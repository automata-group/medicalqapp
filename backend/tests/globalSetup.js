/**
 * Jest Global Setup
 * Runs once before all test suites.
 * Creates the test database and seeds it with test data.
 */
const path = require('path');
const dotenv = require('dotenv');
const { Sequelize } = require('sequelize');

// Load test environment BEFORE anything else
dotenv.config({ path: path.join(__dirname, '..', '.env.test'), override: true });

module.exports = async () => {
    // Step 1: Connect WITHOUT a database to create it first
    const rootSequelize = new Sequelize('', process.env.DB_USER, process.env.DB_PASS || null, {
        host: process.env.DB_HOST,
        dialect: process.env.DB_DIALECT || 'mysql',
        logging: false
    });

    try {
        const dbName = process.env.DB_NAME;
        await rootSequelize.query(`DROP DATABASE IF EXISTS \`${dbName}\``);
        await rootSequelize.query(`CREATE DATABASE \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
        console.log(`\n✅ Test database "${dbName}" created`);
        await rootSequelize.close();
    } catch (error) {
        console.error('❌ Failed to create test database:', error.message);
        await rootSequelize.close();
        process.exit(1);
    }

    // Step 2: Now connect to the actual test DB and seed it
    const sequelize = require('../src/config/database');
    const models = require('../src/models');

    const {
        User, Specialty, Question, Option, Explanation,
        Achievement, SubscriptionPlan, MockExam, MockExamSection,
        SectionQuestion, Subscription, DiscountCode, Notification
    } = models;

    try {
        await sequelize.authenticate();
        console.log('✅ Connected to test DB');

        await sequelize.sync({ force: true });
        console.log('✅ Test tables created');

        // ========== SEED TEST DATA ==========

        // 1. Admin user
        await User.create({
            fullName: 'Admin',
            email: 'admin@medqbank.com',
            password: 'Admin@123',
            role: 'admin',
            isVerified: true
        });

        // 2. Test user
        const testUser = await User.create({
            fullName: 'طالب تجريبي',
            email: 'student@test.com',
            password: 'Test@123',
            role: 'user',
            isVerified: true
        });

        // 3. Specialties
        const specialties = await Specialty.bulkCreate([
            { name: 'Internal Medicine', nameAr: 'الباطنة', icon: '🫀', sortOrder: 1, isActive: true },
            { name: 'Surgery', nameAr: 'الجراحة', icon: '🔪', sortOrder: 2, isActive: true },
            { name: 'Pediatrics', nameAr: 'طب الأطفال', icon: '👶', sortOrder: 3, isActive: true },
            { name: 'Obstetrics & Gynecology', nameAr: 'النساء والولادة', icon: '🤰', sortOrder: 4, isActive: true },
            { name: 'Pharmacology', nameAr: 'علم الأدوية', icon: '💊', sortOrder: 5, isActive: true },
            { name: 'Anatomy', nameAr: 'التشريح', icon: '🦴', sortOrder: 6, isActive: true },
        ]);

        // 4. Questions
        const questionsData = [
            {
                text: 'What is the most common cause of community-acquired pneumonia?',
                specialtyId: specialties[0].id,
                difficulty: 'medium',
                options: [
                    { text: 'Streptococcus pneumoniae', isCorrect: true },
                    { text: 'Staphylococcus aureus', isCorrect: false },
                    { text: 'Haemophilus influenzae', isCorrect: false },
                    { text: 'Klebsiella pneumoniae', isCorrect: false },
                ],
                explanation: 'Streptococcus pneumoniae is the most common cause of CAP.'
            },
            {
                text: 'Which nerve is most commonly injured during thyroidectomy?',
                specialtyId: specialties[1].id,
                difficulty: 'hard',
                options: [
                    { text: 'Superior laryngeal nerve', isCorrect: false },
                    { text: 'Recurrent laryngeal nerve', isCorrect: true },
                    { text: 'Hypoglossal nerve', isCorrect: false },
                    { text: 'Vagus nerve', isCorrect: false },
                ],
                explanation: 'The recurrent laryngeal nerve is most commonly injured.'
            },
            {
                text: 'What is the most common congenital heart defect?',
                specialtyId: specialties[2].id,
                difficulty: 'easy',
                options: [
                    { text: 'ASD', isCorrect: false },
                    { text: 'VSD', isCorrect: true },
                    { text: 'PDA', isCorrect: false },
                    { text: 'Tetralogy of Fallot', isCorrect: false },
                ],
                explanation: 'VSD is the most common congenital heart defect.'
            },
            {
                text: 'Which drug is first-line for hypertension in pregnancy?',
                specialtyId: specialties[3].id,
                difficulty: 'medium',
                options: [
                    { text: 'Enalapril', isCorrect: false },
                    { text: 'Methyldopa', isCorrect: true },
                    { text: 'Losartan', isCorrect: false },
                    { text: 'Hydrochlorothiazide', isCorrect: false },
                ],
                explanation: 'Methyldopa is first-line for chronic hypertension in pregnancy.'
            },
            {
                text: 'Which antibiotic inhibits cell wall synthesis?',
                specialtyId: specialties[4].id,
                difficulty: 'easy',
                options: [
                    { text: 'Ciprofloxacin', isCorrect: false },
                    { text: 'Amoxicillin', isCorrect: true },
                    { text: 'Azithromycin', isCorrect: false },
                    { text: 'Doxycycline', isCorrect: false },
                ],
                explanation: 'Amoxicillin inhibits bacterial cell wall synthesis.'
            }
        ];

        for (const qData of questionsData) {
            const question = await Question.create({
                text: qData.text,
                specialtyId: qData.specialtyId,
                difficulty: qData.difficulty,
                isActive: true
            });

            for (let i = 0; i < qData.options.length; i++) {
                await Option.create({
                    questionId: question.id,
                    text: qData.options[i].text,
                    isCorrect: qData.options[i].isCorrect,
                    order: String.fromCharCode(65 + i)
                });
            }

            await Explanation.create({
                questionId: question.id,
                text: qData.explanation
            });
        }

        // 5. Achievements
        await Achievement.bulkCreate([
            { name: 'First Step', slug: 'first_step', description: 'Answer your first question', icon: '🎯', criteriaType: 'questions_solved', criteriaValue: 1, xpReward: 10 },
            { name: 'Getting Started', slug: 'getting_started', description: 'Answer 10 questions', icon: '🚀', criteriaType: 'questions_solved', criteriaValue: 10, xpReward: 50 },
        ]);

        // 6. Subscription Plans
        await SubscriptionPlan.bulkCreate([
            { name: 'Free', slug: 'free', description: 'Limited access', price: 0, currency: 'SAR', durationInDays: 365, features: ['10 questions/day'], isActive: true },
            { name: 'Monthly Pro', slug: 'monthly-pro', description: 'Full access', price: 49.99, currency: 'SAR', durationInDays: 30, features: ['Unlimited questions', 'Mock exams'], isActive: true },
            { name: 'Yearly Pro', slug: 'yearly-pro', description: 'Full access yearly', price: 399.99, currency: 'SAR', durationInDays: 365, features: ['Unlimited', 'Mock exams'], isActive: true },
        ]);

        // 7. Active subscription for test user
        const plans = await SubscriptionPlan.findAll();
        await Subscription.create({
            userId: testUser.id,
            planId: plans[1].id,
            startDate: new Date(),
            endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
            status: 'active'
        });

        // 8. Mock Exam
        const mockExam = await MockExam.create({
            title: 'SLE Practice Exam 1',
            description: 'Full practice exam',
            totalQuestions: 5,
            duration: 60,
            isPremium: false,
            isActive: true
        });

        const section = await MockExamSection.create({
            mockExamId: mockExam.id,
            title: 'General Medicine',
            questionCount: 5,
            timeLimit: 60,
            sortOrder: 1
        });

        const allQuestions = await Question.findAll();
        for (let i = 0; i < allQuestions.length; i++) {
            await SectionQuestion.create({
                sectionId: section.id,
                questionId: allQuestions[i].id,
                sortOrder: i + 1
            });
        }

        // 9. Discount Code
        await DiscountCode.create({
            code: 'TEST50',
            type: 'percentage',
            value: 50,
            maxUses: 100,
            usedCount: 0,
            isActive: true,
            expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
        });

        // 10. Notification
        await Notification.create({
            userId: testUser.id,
            title: 'Welcome!',
            message: 'Welcome to Medical QBank',
            type: 'system',
            isRead: false
        });

        console.log('✅ Test data seeded successfully\n');
        await sequelize.close();
    } catch (error) {
        console.error('❌ Test seeding failed:', error);
        await sequelize.close();
        process.exit(1);
    }
};
