const { User, Specialty, Question, QuestionAttempt, StudyPlan, Subscription, SubscriptionPlan, Bookmark, DailyStreak, Achievement, UserAchievement, UserMockExam, MockExam, UserSpecialty, sequelize } = require('../models');
const bcrypt = require('bcryptjs');

const seedTester = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ DB Connected');

        const email = 'test@medqbank.com';
        let user = await User.findOne({ where: { email } });

        if (user) {
            console.log('🧹 Clearing existing test user data...');
            await QuestionAttempt.destroy({ where: { userId: user.id } });
            await StudyPlan.destroy({ where: { userId: user.id } });
            await Subscription.destroy({ where: { userId: user.id } });
            await Bookmark.destroy({ where: { userId: user.id } });
            await DailyStreak.destroy({ where: { userId: user.id } });
            await UserAchievement.destroy({ where: { userId: user.id } });
            await UserMockExam.destroy({ where: { userId: user.id } });
            await UserSpecialty.destroy({ where: { userId: user.id } });
            await user.destroy();
        }

        console.log('👤 Creating Test User (test@medqbank.com | Test@123)...');
        user = await User.create({
            fullName: 'Test Doctor',
            email,
            password: 'Test@123',
            phone: '+966500000000',
            role: 'user',
            referralCode: 'TEST1234'
        });

        console.log('🔗 Assigning Specialties...');
        const specialties = await Specialty.findAll({ limit: 4 });
        for (const sp of specialties) {
            await UserSpecialty.create({ userId: user.id, specialtyId: sp.id });
        }

        console.log('📅 Creating Study Plan...');
        const today = new Date();
        const examDate = new Date();
        examDate.setDate(today.getDate() + 45); // 45 days from now
        await StudyPlan.create({
            userId: user.id,
            examDate,
            dailyHours: 4,
            studyDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Saturday']
        });

        console.log('💳 Adding Premium Subscription...');
        let plan = await SubscriptionPlan.findOne({ where: { durationInDays: 365 } });
        if (!plan) plan = await SubscriptionPlan.findOne(); // grab any

        if (plan) {
            const endDate = new Date();
            endDate.setFullYear(today.getFullYear() + 1);
            await Subscription.create({
                userId: user.id,
                planId: plan.id,
                status: 'active',
                startDate: today,
                endDate
            });
        }

        console.log('🔥 Setting up Streaks...');
        const yesterday = new Date();
        yesterday.setDate(today.getDate() - 1);
        await DailyStreak.create({
            userId: user.id,
            currentStreak: 12,
            longestStreak: 25,
            lastActivityDate: yesterday
        });

        console.log('📊 Generatings Stats (Question Attempts)...');
        const questions = await Question.findAll({ limit: 150 }); // Grab up to 150 questions
        if (questions.length > 0) {
            const attempts = [];
            let i = 0;
            for (const q of questions) {
                // Determine knowledge level for realistic masteries
                // 50% Green (Correct, low time), 30% Yellow (Correct but long, or wrong once then correct), 20% Red (Incorrect)
                const isCorrect = i % 10 < 7; // 70% correct overall
                const timeTaken = isCorrect ? Math.floor(Math.random() * 20) + 10 : Math.floor(Math.random() * 40) + 30; // Faster if correct

                const attemptDate = new Date();
                attemptDate.setDate(today.getDate() - Math.floor(Math.random() * 10)); // Over the last 10 days

                attempts.push({
                    userId: user.id,
                    questionId: q.id,
                    selectedOptionId: 1, // Dummy
                    isCorrect,
                    timeTaken,
                    createdAt: attemptDate,
                    updatedAt: attemptDate
                });

                // Occasionally boomark a question
                if (i % 15 === 0) {
                    await Bookmark.create({ userId: user.id, questionId: q.id });
                }
                i++;
            }
            await QuestionAttempt.bulkCreate(attempts);
        }

        console.log('🏆 Granting Achievements...');
        const achievements = await Achievement.findAll({ limit: 2 });
        if (achievements.length >= 1) await UserAchievement.create({ userId: user.id, achievementId: achievements[0].id });
        if (achievements.length >= 2) await UserAchievement.create({ userId: user.id, achievementId: achievements[1].id });

        console.log('📝 Simulating a Mock Exam...');
        const exam = await MockExam.findOne({ where: { isActive: true } });
        if (exam) {
            await UserMockExam.create({
                userId: user.id,
                mockExamId: exam.id,
                status: 'completed',
                score: 75,
                timeSpent: 3600, // 1 hour
                startedAt: yesterday,
                completedAt: new Date(yesterday.getTime() + 3600000)
            });
        }

        console.log('\n✅ TEST ACCOUNT FULLY SEEDED!');
        console.log('📧 Email: test@medqbank.com');
        console.log('🔑 Password: Test@123\n');
        process.exit(0);

    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedTester();
