const { saveSessionLogic, getActiveSessionLogic } = require('./sessionBase');

exports.saveTopicSession = async (req, res) => {
    try {
        const session = await saveSessionLogic(req.user.id, req.body, 'topic');
        res.status(201).json({ success: true, data: session });
    } catch (error) {
        console.error('Save Topic Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

exports.getTopicSession = async (req, res) => {
    try {
        const { specialtyId, subTopic } = req.query;
        const session = await getActiveSessionLogic(req.user.id, 'topic', { specialtyId, subTopic });
        if (!session) return res.status(404).json({ success: false, message: 'No active topic session' });
        res.status(200).json({ success: true, data: session });
    } catch (error) {
        console.error('Get Topic Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};
