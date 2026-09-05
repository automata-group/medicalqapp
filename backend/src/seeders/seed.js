/**
 * Database Seeder Script
 * Run: node src/seeders/seed.js
 * 
 * Seeds the database with initial test data for all modules:
 * - Admin user
 * - Specialties
 * - Questions + Options + Explanations
 * - Achievements
 * - Subscription Plans
 * - Mock Exams
 */

const sequelize = require('../config/database');
const models = require('../models');
const bcrypt = require('bcryptjs');

const {
    User, Specialty, Question, Option, Explanation,
    Achievement, SubscriptionPlan, MockExam, MockExamSection, SectionQuestion
} = models;

const seed = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ DB Connected');

        // Nuclear reset: Drop entire database and recreate to remove ALL ghost FK constraints
        const dbName = sequelize.config.database;
        await sequelize.query(`DROP DATABASE IF EXISTS \`${dbName}\``);
        await sequelize.query(`CREATE DATABASE \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
        await sequelize.query(`USE \`${dbName}\``);
        console.log('✅ Database reset');

        // Now sync all Sequelize models (creates fresh tables)
        await sequelize.sync({ force: true });
        console.log('✅ Tables created');

        // ========== 1. ADMIN USER ==========
        const admin = await User.create({
            fullName: 'Admin',
            email: 'admin@medqbank.com',
            password: 'Admin@123',
            role: 'admin',
            isVerified: true
        });
        console.log('✅ Admin user created (admin@medqbank.com / Admin@123)');

        // ========== 2. TEST USER ==========
        const testUser = await User.create({
            fullName: 'طالب تجريبي',
            email: 'student@test.com',
            password: 'Test@123',
            role: 'user',
            isVerified: true
        });
        console.log('✅ Test user created (student@test.com / Test@123)');

        // ========== 3. SPECIALTIES ==========
        const specialties = await Specialty.bulkCreate([
            // Dental Specialties (User Requested)
            { name: 'Orthodontics', nameAr: 'تقويم الأسنان', icon: '😬', sortOrder: 1, isActive: true },
            { name: 'Endodontics', nameAr: 'علاج الجذور', icon: '⚡', sortOrder: 2, isActive: true },
            { name: 'Prosthodontics', nameAr: 'الاستعاضة السنية', icon: '👑', sortOrder: 3, isActive: true },
            { name: 'Periodontics', nameAr: 'أمراض اللثة', icon: '👄', sortOrder: 4, isActive: true },
            { name: 'Pediatric Dentistry', nameAr: 'طب أسنان الأطفال', icon: '👶', sortOrder: 5, isActive: true },
            { name: 'Restorative', nameAr: 'العلاج التحفظي', icon: '🛠️', sortOrder: 6, isActive: true },
            { name: 'Oral Surgery', nameAr: 'جراحة الفم والوجه والفكين', icon: '💉', sortOrder: 7, isActive: true },
            { name: 'Oral Medicine & Pathology', nameAr: 'طب وأمراض الفم', icon: '🔬', sortOrder: 8, isActive: true },
            { name: 'Dental Ethics', nameAr: 'أخلاقيات طب الأسنان', icon: '⚖️', sortOrder: 9, isActive: true },
            { name: 'Sterilization and Infection Control', nameAr: 'التعقيم ومكافحة العدوى', icon: '🧼', sortOrder: 10, isActive: true },
        ]);
        console.log(`✅ ${specialties.length} dental specialties created`);

        // ========== 4. QUESTIONS ==========
        // Sample questions for dental specialties
        const questionsData = [
            // Orthodontics
            {
                text: 'Which classification is used for malocclusion?',
                specialtyId: specialties[0].id, // Orthodontics
                subTopic: 'Classification',
                difficulty: 'easy',
                options: [
                    { text: 'Angle classification', isCorrect: true },
                    { text: 'Black classification', isCorrect: false },
                    { text: 'Kennedy classification', isCorrect: false },
                    { text: 'Pell and Gregory', isCorrect: false },
                ],
                explanation: 'Angle classification is the most common system used to classify malocclusion.'
            },

            // Endodontics
            {
                text: 'What is the most common cause of endodontic failure?',
                specialtyId: specialties[1].id, // Endodontics
                subTopic: 'Failures',
                difficulty: 'medium',
                options: [
                    { text: 'Incomplete obturation', isCorrect: true },
                    { text: 'Perforation', isCorrect: false },
                    { text: 'Instrument separation', isCorrect: false },
                    { text: 'Over-filling', isCorrect: false },
                ],
                explanation: 'Incomplete obturation allowing bacterial leakage is a primary cause of failure.'
            },
            {
                text: 'Which material is used for obturation?',
                specialtyId: specialties[1].id, // Endodontics
                subTopic: 'Obturation',
                difficulty: 'easy',
                options: [
                    { text: 'Gutta Percha', isCorrect: true },
                    { text: 'Amalgam', isCorrect: false },
                    { text: 'Composite', isCorrect: false },
                    { text: 'Zirconia', isCorrect: false },
                ],
                explanation: 'Gutta Percha is the standard material for canal obturation.'
            },

            // Prosthodontics
            {
                text: 'Which material is best for anterior crown aesthetics?',
                specialtyId: specialties[2].id, // Prosthodontics
                subTopic: 'Crowns',
                difficulty: 'medium',
                options: [
                    { text: 'Lithium Disilicate (E.max)', isCorrect: true },
                    { text: 'Gold Alloy', isCorrect: false },
                    { text: 'Amalgam', isCorrect: false },
                    { text: 'Stainless Steel', isCorrect: false },
                ],
                explanation: 'Lithium disilicate offers superior translucency and aesthetics for anterior restorations.'
            },

            // Periodontics
            {
                text: 'Which bacteria are primarily associated with Aggressive Periodontitis?',
                specialtyId: specialties[3].id, // Periodontics
                subTopic: 'Microbiology',
                difficulty: 'hard',
                options: [
                    { text: 'Aggregatibacter actinomycetemcomitans', isCorrect: true },
                    { text: 'Streptococcus mutans', isCorrect: false },
                    { text: 'Lactobacillus acidophilus', isCorrect: false },
                    { text: 'Pseudomonas aeruginosa', isCorrect: false },
                ],
                explanation: 'A. actinomycetemcomitans is a key pathogen in aggressive periodontitis.'
            },

            // Pediatric Dentistry
            {
                text: 'When should the first dental visit occur?',
                specialtyId: specialties[4].id, // Pediatric Dentistry
                subTopic: 'Prevention',
                difficulty: 'easy',
                options: [
                    { text: 'By age 1 or within 6 months of first tooth eruption', isCorrect: true },
                    { text: 'At age 3', isCorrect: false },
                    { text: 'When all primary teeth erupt', isCorrect: false },
                    { text: 'Only if there is pain', isCorrect: false },
                ],
                explanation: 'Early visits help prevent nursing bottle caries and establish a dental home.'
            },

            // Dental Surgery
            {
                text: 'What is the most common complication after third molar extraction?',
                specialtyId: specialties[6].id, // Dental Surgery
                subTopic: 'Complications',
                difficulty: 'medium',
                options: [
                    { text: 'Alveolar Osteitis (Dry Socket)', isCorrect: true },
                    { text: 'Mandibular fracture', isCorrect: false },
                    { text: 'Nerve paresthesia', isCorrect: false },
                    { text: 'Severe hemorrhage', isCorrect: false },
                ],
                explanation: 'Dry socket occurs when the blood clot dislodges or dissolves prematurely.'
            }
        ];

        for (const qData of questionsData) {
            const question = await Question.create({
                text: qData.text,
                specialtyId: qData.specialtyId,
                subTopic: qData.subTopic,
                difficulty: qData.difficulty,
                isActive: true
            });

            for (let i = 0; i < qData.options.length; i++) {
                await Option.create({
                    questionId: question.id,
                    text: qData.options[i].text,
                    isCorrect: qData.options[i].isCorrect,
                    order: String.fromCharCode(65 + i) // A, B, C, D
                });
            }

            await Explanation.create({
                questionId: question.id,
                text: qData.explanation
            });
        }
        console.log(`✅ ${questionsData.length} questions with options & explanations created`);

        // ========== 5. ACHIEVEMENTS ==========
        await Achievement.bulkCreate([
            { name: 'First Step', slug: 'first_step', description: 'Answer your first question', icon: '🎯', criteriaType: 'questions_solved', criteriaValue: 1, xpReward: 10 },
            { name: 'Getting Started', slug: 'getting_started', description: 'Answer 10 questions', icon: '🚀', criteriaType: 'questions_solved', criteriaValue: 10, xpReward: 50 },
            { name: 'Perfect Score', slug: 'perfect_score', description: 'Get 100% on a mock exam', icon: '🏆', criteriaType: 'mock_score', criteriaValue: 100, xpReward: 200 },
            { name: 'Week Warrior', slug: 'week_warrior', description: '7-day streak', icon: '🔥', criteriaType: 'streak_days', criteriaValue: 7, xpReward: 100 },
        ]);
        console.log('✅ 4 achievements created');

        // ========== 6. SUBSCRIPTION PLANS ==========
        await SubscriptionPlan.bulkCreate([
            { name: 'Free', slug: 'free', description: 'Limited access', price: 0, currency: 'SAR', durationInDays: 365, features: ['10 questions/day', 'Basic stats'], isActive: true },
            { name: '1 Month', slug: '1-month', description: 'Full access for 1 month', price: 149.00, currency: 'SAR', durationInDays: 30, features: ['Unlimited questions', 'Full stats', 'Mock exams', 'AI explanations'], isActive: true },
            { name: '3 Months', slug: '3-months', description: 'Full access for 3 months', price: 399.00, currency: 'SAR', durationInDays: 90, features: ['Unlimited questions', 'Full stats', 'Mock exams', 'AI explanations'], isActive: true },
            { name: '6 Months', slug: '6-months', description: 'Full access for 6 months', price: 749.00, currency: 'SAR', durationInDays: 180, features: ['Unlimited questions', 'Full stats', 'Mock exams', 'AI explanations'], isActive: true },
            { name: '12 Months', slug: '12-months', description: 'Full access for 1 year', price: 1299.00, currency: 'SAR', durationInDays: 365, features: ['Unlimited questions', 'Full stats', 'Mock exams', 'AI explanations', 'Priority support'], isActive: true },
        ]);
        console.log('✅ 3 subscription plans created');

        // ========== 7. MOCK EXAM ==========
        const mockExam = await MockExam.create({
            title: 'SLE Practice Exam 1 (Free)',
            description: 'Free practice exam for Saudi License Examination',
            totalQuestions: 5,
            duration: 60,
            isPremium: false,
            price: 0,
            isActive: true
        });

        const premiumExam = await MockExam.create({
            title: 'Full SLE Premium Exam',
            description: 'Complete simulation with advanced questions',
            totalQuestions: 10,
            duration: 120,
            isPremium: true,
            price: 0.00,
            isActive: true
        });

        const section = await MockExamSection.create({
            mockExamId: mockExam.id,
            title: 'General Medicine',
            questionCount: 5,
            timeLimit: 60,
            sortOrder: 1
        });

        const premiumSection = await MockExamSection.create({
            mockExamId: premiumExam.id,
            title: 'Advanced Medicine',
            questionCount: 10,
            timeLimit: 120,
            sortOrder: 1
        });
        console.log('✅ 1 Free & 1 Premium mock exam created');

        // Link questions to section
        const allQuestions = await Question.findAll();
        for (let i = 0; i < allQuestions.length; i++) {
            // Link to Free Exam Section
            if (i < 5) {
                await SectionQuestion.create({
                    sectionId: section.id,
                    questionId: allQuestions[i].id,
                    sortOrder: i + 1
                });
            }

            // Link All to Premium Exam Section
            await SectionQuestion.create({
                sectionId: premiumSection.id,
                questionId: allQuestions[i].id,
                sortOrder: i + 1
            });
        }
        console.log('✅ Questions linked to mock exam sections');

        // ========== DONE ==========
        console.log('\n🎉 === DATABASE SEEDED SUCCESSFULLY === 🎉');
        console.log('\n📋 Test Credentials:');
        console.log('   Admin: admin@medqbank.com / Admin@123');
        console.log('   User:  student@test.com / Test@123');
        console.log('');

        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seed();
