const { AppSetting } = require('../../models');

const defaultSystemSettings = {
    appName: "Medical QBank",
    maintenanceMode: false,
    allowRegistration: true,
    defaultLanguage: "ar",
    showQuestionCount: false // Toggle to hide/show question counts in mobile app
};

const defaultAiSettings = {
    model: "gpt-3.5-turbo",
    temperature: 0.7,
    maxTokens: 500
};

// @desc    Get system settings
// @route   GET /api/v1/admin/config/settings
// @access  Private (Admin)
exports.getSettings = async (req, res, next) => {
    try {
        let setting = await AppSetting.findOne({ where: { key: 'system_settings' } });
        if (!setting) {
            setting = await AppSetting.create({
                key: 'system_settings',
                value: defaultSystemSettings,
                description: 'Global system and app settings'
            });
        }
        res.status(200).json({ success: true, data: { ...defaultSystemSettings, ...setting.value } });
    } catch (error) {
        console.error('Error fetching settings:', error);
        res.status(500).json({ success: false, message: 'Server error fetching settings' });
    }
};

// @desc    Update system settings
// @route   PUT /api/v1/admin/config/settings
// @access  Private (Admin)
exports.updateSettings = async (req, res, next) => {
    try {
        let setting = await AppSetting.findOne({ where: { key: 'system_settings' } });
        const currentVal = setting ? setting.value : defaultSystemSettings;
        const updatedVal = { ...currentVal, ...req.body };

        if (setting) {
            await setting.update({ value: updatedVal });
        } else {
            setting = await AppSetting.create({
                key: 'system_settings',
                value: updatedVal,
                description: 'Global system and app settings'
            });
        }

        res.status(200).json({ success: true, data: setting.value, message: 'Settings updated successfully' });
    } catch (error) {
        console.error('Error updating settings:', error);
        res.status(500).json({ success: false, message: 'Server error updating settings' });
    }
};

// @desc    Get AI config
// @route   GET /api/v1/admin/config/ai-config
// @access  Private (Admin)
exports.getAiConfig = async (req, res, next) => {
    try {
        let setting = await AppSetting.findOne({ where: { key: 'ai_settings' } });
        if (!setting) {
            setting = await AppSetting.create({
                key: 'ai_settings',
                value: defaultAiSettings,
                description: 'AI model parameters and settings'
            });
        }
        res.status(200).json({ success: true, data: { ...defaultAiSettings, ...setting.value } });
    } catch (error) {
        console.error('Error fetching AI settings:', error);
        res.status(500).json({ success: false, message: 'Server error fetching AI settings' });
    }
};

// @desc    Update AI config
// @route   PUT /api/v1/admin/config/ai-config
// @access  Private (Admin)
exports.updateAiConfig = async (req, res, next) => {
    try {
        let setting = await AppSetting.findOne({ where: { key: 'ai_settings' } });
        const currentVal = setting ? setting.value : defaultAiSettings;
        const updatedVal = { ...currentVal, ...req.body };

        if (setting) {
            await setting.update({ value: updatedVal });
        } else {
            setting = await AppSetting.create({
                key: 'ai_settings',
                value: updatedVal,
                description: 'AI model parameters and settings'
            });
        }

        res.status(200).json({ success: true, data: setting.value, message: 'AI settings updated successfully' });
    } catch (error) {
        console.error('Error updating AI settings:', error);
        res.status(500).json({ success: false, message: 'Server error updating AI settings' });
    }
};
