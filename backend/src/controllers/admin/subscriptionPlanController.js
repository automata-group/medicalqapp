const { SubscriptionPlan, AdminActivityLog } = require('../../models');

// @desc    Get all subscription plans (Admin)
// @route   GET /api/v1/admin/subscription-plans
// @access  Private (Admin)
exports.getPlans = async (req, res, next) => {
    try {
        const plans = await SubscriptionPlan.findAll();
        res.status(200).json({ success: true, data: plans });
    } catch (error) {
        next(error);
    }
};

// @desc    Create subscription plan
// @route   POST /api/v1/admin/subscription-plans
// @access  Private (Admin)
exports.createPlan = async (req, res, next) => {
    try {
        const { name, slug, price, duration, durationInDays, features, isActive, discountPercentage, isPopular } = req.body;

        const plan = await SubscriptionPlan.create({
            name,
            slug: slug || name.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
            price,
            durationInDays: durationInDays || duration, // accept either field name
            features,
            isActive,
            discountPercentage,
            isPopular
        });

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'CREATE_PLAN',
            targetResource: `Plan:${plan.id}`,
            ipAddress: req.ip
        });

        res.status(201).json({ success: true, data: plan });
    } catch (error) {
        next(error);
    }
};

// @desc    Update subscription plan
// @route   PUT /api/v1/admin/subscription-plans/:id
// @access  Private (Admin)
exports.updatePlan = async (req, res, next) => {
    try {
        let plan = await SubscriptionPlan.findByPk(req.params.id);

        if (!plan) {
            return res.status(404).json({ success: false, message: 'Plan not found' });
        }

        plan = await plan.update(req.body);

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'UPDATE_PLAN',
            targetResource: `Plan:${plan.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, data: plan });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete subscription plan
// @route   DELETE /api/v1/admin/subscription-plans/:id
// @access  Private (Admin)
exports.deletePlan = async (req, res, next) => {
    try {
        const plan = await SubscriptionPlan.findByPk(req.params.id);

        if (!plan) {
            return res.status(404).json({ success: false, message: 'Plan not found' });
        }

        // Check if plan has active subscriptions? Ideally yes, preventing delete.
        // For MVP, allow delete (cascading or keeping history might be needed).
        // Let's safe delete by just marking inactive if used, or destroy if confident.
        // Using destroy for now.
        await plan.destroy();

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'DELETE_PLAN',
            targetResource: `Plan:${req.params.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Plan deleted' });
    } catch (error) {
        next(error);
    }
};

// @desc    Seed / restore official subscription plans
// @route   POST /api/v1/admin/subscription-plans/seed-defaults
// @access  Private (Admin)
exports.seedDefaultPlans = async (req, res, next) => {
    try {
        const { seedOfficialPlans } = require('../../utils/seedPlans');
        await seedOfficialPlans();
        const plans = await SubscriptionPlan.findAll({
            order: [['price', 'ASC']]
        });

        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'SEED_OFFICIAL_PLANS',
            targetResource: 'SubscriptionPlans',
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Official plans seeded successfully', data: plans });
    } catch (error) {
        next(error);
    }
};
