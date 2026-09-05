const { StudySession, QuestionAttempt } = require('../../models');
const { Op } = require('sequelize');

/**
 * Common logic for saving a study session
 */
exports.saveSessionLogic = async (userId, data, type) => {
    const { specialtyId, subTopic, filter, attemptedIds, lastQuestionId } = data;

    // Deactivate previous active sessions for this user that are NOT of this specific section
    await StudySession.update({ isActive: false }, {
        where: { 
            userId, 
            isActive: true,
            [Op.or]: [
                { specialtyId: { [Op.ne]: specialtyId || null } },
                { subTopic: { [Op.ne]: subTopic || null } },
                { sessionType: { [Op.ne]: type } }
            ]
        }
    });

    // Upsert
    const [session, created] = await StudySession.findOrCreate({
        where: { 
            userId, 
            specialtyId: specialtyId || null, 
            subTopic: subTopic || null,
            sessionType: type
        },
        defaults: {
            filter,
            attemptedIds: Array.isArray(attemptedIds) ? attemptedIds.join(',') : attemptedIds,
            lastQuestionId,
            isActive: true
        }
    });

    if (!created) {
        await session.update({
            filter,
            attemptedIds: Array.isArray(attemptedIds) ? attemptedIds.join(',') : attemptedIds,
            lastQuestionId,
            isActive: true
        });
    }

    return session;
};

/**
 * Common logic for getting an active session
 */
exports.getActiveSessionLogic = async (userId, type, filters = {}) => {
    const where = { userId, isActive: true, sessionType: type };
    if (filters.specialtyId) where.specialtyId = filters.specialtyId;
    if (filters.subTopic) where.subTopic = filters.subTopic;

    const session = await StudySession.findOne({
        where,
        order: [['updatedAt', 'DESC']]
    });

    if (!session) return null;

    const attemptedIds = session.attemptedIds 
        ? session.attemptedIds.split(',').map(id => parseInt(id, 10)).filter(id => !isNaN(id)) 
        : [];

    let correctCount = 0;
    if (attemptedIds.length > 0) {
        correctCount = await QuestionAttempt.count({
            where: {
                userId,
                questionId: { [Op.in]: attemptedIds },
                isCorrect: true
            }
        });
    }

    return {
        ...session.toJSON(),
        attemptedIds,
        correctCount
    };
};
