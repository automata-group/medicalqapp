const { saveSessionLogic, getActiveSessionLogic } = require('./sessionBase');

exports.saveGeneralSession = async (req, res) => {
    try {
        const session = await saveSessionLogic(req.user.id, req.body, 'general');
        res.status(201).json({ success: true, data: session });
    } catch (error) {
        console.error('Save General Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

exports.getGeneralSession = async (req, res) => {
    try {
        const session = await getActiveSessionLogic(req.user.id, 'general');
        if (!session) return res.status(404).json({ success: false, message: 'No active general session' });
        res.status(200).json({ success: true, data: session });
    } catch (error) {
        console.error('Get General Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};
