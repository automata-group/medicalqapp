require('dotenv').config();
const { Worker } = require('bullmq');
const aiService = require('./services/aiService');
const { Question, Option, Explanation, Specialty, Topic, sequelize } = require('./models');

// Configure Redis Connection from Docker Internal Net
const connection = {
    host: process.env.REDIS_HOST || '127.0.0.1',
    port: process.env.REDIS_PORT || 6379,
    maxRetriesPerRequest: null // BullMQ requires this
};

async function processDocxJob(job) {
    const { textChunk, chunkIndex, totalChunks, specialtyName, topicName, isAutoDetect } = job.data;
    
    const existingSpecialties = await Specialty.findAll({
        include: [{ model: Topic, as: 'topics', attributes: ['name'] }]
    });

    // Fetch Existing Questions for AI Context
    let existingQuestionsQuery = { attributes: ['text'], order: [['createdAt', 'DESC']], limit: 100 };
    if (!isAutoDetect && specialtyName) {
        existingQuestionsQuery.where = { specialtyId: specialtyName };
    }
    const recentQuestions = await Question.findAll(existingQuestionsQuery);
    const existingQuestionTexts = recentQuestions.map(q => q.text);

    const aiContext = {
        existingSpecialties,
        existingQuestionTexts,
        maxQuestions: 100 // Safe upper bound for 6000 character chunks
    };

    let detectedSpecialtyName = specialtyName;
    let detectedTopicName = topicName;

    // Report starting processing this slice
    await job.updateProgress({
        type: 'progress',
        percent: Math.round(((chunkIndex) / totalChunks) * 100),
        message: `Worker node spinning up slice ${chunkIndex + 1}/${totalChunks}...`
    });

    try {
        // Parse AI
        const aiResult = await aiService.parseDocxQuestions(textChunk, 'auto', 'auto', aiContext);

        if (aiResult.success && aiResult.data && Array.isArray(aiResult.data.questions)) {
            const extracted = aiResult.data.questions;
            if (extracted.length === 0) return { saved: 0, skipped: 0, detectedTopicName };

            let currentSpecialty = null;
            let currentTopic = null;

            let chunkSaved = 0;
            let chunkSkipped = 0;
            await sequelize.transaction(async (t) => {
                for (const qData of extracted) {
                    if (!qData.questionText || qData.isDuplicate) {
                        chunkSkipped++;
                        continue; // Honor AI deduplication marking
                    }

                    // Dynamic per-question topic resolution according to new AI structure
                    let localDetectedSpecialty = (qData.detectedSpecialty || detectedSpecialtyName).trim();
                    let localDetectedTopic = (qData.detectedTopic || detectedTopicName).trim();

                    console.log(`[Worker] --- Atomic Question Processing Start ---`);
                    console.log(`[Worker] Question: "${qData.questionText.substring(0, 50)}..."`);
                    console.log(`[Worker] AI Reasoning: ${qData.reasoning_and_analysis ? qData.reasoning_and_analysis.substring(0, 500) : 'No reasoning provided'}`);
                    console.log(`[Worker] Taxonomy Detection: Specialty="${localDetectedSpecialty}" | Topic="${localDetectedTopic}"`);

                    if (isAutoDetect || qData.mappedToExistingSystemCategory === true || qData.mappedToExistingSystemCategory === 'true') {
                        const foundSp = await Specialty.findOne({ 
                            where: sequelize.where(sequelize.fn('LOWER', sequelize.col('name')), localDetectedSpecialty.toLowerCase()),
                            transaction: t 
                        });

                        if (foundSp) {
                            currentSpecialty = foundSp;
                            console.log(`   -> Found Specialty: ${currentSpecialty.name}`);
                        } else {
                            const [dbSp] = await Specialty.findOrCreate({
                                where: { name: localDetectedSpecialty.substring(0, 50) || 'General Medicine' },
                                defaults: { description: 'Auto-detected specialty' },
                                transaction: t
                            });
                            currentSpecialty = dbSp;
                            console.log(`   -> Created/Using Specialty: ${currentSpecialty.name}`);
                        }

                        const foundTopic = await Topic.findOne({ 
                            where: { 
                                specialtyId: currentSpecialty.id,
                                name: sequelize.where(sequelize.fn('LOWER', sequelize.col('name')), localDetectedTopic.toLowerCase())
                            }, 
                            transaction: t 
                        });

                        if (foundTopic) {
                            currentTopic = foundTopic;
                            console.log(`   -> Found Topic: ${currentTopic.name}`);
                        } else {
                            const [dbTop] = await Topic.findOrCreate({
                                where: { 
                                    name: localDetectedTopic.substring(0, 50) || 'General', 
                                    specialtyId: currentSpecialty.id 
                                },
                                defaults: { description: 'Auto-detected topic' },
                                transaction: t
                            });
                            currentTopic = dbTop;
                            console.log(`   -> Created/Using Topic: ${currentTopic.name} in Specialty ${currentSpecialty.name}`);
                        }
                    } else if (!currentSpecialty) {
                        currentSpecialty = await Specialty.findByPk(specialtyName);
                        currentTopic = await Topic.findByPk(topicName);
                        console.log(`   -> Fallback to Default: ${currentSpecialty?.name || 'Error'} / ${currentTopic?.name || 'Error'}`);
                    }

                    if (!currentSpecialty || !currentTopic) {
                        console.error('   -> FAILED to resolve category/topic. Skipping.');
                        continue;
                    }

                    const duplicate = await Question.findOne({
                        where: { text: qData.questionText },
                        attributes: ['id'],
                        transaction: t
                    });
                    if (duplicate) {
                        chunkSkipped++;
                        continue;
                    }

                    const question = await Question.create({
                        text: qData.questionText,
                        specialtyId: currentSpecialty.id,
                        topicId: currentTopic.id,
                        difficulty: qData.difficulty || 'medium',
                        timeEstimate: 60,
                        isPremium: (qData.points && qData.points >= 3),
                        isActive: true,
                        verifiedByAI: true,
                        source: 'DOCX Import'
                    }, { transaction: t });

                    const aiOptions = qData.options || [];
                    if (aiOptions.length > 0) {
                        await Option.bulkCreate(
                            aiOptions.map((opt, index) => {
                                // Ensure order is an integer. If AI returns 'A', 'B', etc., map to 1, 2, 3...
                                let orderValue = parseInt(opt.order);
                                if (isNaN(orderValue)) {
                                    const orderMap = { 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5 };
                                    orderValue = orderMap[String(opt.order).toUpperCase()] || (index + 1);
                                }
                                return {
                                    questionId: question.id,
                                    text: opt.text,
                                    order: orderValue,
                                    isCorrect: opt.isCorrect
                                };
                            }),
                            { transaction: t }
                        );
                    }

                    await Explanation.create({
                        questionId: question.id,
                        text: qData.explanation || 'No explanation provided.',
                        whyWrong: {},
                        references: qData.references || `${currentSpecialty.name} / ${currentTopic.name} — DOCX Import`,
                        aiGenerated: true
                    }, { transaction: t });

                    chunkSaved++;
                }
            });

            return { saved: chunkSaved, skipped: chunkSkipped, detectedTopicName };
        }
        return { saved: 0, skipped: 0, detectedTopicName };
    } catch (err) {
        console.error(`[Worker] Slice ${chunkIndex} failed:`, err);
        throw err;
    }
}

// Boot Sequence
async function startWorker() {
    try {
        await sequelize.authenticate();
        console.log('[AI Worker] Database Connection Established.');
        
        const worker = new Worker('docx-extraction', processDocxJob, { 
            connection,
            concurrency: 4 // Native parallel slicing paths
        });
        
        worker.on('completed', job => {
            console.log(`[AI Worker] Job with id ${job.id} has been completed.`);
        });
        
        worker.on('failed', (job, err) => {
            console.error(`[AI Worker] Job with id ${job.id} has failed with ${err.message}`);
        });

        console.log('[AI Worker] BullMQ Engine is listening for extraction jobs...');
    } catch (err) {
        console.error('[AI Worker] Boot failure:', err);
        process.exit(1);
    }
}

startWorker();
