const { User, QuestionAttempt, DailyStreak, Specialty, Question, Achievement, UserAchievement, UserMockExam, sequelize } = require('../models');
const { Op } = require('sequelize');

// @desc    Get dashboard overview
// @route   GET /api/v1/dashboard/overview
// @access  Private
exports.getOverview = async (req, res, next) => {
    try {
        const userId = req.user.id;

        // 1. Get total solved questions
        const totalSolved = await QuestionAttempt.count({
            where: { userId },
            distinct: true,
            col: 'questionId'
        });

        const allSpecialties = await Specialty.findAll({
            where: { isActive: true },
            attributes: {
                include: [
                    [
                        sequelize.fn('COUNT', sequelize.col('questions.id')),
                        'totalQuestions'
                    ]
                ]
            },
            include: [{
                model: Question,
                as: 'questions',
                attributes: []
            }],
            group: ['Specialty.id']
        });

        // Calculate total available questions
        let totalAvailableQuestions = await Question.count({
            where: { isActive: true }
        }) || 0;

        // Fallback: if Question.count is 0 but specialties have counts, use the sum
        if (totalAvailableQuestions === 0) {
            totalAvailableQuestions = allSpecialties.reduce((sum, s) => sum + (s.totalQuestions || 0), 0);
        }

        const correctAnswers = await QuestionAttempt.count({
            where: { userId, isCorrect: true },
            distinct: true,
            col: 'questionId'
        });
        const accuracy = totalSolved > 0 ? Math.round((correctAnswers / totalSolved) * 100) : 0;

        // 3. Get streak info
        let streak = await DailyStreak.findOne({ where: { userId } });

        // 4. Get Weak & Strong Areas
        // First, fetch user's selected specialties to ensure they all appear
        const userWithSpecialties = await User.findByPk(userId, {
            include: [{
                model: Specialty,
                as: 'specialties',
                attributes: ['id', 'name', 'icon'],
                through: { attributes: [] }
            }]
        });

        const selectedSpecialties = userWithSpecialties ? userWithSpecialties.specialties : [];

        // Get actual performance stats
        const attemptStats = await QuestionAttempt.findAll({
            attributes: [
                [sequelize.col('question.specialty.name'), 'specialtyName'],
                [sequelize.literal('COUNT(DISTINCT `questionId`)'), 'total'],
                [sequelize.literal('COUNT(DISTINCT CASE WHEN `isCorrect` = true THEN `questionId` ELSE NULL END)'), 'correct']
            ],
            include: [{
                model: Question,
                as: 'question',
                attributes: [],
                include: [{
                    model: Specialty,
                    as: 'specialty',
                    attributes: []
                }]
            }],
            where: { userId },
            group: ['question.specialty.name'],
            raw: true
        });

        // Merge selected specialties with performance data
        // If a user has selected a specialty but hasn't practiced, it shows 0%
        // If a user has practiced a specialty they haven't "selected" (e.g. from general pool), it should also typically be shown,
        // but for the "My Specialties" carousel, strict adherence to selection is usually better.
        // However, let's include all stats, prioritizing selected ones.

        const statsMap = new Map();
        attemptStats.forEach(s => {
            statsMap.set(s.specialtyName, {
                total: parseInt(s.total),
                correct: parseInt(s.correct),
                accuracy: parseInt(s.total) > 0 ? Math.round((parseInt(s.correct) / parseInt(s.total)) * 100) : 0
            });
        });

        // Create list from selected specialties
        const processedStats = selectedSpecialties.map(s => {
            const stat = statsMap.get(s.name) || { total: 0, correct: 0, accuracy: 0 };
            return {
                id: s.id,
                name: s.name,
                icon: s.icon,
                total: stat.total,
                correct: stat.correct,
                accuracy: stat.accuracy
            };
        });

        // If processedStats is empty (user selected nothing), maybe fallback to attemptStats keys?
        // But user flow forces selection. So it should be fine.

        // Sort by accuracy
        processedStats.sort((a, b) => a.accuracy - b.accuracy);
        const weakAreas = processedStats.slice(0, 3); // Bottom 3
        const strongAreas = processedStats.slice(-3).reverse(); // Top 3

        // 5. Exam countdown
        const user = await User.findByPk(userId, { include: ['studyPlan'] });
        let daysToExam = null;
        if (user.studyPlan && user.studyPlan.examDate) {
            const diffTime = new Date(user.studyPlan.examDate) - new Date();
            daysToExam = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        }

        // 6. Activity Graph (Last 7 Days)
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

        const activityGraphData = await QuestionAttempt.findAll({
            attributes: [
                [sequelize.fn('DATE', sequelize.col('QuestionAttempt.createdAt')), 'date'],
                [sequelize.literal('COUNT(DISTINCT `questionId`)'), 'count']
            ],
            where: {
                userId,
                createdAt: { [Op.gte]: sevenDaysAgo }
            },
            group: [sequelize.fn('DATE', sequelize.col('QuestionAttempt.createdAt'))],
            raw: true
        });

        // Fill out 7 days
        const activityGraph = [];
        const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            const dateStr = d.toISOString().split('T')[0]; // YYYY-MM-DD

            const match = activityGraphData.find(a => a.date === dateStr);
            activityGraph.push({
                day: days[d.getDay()],
                count: match ? parseInt(match.count) : 0
            });
        }

        // 7. Continue Revision (Recent unique specialty + topic combinations)
        const recentAttempts = await QuestionAttempt.findAll({
            where: { userId },
            order: [['createdAt', 'DESC']],
            limit: 10,
            include: [{
                model: Question,
                as: 'question',
                include: [
                    { model: Specialty, as: 'specialty', attributes: ['id', 'name', 'icon'] },
                    { model: sequelize.models.Topic, as: 'topic', attributes: ['id', 'name'] }
                ]
            }]
        });

        const recommendedTasks = weakAreas
            .filter(wa => wa.accuracy < 60)
            .map(wa => ({
                specialtyId: wa.id,
                title: wa.name,
                icon: wa.icon,
                subtitle: "Recommended: Weak Area",
                timestamp: new Date(),
                type: 'recommendation'
            }));

        const seenSections = new Set();
        let continueRevisionList = [];

        for (const attempt of recentAttempts) {
            if (!attempt.question || !attempt.question.specialty) continue;
            
            const specialtyId = attempt.question.specialty.id;
            const topicId = attempt.question.topic ? attempt.question.topic.id : null;
            const topicName = attempt.question.topic ? attempt.question.topic.name : attempt.question.subTopic;
            
            const sectionKey = `${specialtyId}-${topicId || topicName}`;
            
            if (!seenSections.has(sectionKey) && continueRevisionList.length < 3) {
                seenSections.add(sectionKey);
                continueRevisionList.push({
                    specialtyId,
                    topicId,
                    topicName,
                    title: attempt.question.specialty.name,
                    icon: attempt.question.specialty.icon,
                    subtitle: topicName || "Recent Practice",
                    timestamp: attempt.createdAt,
                    type: 'specialty'
                });
            }
        }

        let continueRevision = [...recommendedTasks, ...continueRevisionList];

        // Fallback: show selected specialties if no history
        if (continueRevision.length === 0 && selectedSpecialties.length > 0) {
            continueRevision = selectedSpecialties.slice(0, 3).map(s => ({
                specialtyId: s.id,
                title: s.name,
                icon: s.icon,
                subtitle: "Start Revision",
                timestamp: new Date(),
                type: 'specialty'
            }));
        }

        res.status(200).json({
            success: true,
            data: {
                totalSolved,
                totalAvailableQuestions,
                accuracy,
                currentStreak: streak ? streak.currentStreak : 0,
                daysToExam,
                weakAreas,
                strongAreas,
                activityGraph,
                specialtyStats: processedStats,
                allSpecialties,
                continueRevision,
                motivationalQuote: "Keep pushing forward! 🚀"
            }
        });

    } catch (error) {
        next(error);
    }
};

// @desc    Get recent activity
// @route   GET /api/v1/dashboard/recent-activity
// @access  Private
exports.getRecentActivity = async (req, res, next) => {
    try {
        const activities = await QuestionAttempt.findAll({
            where: { userId: req.user.id },
            order: [['createdAt', 'DESC']],
            limit: 10,
            include: [{
                model: Question,
                as: 'question',
                attributes: ['text', 'difficulty'],
                include: [{ model: Specialty, as: 'specialty', attributes: ['name', 'icon'] }]
            }]
        });

        res.status(200).json({
            success: true,
            count: activities.length,
            data: activities
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get daily stats
// @route   GET /api/v1/dashboard/stats/daily
// @access  Private
exports.getDailyStats = async (req, res, next) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const attempts = await QuestionAttempt.findAll({
            where: {
                userId: req.user.id,
                createdAt: { [Op.gte]: today }
            }
        });

        const dailyQuestions = new Set();
        const dailyCorrect = new Set();
        let timeSpent = 0;

        attempts.forEach(a => {
            dailyQuestions.add(a.questionId);
            if (a.isCorrect) dailyCorrect.add(a.questionId);
            timeSpent += (a.timeTaken || 0);
        });

        const total = dailyQuestions.size;
        const correct = dailyCorrect.size;

        res.status(200).json({
            success: true,
            data: {
                date: today,
                totalQuestions: total,
                correctAnswers: correct,
                accuracy: total > 0 ? Math.round((correct / total) * 100) : 0,
                timeSpentSeconds: timeSpent
            }
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get weekly stats
// @route   GET /api/v1/dashboard/stats/weekly
// @access  Private
exports.getWeeklyStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const stats = [];

        // Loop through last 7 days
        for (let i = 6; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];

            const dayStats = await QuestionAttempt.findOne({
                attributes: [
                    [sequelize.literal('COUNT(DISTINCT `questionId`)'), 'total'],
                    [sequelize.literal('COUNT(DISTINCT CASE WHEN `isCorrect` = true THEN `questionId` ELSE NULL END)'), 'correct']
                ],
                where: {
                    userId,
                    createdAt: {
                        [Op.gte]: new Date(dateStr + 'T00:00:00Z'),
                        [Op.lte]: new Date(dateStr + 'T23:59:59Z')
                    }
                },
                raw: true
            });

            stats.push({
                date: dateStr,
                total: parseInt(dayStats.total) || 0,
                correct: parseInt(dayStats.correct) || 0
            });
        }

        res.status(200).json({ success: true, count: stats.length, data: stats });
    } catch (error) {
        next(error);
    }
};

// @desc    Get monthly stats
// @route   GET /api/v1/dashboard/stats/monthly
// @access  Private
exports.getMonthlyStats = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const stats = [];

        // For monthly, grouping by date is more efficient than 30 separate queries
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const data = await QuestionAttempt.findAll({
            attributes: [
                [sequelize.fn('DATE', sequelize.col('createdAt')), 'date'],
                [sequelize.literal('COUNT(DISTINCT `questionId`)'), 'total'],
                [sequelize.literal('COUNT(DISTINCT CASE WHEN `isCorrect` = true THEN `questionId` ELSE NULL END)'), 'correct']
            ],
            where: {
                userId,
                createdAt: { [Op.gte]: thirtyDaysAgo }
            },
            group: [sequelize.fn('DATE', sequelize.col('createdAt'))],
            raw: true
        });

        // Fill in missing dates
        for (let i = 29; i >= 0; i--) {
            const date = new Date();
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];

            const match = data.find(d => d.date === dateStr);
            stats.push({
                date: dateStr,
                total: match ? parseInt(match.total) : 0,
                correct: match ? parseInt(match.correct) : 0
            });
        }

        res.status(200).json({ success: true, count: stats.length, data: stats });
    } catch (error) {
        next(error);
    }
};

// @desc    Get achievements and progress
// @route   GET /api/v1/dashboard/achievements
// @access  Private
exports.getAchievements = async (req, res, next) => {
    try {
        const userId = req.user.id;
        const achievements = await Achievement.findAll();
        const userAchievements = await UserAchievement.findAll({ where: { userId } });
        const unlockedIds = new Set(userAchievements.map(ua => ua.achievementId));

        // Stats for progress calc
        const totalSolved = await QuestionAttempt.count({
            where: { userId },
            distinct: true,
            col: 'questionId'
        });
        const streak = await DailyStreak.findOne({ where: { userId } });
        const currentStreak = streak ? streak.currentStreak : 0;
        const maxMockScore = (await UserMockExam.max('score', { where: { userId } })) || 0;

        const result = [];

        for (const ach of achievements) {
            let isUnlocked = unlockedIds.has(ach.id);
            let progress = 0;
            let target = ach.criteriaValue;

            switch (ach.criteriaType) {
                case 'questions_solved':
                    progress = totalSolved;
                    break;
                case 'streak_days':
                    progress = currentStreak;
                    break;
                case 'mock_score':
                    progress = maxMockScore;
                    break;
                default:
                    progress = 0;
            }

            // Sync Unlock if criteria met but not in DB
            if (!isUnlocked && progress >= target) {
                try {
                    await UserAchievement.create({ userId, achievementId: ach.id });
                    isUnlocked = true;
                    // Optional: Add notification logic here in future
                } catch (e) {
                    // Ignore duplicate entry error race condition
                }
            }

            result.push({
                id: ach.id,
                name: ach.name,
                description: ach.description,
                icon: ach.icon,
                xpReward: ach.xpReward,
                isUnlocked,
                progress: Math.min(progress, target),
                target
            });
        }

        res.status(200).json({ success: true, count: result.length, data: result });
    } catch (error) {
        next(error);
    }
};
