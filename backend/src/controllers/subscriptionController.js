const { Subscription, User, SubscriptionPlan, Payment, DiscountCode } = require('../models');
const axios = require('axios');
const crypto = require('crypto');

// ─── Helper: Verify Moyasar Webhook Signature ──────────────────────
const verifyMoyasarWebhook = (req) => {
    const secret = process.env.MOYASAR_WEBHOOK_SECRET;
    if (!secret) {
        console.warn('⚠️ MOYASAR_WEBHOOK_SECRET not set — webhook signature verification skipped.');
        return true; // Allow in development but warn loudly
    }

    const signature = req.headers['x-moyasar-signature'] || req.headers['x-signature'];
    if (!signature) {
        console.error('Webhook: Missing signature header');
        return false;
    }

    const payload = JSON.stringify(req.body);
    const expectedSignature = crypto
        .createHmac('sha256', secret)
        .update(payload)
        .digest('hex');

    const sigBuf = Buffer.from(signature, 'utf8');
    const expectedBuf = Buffer.from(expectedSignature, 'utf8');

    // timingSafeEqual throws if lengths differ — handle gracefully
    if (sigBuf.length !== expectedBuf.length) {
        return false;
    }
    return crypto.timingSafeEqual(sigBuf, expectedBuf);
};


// @desc    Get all active subscription plans
// @route   GET /api/v1/subscriptions/plans
// @access  Public
exports.getPlans = async (req, res, next) => {
    try {
        const plans = await SubscriptionPlan.findAll({
            where: { isActive: true },
            order: [['price', 'ASC']]
        });

        res.status(200).json({
            success: true,
            data: plans
        });
    } catch (err) {
        next(err);
    }
};


exports.getSubscription = async (req, res, next) => {
    try {
        const subscription = await Subscription.findOne({
            where: { userId: req.user.id },
            include: [{ model: SubscriptionPlan, as: 'plan' }],
            order: [['createdAt', 'DESC']] // Get latest
        });

        if (subscription) {
            // Check local expiry logic
            if (subscription.status === 'active' && new Date() > subscription.endDate) {
                subscription.status = 'expired';
                await subscription.save();
            }
        }

        res.status(200).json({
            success: true,
            data: subscription
        });
    } catch (err) {
        next(err);
    }
};

exports.createCheckoutSession = async (req, res, next) => {
    try {
        const { planId, promoCode } = req.body;

        const plan = await SubscriptionPlan.findByPk(planId);
        if (!plan || !plan.isActive) {
            return res.status(404).json({ success: false, message: 'Plan not found or inactive' });
        }

        // ─── Promo Code Validation (Server-Side) ───────────────────
        let finalPrice = parseFloat(plan.price);
        let appliedDiscount = null;

        if (promoCode && promoCode.trim()) {
            const discount = await DiscountCode.findOne({
                where: { code: promoCode.trim().toUpperCase() }
            });

            if (discount && discount.isValid()) {
                if (discount.type === 'percentage') {
                    finalPrice = finalPrice * (1 - parseFloat(discount.value) / 100);
                } else if (discount.type === 'fixed_amount') {
                    finalPrice = Math.max(0, finalPrice - parseFloat(discount.value));
                }
                appliedDiscount = {
                    code: discount.code,
                    type: discount.type,
                    value: parseFloat(discount.value)
                };
                // Atomically increment usage count to prevent race conditions
                await discount.increment('usedCount');
            } else {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid, expired, or fully used promo code'
                });
            }
        }

        // Ensure minimum charge (Moyasar requires at least 1 SAR = 100 Halalas)
        finalPrice = Math.max(finalPrice, 1);
        const amount = Math.round(finalPrice * 100); // SAR to Halala

        if (!process.env.MOYASAR_PUBLISHABLE_KEY) {
            return res.status(500).json({ success: false, message: 'Payment gateway not configured' });
        }

        // Generate a unique session token for this checkout
        const sessionToken = crypto.randomUUID();
        
        // Dynamically determine the host (e.g., healthlicenseprep.com)
        const host = req.get('host');
        const protocol = req.protocol;
        const callbackUrl = `${protocol}://${host}/payment-callback`;

        // Store session data temporarily (expires in 30 minutes)
        checkoutSessions.set(sessionToken, {
            publishableKey: process.env.MOYASAR_PUBLISHABLE_KEY,
            amount,
            currency: plan.currency || 'SAR',
            description: `Medical Q ${plan.name}`,
            callbackUrl,
            metadata: {
                user_id: req.user.id.toString(),
                plan_id: plan.id.toString(),
                promo_code: appliedDiscount ? appliedDiscount.code : '',
                original_price: plan.price.toString(),
                final_price: finalPrice.toString()
            },
            createdAt: Date.now()
        });

        // Auto-cleanup after 30 minutes
        setTimeout(() => checkoutSessions.delete(sessionToken), 30 * 60 * 1000);

        // Return the checkout page URL
        res.status(200).json({
            success: true,
            checkoutUrl: `/api/v1/subscriptions/checkout-page/${sessionToken}`,
            finalPrice,
            appliedDiscount
        });

    } catch (err) {
        console.error('Payment Config Error:', err.message);
        return res.status(500).json({
            success: false,
            message: 'Payment gateway error',
            error: err.message
        });
    }
};

// ─── In-Memory Checkout Sessions Store ──────────────────────────
const checkoutSessions = new Map();

// @desc    Serve the Moyasar JS SDK checkout page
// @route   GET /api/v1/subscriptions/checkout-page/:token
// @access  Public (protected by unique token)
exports.renderCheckoutPage = (req, res) => {
    const { token } = req.params;
    const session = checkoutSessions.get(token);

    if (!session) {
        return res.status(404).send('<h1>Session expired or invalid</h1><p>Please go back and try again.</p>');
    }

    const { publishableKey, amount, currency, description, callbackUrl, metadata } = session;
    const metadataJson = JSON.stringify(metadata);
    const displayAmount = (amount / 100).toFixed(2);

    const html = `<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Complete Payment</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/moyasar-payment-form@2.2.7/dist/moyasar.css" />
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f8fafc;
      padding: 16px;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    .payment-container { width: 100%; max-width: 480px; margin: 0 auto; flex: 1; }
    .payment-header {
      text-align: center; margin-bottom: 24px; padding: 24px;
      background: white; border-radius: 20px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    }
    .payment-header h2 { font-size: 16px; color: #64748b; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
    .payment-header .amount { font-size: 36px; font-weight: 800; color: #1e293b; }
    .payment-header .currency { font-size: 14px; color: #94a3b8; font-weight: 600; margin-top: 4px; }
    
    .mysr-form {
      background: white; border-radius: 20px; padding: 8px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    }
    
    .payment-footer {
      text-align: center; margin-top: 32px; padding-bottom: 24px;
    }
    .payment-footer p { color: #94a3b8; font-size: 12px; display: flex; align-items: center; justify-content: center; gap: 6px; }
    
    /* Center the loader if JS takes time */
    #loading-indicator {
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      padding: 40px; color: #64748b;
    }
    .spinner {
      border: 3px solid #f3f3f3; border-top: 3px solid #2563eb;
      border-radius: 50%; width: 30px; height: 30px;
      animation: spin 1s linear infinite; margin-bottom: 12px;
    }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="payment-container">
    <div class="payment-header">
      <h2>${description}</h2>
      <div class="amount">${displayAmount}</div>
      <div class="currency">${currency}</div>
    </div>
    
    <div id="loading-indicator">
      <div class="spinner"></div>
      <p>Loading Payment Form...</p>
    </div>

    <div class="mysr-form"></div>
    
    <div class="payment-footer">
      <p>🔒 Secure Payment powered by Moyasar</p>
    </div>

    <!-- On-Screen Debug Console -->
    <div id="debug-console" style="margin-top: 20px; padding: 10px; background: #1e293b; color: #10b981; border-radius: 8px; max-height: 200px; overflow-y: auto; font-family: monospace; font-size: 11px; text-align: left; display: block;">
      <div>[System] Debug Console Initialized</div>
    </div>
  </div>

  <script>
    // 1. Intercept console messages FIRST
    const debugConsole = document.getElementById('debug-console');
    const originalLog = console.log;
    const originalError = console.error;

    function logToScreen(msg, isError) {
      if(!debugConsole) return;
      const color = isError ? '#ef4444' : '#10b981';
      const prefix = isError ? '[ERROR] ' : '[INFO] ';
      const div = document.createElement('div');
      div.style.color = color;
      div.style.marginBottom = '4px';
      div.style.wordBreak = 'break-all';
      div.textContent = prefix + msg;
      debugConsole.appendChild(div);
      debugConsole.scrollTop = debugConsole.scrollHeight;
    }

    console.log = function(...args) {
      logToScreen(args.join(' '), false);
      originalLog.apply(console, args);
    };

    console.error = function(...args) {
      const msg = args.map(a => (a && a.message) ? a.message : String(a)).join(' ');
      logToScreen(msg, true);
      originalError.apply(console, args);
    };

    console.log("Starting payment page load...");

    // 2. Watchdog timer for CDN blocking
    setTimeout(() => {
      if (typeof Moyasar === 'undefined') {
        console.error("Moyasar SDK failed to load after 10 seconds. The CDN might be blocked by your internet provider.");
        document.getElementById('loading-indicator').innerHTML = '<p style="color:red">Failed to load payment form. Please try another network.</p>';
      }
    }, 10000);
  </script>

  <!-- Use unpkg instead of jsdelivr to bypass potential ISP blocking -->
  <script src="https://unpkg.com/moyasar-payment-form@2.2.7/dist/moyasar.umd.min.js"></script>
  
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      try {
        console.log("DOM loaded. Checking Moyasar object...");
        if (typeof Moyasar === 'undefined') {
            console.error("Moyasar object is missing!");
            return;
        }

        console.log("Checking Publishable Key: " + ('${publishableKey}'.substring(0, 10)) + "...");
        console.log("Initializing Moyasar with amount: ${amount}");
        
        Moyasar.init({
          element: '.mysr-form',
          amount: ${amount},
          currency: '${currency}',
          description: '${description.replace(/'/g, "\\'")}',
          publishable_api_key: '${publishableKey}',
          callback_url: '${callbackUrl}',
          metadata: ${metadataJson},
          supported_networks: ['visa', 'mastercard', 'mada'],
          methods: ['creditcard', 'applepay', 'stcpay'],
          on_completed: function(payment) {
             console.log("Payment completed via SDK. Status: " + payment.status);
          },
          on_error: function(error) {
             console.error("Moyasar Form Level Error: " + JSON.stringify(error));
          }
        });
        
        // Hide loading indicator once initialized
        document.getElementById('loading-indicator').style.display = 'none';
        console.log("Moyasar initialized successfully");
      } catch (e) {
        console.error("Initialization Script Error:", e);
        document.getElementById('loading-indicator').innerHTML = '<p style="color:red">Error loading payment form. Please contact support.</p>';
      }
    });
  </script>
</body>
</html>`;

    // Delete session after serving (one-time use)
    checkoutSessions.delete(token);
    res.setHeader('Content-Type', 'text/html');
    res.send(html);
};

exports.handleWebhook = async (req, res, next) => {
    // ─── Step 1: Verify Webhook Signature ───────────────────────
    if (!verifyMoyasarWebhook(req)) {
        console.error('Webhook: Invalid signature — rejecting request');
        return res.status(403).send('Forbidden: Invalid webhook signature');
    }

    const event = req.body;

    try {
        if (event.type === 'payment.paid') {
            const paymentData = event.data;
            const transactionId = paymentData.id;
            const userId = paymentData.metadata && paymentData.metadata.user_id;
            const planId = paymentData.metadata && paymentData.metadata.plan_id;

            if (!userId) {
                console.error('Webhook: user_id missing in metadata');
                return res.status(400).send('Metadata missing');
            }

            // ─── Step 2: Idempotency Check ──────────────────────────
            const existingPayment = await Payment.findOne({ where: { transactionId } });
            if (existingPayment) {
                console.log(`Webhook: Duplicate payment ${transactionId} — already processed.`);
                return res.status(200).send('Already processed');
            }

            // Find plan
            let plan;
            if (planId) {
                plan = await SubscriptionPlan.findByPk(planId);
            } else {
                let slug = 'monthly-pro';
                if (paymentData.description && paymentData.description.toLowerCase().includes('yearly')) {
                    slug = 'yearly-pro';
                }
                plan = await SubscriptionPlan.findOne({ where: { slug } });
            }

            if (!plan) {
                console.error(`Webhook: Plan not found (planId: ${planId})`);
                return res.status(400).send('Plan not found');
            }

            const duration = plan.durationInDays || 30;
            const startDate = new Date();
            const endDate = new Date();
            endDate.setDate(startDate.getDate() + duration);

            // ─── Step 3: Record Payment in Payment Table ────────────
            await Payment.create({
                userId: parseInt(userId),
                amount: paymentData.amount ? paymentData.amount / 100 : parseFloat(plan.price), // Convert Halalas back to SAR
                currency: paymentData.currency || plan.currency || 'SAR',
                status: 'completed',
                provider: 'moyasar',
                transactionId: transactionId,
                paymentMethod: paymentData.source ? paymentData.source.type : 'unknown',
                description: `${plan.name} subscription`,
                metadata: {
                    plan_id: plan.id,
                    promo_code: paymentData.metadata?.promo_code || null,
                    original_price: paymentData.metadata?.original_price || null,
                    final_price: paymentData.metadata?.final_price || null,
                    moyasar_invoice_id: paymentData.invoice_id || null
                }
            });

            // ─── Step 4: Activate Subscription ──────────────────────
            const existingSub = await Subscription.findOne({ where: { userId } });

            if (existingSub) {
                await existingSub.update({
                    status: 'active',
                    planId: plan.id,
                    startDate,
                    endDate,
                    paymentId: transactionId,
                    autoRenew: true
                });
            } else {
                await Subscription.create({
                    userId,
                    planId: plan.id,
                    status: 'active',
                    startDate,
                    endDate,
                    paymentId: transactionId,
                    autoRenew: true
                });
            }

            console.log(`✅ Subscription activated for user ${userId} on plan ${plan.name} (txn: ${transactionId})`);
        }

        res.status(200).send('Webhook received');
    } catch (err) {
        console.error('Webhook Error:', err);
        res.status(500).send('Server Error');
    }
};

// @desc    Validate a promo code (for frontend display)
// @route   POST /api/v1/subscriptions/validate-promo
// @access  Protected
exports.validatePromoCode = async (req, res, next) => {
    try {
        const { code, planId } = req.body;
        if (!code) {
            return res.status(400).json({ success: false, message: 'Promo code is required' });
        }

        const discount = await DiscountCode.findOne({
            where: { code: code.trim().toUpperCase() }
        });

        if (!discount || !discount.isValid()) {
            return res.status(404).json({ success: false, message: 'Invalid, expired, or fully used promo code' });
        }

        // Calculate the discounted price if planId is provided
        let discountedPrice = null;
        if (planId) {
            const plan = await SubscriptionPlan.findByPk(planId);
            if (plan) {
                let price = parseFloat(plan.price);
                if (discount.type === 'percentage') {
                    discountedPrice = price * (1 - parseFloat(discount.value) / 100);
                } else {
                    discountedPrice = Math.max(0, price - parseFloat(discount.value));
                }
                discountedPrice = Math.round(discountedPrice * 100) / 100;
            }
        }

        res.status(200).json({
            success: true,
            data: {
                code: discount.code,
                type: discount.type,
                value: parseFloat(discount.value),
                discountedPrice
            }
        });
    } catch (err) {
        next(err);
    }
};
