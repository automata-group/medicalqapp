const { saveSessionLogic, getActiveSessionLogic } = require('./sessionBase');

exports.saveSpecialtySession = async (req, res) => {
    try {
        const session = await saveSessionLogic(req.user.id, req.body, 'specialty');
        res.status(201).json({ success: true, data: session });
    } catch (error) {
        console.error('Save Specialty Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

exports.getSpecialtySession = async (req, res) => {
    try {
        const { specialtyId } = req.query;
        const session = await getActiveSessionLogic(req.user.id, 'specialty', { specialtyId });
        if (!session) return res.status(404).json({ success: false, message: 'No active specialty session' });
        res.status(200).json({ success: true, data: session });
    } catch (error) {
        console.error('Get Specialty Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};
