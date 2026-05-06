const { saveGeneralSession, getGeneralSession } = require('./sessions/generalSessionController');
const { saveSpecialtySession, getSpecialtySession } = require('./sessions/specialtySessionController');
const { saveTopicSession, getTopicSession } = require('./sessions/topicSessionController');
const { StudySession } = require('../models');

exports.saveSession = async (req, res) => {
    const { sessionType, subTopic, specialtyId } = req.body || {};
    
    let type = sessionType;
    if (!type) {
        if (subTopic) type = 'topic';
        else if (specialtyId) type = 'specialty';
        else type = 'general';
    }

    switch (type) {
        case 'topic':
            return saveTopicSession(req, res);
        case 'specialty':
            return saveSpecialtySession(req, res);
        case 'general':
        default:
            return saveGeneralSession(req, res);
    }
};

exports.getActiveSession = async (req, res) => {
    const { sessionType, subTopic, specialtyId } = req.query;

    let type = sessionType;
    if (!type) {
        if (subTopic) type = 'topic';
        else if (specialtyId) type = 'specialty';
        else type = 'general';
    }

    switch (type) {
        case 'topic':
            return getTopicSession(req, res);
        case 'specialty':
            return getSpecialtySession(req, res);
        case 'general':
        default:
            return getGeneralSession(req, res);
    }
};

exports.deleteSession = async (req, res) => {
    try {
        const userId = req.user.id;
        const { sessionType, specialtyId, subTopic } = req.body || {};

        const where = { userId, isActive: true };
        if (sessionType) where.sessionType = sessionType;
        if (specialtyId) where.specialtyId = specialtyId;
        if (subTopic) where.subTopic = subTopic;

        await StudySession.update({ isActive: false }, { where });

        res.status(200).json({ success: true, message: 'Session cleared' });
    } catch (error) {
        console.error('Delete Session Error:', error);
        res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};
