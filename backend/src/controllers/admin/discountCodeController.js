const { DiscountCode, AdminActivityLog, Payment } = require('../../models');
const { Op } = require('sequelize');

// @desc    Get all discount codes
// @route   GET /api/v1/admin/discount-codes
// @access  Private (Admin)
exports.getDiscountCodes = async (req, res, next) => {
    try {
        const codes = await DiscountCode.findAll();
        res.status(200).json({ success: true, data: codes });
    } catch (error) {
        next(error);
    }
};

// @desc    Create discount code
// @route   POST /api/v1/admin/discount-codes
// @access  Private (Admin)
exports.createDiscountCode = async (req, res, next) => {
    try {
        const { code, discountType, discountValue, maxUses, expiresAt, isActive, type, value } = req.body;

        const discount = await DiscountCode.create({
            code,
            type: type || discountType,
            value: value || discountValue,
            maxUses,
            expiresAt,
            isActive
        });

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'CREATE_DISCOUNT',
            targetResource: `Code:${discount.code}`,
            ipAddress: req.ip
        });

        res.status(201).json({ success: true, data: discount });
    } catch (error) {
        next(error);
    }
};

// @desc    Update discount code
// @route   PUT /api/v1/admin/discount-codes/:id
// @access  Private (Admin)
exports.updateDiscountCode = async (req, res, next) => {
    try {
        let discount = await DiscountCode.findByPk(req.params.id);

        if (!discount) {
            return res.status(404).json({ success: false, message: 'Discount code not found' });
        }

        discount = await discount.update(req.body);

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'UPDATE_DISCOUNT',
            targetResource: `Code:${discount.code}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, data: discount });
    } catch (error) {
        next(error);
    }
};

// @desc    Delete discount code
// @route   DELETE /api/v1/admin/discount-codes/:id
// @access  Private (Admin)
exports.deleteDiscountCode = async (req, res, next) => {
    try {
        const discount = await DiscountCode.findByPk(req.params.id);

        if (!discount) {
            return res.status(404).json({ success: false, message: 'Discount code not found' });
        }

        await discount.destroy();

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'DELETE_DISCOUNT',
            targetResource: `Code:${req.params.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Discount code deleted' });
    } catch (error) {
        next(error);
    }
};

// @desc    Get discount usage stats
// @route   GET /api/v1/admin/discount-codes/:id/usage
// @access  Private (Admin)
exports.getDiscountUsage = async (req, res, next) => {
    try {
        const discount = await DiscountCode.findByPk(req.params.id);
        if (!discount) {
            return res.status(404).json({ success: false, message: 'Discount code not found' });
        }

        // Assuming we have a DiscountCodeUsage model or similar tracking
        // If not, we might track it in Payment or just use the global 'usedCount' if we have it on the model
        // Phase 1 list said: DiscountCodeUsage (Implied)
        // Let's assume we check Payments with this code

        // Mocking usage data for MVP if table doesn't exist
        // Or check if Payment has 'discountCodeId' or 'discountCode'

        const usageCount = await Payment.count({
            where: { metadata: { [Op.like]: `%"discountCode":"${discount.code}"%` }, status: 'completed' }
        });

        res.status(200).json({
            success: true,
            data: {
                code: discount.code,
                totalUses: usageCount, // or discount.usedCount if we increment it
                maxUses: discount.maxUses
            }
        });
    } catch (error) {
        next(error);
    }
};
