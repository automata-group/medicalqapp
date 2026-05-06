// Mock Payment Service for Moyasar
// In real implementation, use 'moyasar' node package or axios calls to https://api.moyasar.com/v1/payments

exports.initiatePayment = async (amount, currency, description, user) => {
    console.log(`Initiating Payment: ${amount} ${currency} for ${description}`);

    // Stub response simulating a Payment URL or Transaction ID
    return {
        id: `pay_${Date.now()}`,
        status: 'initiated',
        amount,
        currency,
        description,
        redirect_url: `http://localhost:3000/payment/callback?status=paid` // Simulate success redirect
    };
};

exports.verifyPayment = async (paymentId) => {
    console.log(`Verifying Payment: ${paymentId}`);

    // Stub verification
    return {
        id: paymentId,
        status: 'paid', // Simulate success
        source: {
            type: 'creditcard',
            company: 'visa',
            number: 'XXXX-XXXX-XXXX-1234'
        }
    };
};

exports.refundPayment = async (paymentId) => {
    console.log(`Refunding Payment: ${paymentId}`);
    return {
        id: paymentId,
        status: 'refunded'
    };
};
