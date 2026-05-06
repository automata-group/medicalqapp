// Stub controller for System Settings
// Real world: Store in 'Settings' table or Config file

let systemSettings = {
    appName: "Medical QBank",
    maintenanceMode: false,
    allowRegistration: true,
    defaultLanguage: "ar"
};

let aiSettings = {
    model: "gpt-3.5-turbo",
    temperature: 0.7,
    maxTokens: 500
};

// @desc    Get system settings
// @route   GET /api/v1/admin/settings
// @access  Private (Admin)
exports.getSettings = async (req, res, next) => {
    res.status(200).json({ success: true, data: systemSettings });
};

// @desc    Update system settings
// @route   PUT /api/v1/admin/settings
// @access  Private (Admin)
exports.updateSettings = async (req, res, next) => {
    systemSettings = { ...systemSettings, ...req.body };
    // In real app, save to DB
    res.status(200).json({ success: true, data: systemSettings });
};

// @desc    Get AI config
// @route   GET /api/v1/admin/ai-config
// @access  Private (Admin)
exports.getAiConfig = async (req, res, next) => {
    res.status(200).json({ success: true, data: aiSettings });
};

// @desc    Update AI config
// @route   PUT /api/v1/admin/ai-config
// @access  Private (Admin)
exports.updateAiConfig = async (req, res, next) => {
    aiSettings = { ...aiSettings, ...req.body };
    res.status(200).json({ success: true, data: aiSettings });
};
