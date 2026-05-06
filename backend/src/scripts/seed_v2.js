const { User, Specialty, Question, Option, Explanation, QuestionAttempt, sequelize } = require('../models');
const { Op } = require('sequelize');

const seedV2 = async () => {
    try {
        await sequelize.authenticate();
        console.log('✅ DB Connected');

        // 1. Force Update Emojis (Again)
        const emojiUpdates = [
            { name: 'Orthodontics', icon: '😬' },
            { name: 'Endodontics', icon: '⚡' },
            { name: 'Prosthodontics', icon: '👑' },
            { name: 'Periodontics', icon: '👄' },
            { name: 'Pediatric Dentistry', icon: '👶' },
            { name: 'Restorative', icon: '🛠️' },
            { name: 'Dental Surgery', icon: '💉' },
            { name: 'Oral Medicine & Pathology', icon: '🔬' },
            { name: 'Dental Ethics', icon: '⚖️' },
        ];

        for (const update of emojiUpdates) {
            await Specialty.update(
                { icon: update.icon },
                { where: { name: update.name } }
            );
        }
        console.log('✅ Emojis forced updated');

        // 2. Get Test User
        const user = await User.findOne({ where: { email: 'student@test.com' } });
        if (!user) {
            console.error('❌ Test user not found. Run initial seed first.');
            process.exit(1);
        }

        // 3. Create Dummy Questions (if not enough exist)
        const specialties = await Specialty.findAll();
        let questionCount = await Question.count();

        if (questionCount < 20) {
            console.log('📝 Creating dummy questions...');
            const dummyQuestions = [
                {
                    text: 'What is the primary cause of dental caries?',
                    specialty: 'Restorative',
                    options: ['Bacteria (S. mutans)', 'Virus', 'Fungus', 'Genetics'],
                    correct: 0,
                    explanation: 'Streptococcus mutans creates acid that demineralizes enamel.'
                },
                {
                    text: 'Which tooth is known as the "cornerstone" of the dental arch?',
                    specialty: 'Orthodontics',
                    options: ['Canine', 'Central Incisor', 'First Molar', 'Premolar'],
                    correct: 0,
                    explanation: 'The canine is the longest and most stable tooth.'
                },
                {
                    text: 'Best storage medium for an avulsed tooth?',
                    specialty: 'Dental Surgery',
                    options: ['Milk (HBSS)', 'Water', 'Alcohol', 'Dry tissue'],
                    correct: 0,
                    explanation: 'Milk or HBSS maintains cell viability better than water.'
                },
                {
                    text: 'Characteristic feature of Gingivitis?',
                    specialty: 'Periodontics',
                    options: ['Bleeding on probing', 'Bone loss', 'Tooth mobility', 'Attachment loss'],
                    correct: 0,
                    explanation: 'Bleeding on probing is the hallmark sign of gingivitis.'
                },
                {
                    text: 'Identify the "Safest" local anesthetic for pregnant patients.',
                    specialty: 'Oral Medicine & Pathology',
                    options: ['Lidocaine', 'Articaine', 'Mepivacaine', 'Bupivacaine'],
                    correct: 0,
                    explanation: 'Lidocaine (Category B) is considered the safest.'
                }
            ];

            for (const q of dummyQuestions) {
                const sp = specialties.find(s => s.name.includes(q.specialty)) || specialties[0];
                const createdQ = await Question.create({
                    text: q.text,
                    specialtyId: sp.id,
                    difficulty: 'medium',
                    isActive: true
                });

                for (let i = 0; i < q.options.length; i++) {
                    await Option.create({
                        questionId: createdQ.id,
                        text: q.options[i],
                        isCorrect: i === q.correct,
                        order: String.fromCharCode(65 + i)
                    });
                }

                await Explanation.create({
                    questionId: createdQ.id,
                    text: q.explanation
                });
            }
            console.log('✅ Added 5 dummy questions');
            questionCount += 5;
        }

        // 4. Generate Historical Stats (QuestionAttempts)
        // Clear recent attempts to avoid duplicates if re-run
        // await QuestionAttempt.destroy({ where: { userId: user.id } }); 
        // Commented out destroy to accumulate data, or uncomment to reset stats.
        // Let's reset stats for a clean chart
        await QuestionAttempt.destroy({ where: { userId: user.id } });
        console.log('🧹 Cleared old stats');

        const allQuestions = await Question.findAll();
        const attemptsToCreate = [];
        const today = new Date();

        // Generate 50 attempts over the last 30 days
        for (let i = 0; i < 50; i++) {
            const randomDaysAgo = Math.floor(Math.random() * 30);
            const date = new Date();
            date.setDate(today.getDate() - randomDaysAgo);

            const randomQ = allQuestions[Math.floor(Math.random() * allQuestions.length)];
            const isCorrect = Math.random() > 0.4; // 60% success rate

            attemptsToCreate.push({
                userId: user.id,
                questionId: randomQ.id,
                selectedOptionId: 1, // Dummy ID, doesn't matter for stats
                isCorrect: isCorrect,
                timeTaken: Math.floor(Math.random() * 60) + 10,
                createdAt: date,
                updatedAt: date
            });
        }

        // Sort by date so they insert somewhat logically (optional)
        attemptsToCreate.sort((a, b) => a.createdAt - b.createdAt);

        await QuestionAttempt.bulkCreate(attemptsToCreate);
        console.log(`✅ Generated ${attemptsToCreate.length} historical practice attempts for stats.`);

        console.log('\n🎉 === DATA SEEDED SUCCESSFULLY === 🎉');
        process.exit(0);
    } catch (error) {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    }
};

seedV2();
