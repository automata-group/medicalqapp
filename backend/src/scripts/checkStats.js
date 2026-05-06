const { User, Question, QuestionAttempt, sequelize } = require('../models');

const seedAllUsers = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ DB Connected');

        const users = await User.findAll();
        const allQuestions = await Question.findAll();

        if (allQuestions.length === 0) {
            console.error('❌ No questions found. Run seed_v2 first.');
            process.exit(1);
        }

        console.log(`\n--- Seeding ${users.length} Users ---`);

        for (const user of users) {
            // Check if user already has significant attempts
            const currentAttempts = await QuestionAttempt.count({ where: { userId: user.id } });
            if (currentAttempts > 10) {
                console.log(`Skipping ${user.email} (Already has ${currentAttempts} attempts)`);
                continue;
            }

            const attemptsToCreate = [];
            const today = new Date();

            // Generate 30-50 attempts per user
            const count = 30 + Math.floor(Math.random() * 20);

            for (let i = 0; i < count; i++) {
                const randomDaysAgo = Math.floor(Math.random() * 30);
                const date = new Date();
                date.setDate(today.getDate() - randomDaysAgo);

                const randomQ = allQuestions[Math.floor(Math.random() * allQuestions.length)];
                const isCorrect = Math.random() > 0.4; // 60% success rate

                attemptsToCreate.push({
                    userId: user.id,
                    questionId: randomQ.id,
                    selectedOptionId: 1,
                    isCorrect: isCorrect,
                    timeTaken: Math.floor(Math.random() * 60) + 10,
                    createdAt: date,
                    updatedAt: date
                });
            }

            await QuestionAttempt.bulkCreate(attemptsToCreate);
            console.log(`✅ Seeded ${count} attempts for ${user.email}`);
        }

        console.log('\n🎉 Users seeded successfully!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedAllUsers();
