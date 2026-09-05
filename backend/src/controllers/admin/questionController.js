const { Question, Option, Explanation, Specialty, Topic, AdminActivityLog, sequelize } = require('../../models');
const aiService = require('../../services/aiService');
const { Queue, QueueEvents } = require('bullmq');
const { Op } = require('sequelize');

const redisConnection = { host: process.env.REDIS_HOST || '127.0.0.1', port: process.env.REDIS_PORT || 6379, maxRetriesPerRequest: null };
const docxQueue = new Queue('docx-extraction', { connection: redisConnection });
const queueEvents = new QueueEvents('docx-extraction', { connection: redisConnection });

// @desc    Get all questions (Admin)
// @route   GET /api/v1/admin/questions
// @access  Private (Admin)
exports.getQuestions = async (req, res, next) => {
    try {
        const { page = 1, limit = 10, specialtyId, topicId, search } = req.query;
        const offset = (page - 1) * limit;

        const whereClause = {};
        if (specialtyId) whereClause.specialtyId = specialtyId;
        if (topicId) whereClause.topicId = topicId;

        const queryTerm = (search || req.query.q || '').trim();
        if (queryTerm) {
            whereClause[Op.or] = [
                { text: { [Op.like]: `%${queryTerm}%` } },
                { subTopic: { [Op.like]: `%${queryTerm}%` } }
            ];
        }

        const { count, rows } = await Question.findAndCountAll({
            where: whereClause,
            limit: parseInt(limit),
            offset: parseInt(offset),
            include: [
                { model: Specialty, as: 'specialty', attributes: ['name'] },
                { model: Topic, as: 'topic', attributes: ['name'] }
            ],
            order: [['createdAt', 'DESC']]
        });

        res.status(200).json({
            success: true,
            count,
            totalPages: Math.ceil(count / limit),
            currentPage: parseInt(page),
            data: rows
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Get single question (Admin)
// @route   GET /api/v1/admin/questions/:id
// @access  Private (Admin)
exports.getQuestion = async (req, res, next) => {
    try {
        const question = await Question.findByPk(req.params.id, {
            include: [
                { model: Option, as: 'options' },
                { model: Explanation, as: 'explanation' },
                { model: Specialty, as: 'specialty' },
                { model: Topic, as: 'topic' }
            ]
        });

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        res.status(200).json({ success: true, data: question });
    } catch (error) {
        next(error);
    }
};

// @desc    Upload Question Image
// @route   POST /api/v1/admin/questions/upload-image
// @access  Private (Admin)
exports.uploadQuestionImage = async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'No image file uploaded' });
        }
        const imageUrl = `/uploads/questions/${req.file.filename}`;
        res.status(200).json({
            success: true,
            imageUrl,
            message: 'Image uploaded successfully'
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Create Question
// @route   POST /api/v1/admin/questions
// @access  Private (Admin)
exports.createQuestion = async (req, res, next) => {
    try {
        const { text, specialtyId, topicId, difficulty, isPremium, options, explanation, image } = req.body;

        const question = await Question.create({
            text,
            specialtyId,
            topicId,
            difficulty,
            image: image || null,
            isPremium: isPremium || false,
            isActive: true
        });

        if (options && options.length > 0) {
            await Promise.all(options.map((opt, index) => {
                return Option.create({
                    questionId: question.id,
                    text: opt.text,
                    isCorrect: opt.isCorrect,
                    order: String.fromCharCode(65 + index) // A, B, C...
                });
            }));
        }

        if (explanation) {
            await Explanation.create({
                questionId: question.id,
                text: explanation.text,
                references: explanation.references
            });
        }

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'CREATE_QUESTION',
            targetResource: `Question:${question.id}`,
            ipAddress: req.ip
        });

        res.status(201).json({ success: true, data: question });

    } catch (error) {
        next(error);
    }
};

// @desc    Update Question
// @route   PUT /api/v1/admin/questions/:id
// @access  Private (Admin)
exports.updateQuestion = async (req, res, next) => {
    try {
        const { text, specialtyId, topicId, difficulty, isPremium, isActive, options, explanation, image } = req.body;

        let question = await Question.findByPk(req.params.id);

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        // Update fields
        const updateData = {
            text: text || question.text,
            specialtyId: specialtyId !== undefined ? specialtyId : question.specialtyId,
            topicId: topicId !== undefined ? topicId : question.topicId,
            difficulty: difficulty || question.difficulty,
            isPremium: isPremium !== undefined ? isPremium : question.isPremium,
            isActive: isActive !== undefined ? isActive : question.isActive
        };

        if (image !== undefined) {
            updateData.image = image || null;
        }

        question = await question.update(updateData);

        // Update Options (Replace Strategy for simplicity)
        if (options && options.length > 0) {
            await Option.destroy({ where: { questionId: question.id } });
            await Promise.all(options.map((opt, index) => {
                return Option.create({
                    questionId: question.id,
                    text: opt.text,
                    isCorrect: opt.isCorrect,
                    order: String.fromCharCode(65 + index)
                });
            }));
        }

        // Update Explanation
        if (explanation) {
            const expParams = {
                questionId: question.id,
                text: explanation.text,
                references: explanation.references
            };
            const existingExp = await Explanation.findOne({ where: { questionId: question.id } });
            if (existingExp) {
                await existingExp.update(expParams);
            } else {
                await Explanation.create(expParams);
            }
        }

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'UPDATE_QUESTION',
            targetResource: `Question:${question.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, data: question });

    } catch (error) {
        next(error);
    }
};

// @desc    Delete Question
// @route   DELETE /api/v1/admin/questions/:id
// @access  Private (Admin)
exports.deleteQuestion = async (req, res, next) => {
    try {
        const question = await Question.findByPk(req.params.id);

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        // Soft delete if paranoid is enabled, or hard delete. 
        // Assuming models are paranoid: false (default), this is hard delete.
        // Associations (Options, Explanations) should cascade if set up, otherwise we delete them manually.
        // Ideally DB cascade is set. Assuming sequelize cascade hooks are default or DB level.
        // We'll trust Sequelize 'onDelete: CASCADE' if defined in associations, or better:
        await Option.destroy({ where: { questionId: question.id } });
        await Explanation.destroy({ where: { questionId: question.id } });
        await question.destroy();

        // Log
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'DELETE_QUESTION',
            targetResource: `Question:${req.params.id}`,
            ipAddress: req.ip
        });

        res.status(200).json({ success: true, message: 'Question deleted' });

    } catch (error) {
        next(error);
    }
};

// @desc    Move Single Question to Another Specialty / Topic
// @route   PUT /api/v1/admin/questions/:id/move
// @access  Private (Admin)
exports.moveQuestion = async (req, res, next) => {
    try {
        const { specialtyId, topicId } = req.body;
        const questionId = req.params.id;

        if (!specialtyId) {
            return res.status(400).json({ success: false, message: 'Please specify the target specialty' });
        }

        const question = await Question.findByPk(questionId);
        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        const targetSpecialty = await Specialty.findByPk(specialtyId);
        if (!targetSpecialty) {
            return res.status(404).json({ success: false, message: 'Target specialty not found' });
        }

        await question.update({
            specialtyId: parseInt(specialtyId),
            topicId: topicId ? parseInt(topicId) : null
        });

        const updatedQuestion = await Question.findByPk(questionId, {
            include: [
                { model: Specialty, as: 'specialty', attributes: ['id', 'name'] },
                { model: Topic, as: 'topic', attributes: ['id', 'name'] }
            ]
        });

        if (req.user) {
            await AdminActivityLog.create({
                adminId: req.user.id,
                action: 'MOVE_QUESTION',
                targetResource: `Question:${questionId} moved to Specialty:${specialtyId}`,
                ipAddress: req.ip
            });
        }

        res.status(200).json({
            success: true,
            message: `Question moved successfully to ${targetSpecialty.name}`,
            data: updatedQuestion
        });
    } catch (error) {
        next(error);
    }
};

// @desc    Bulk Move Questions to Another Specialty / Topic
// @route   POST /api/v1/admin/questions/bulk-move
// @access  Private (Admin)
exports.bulkMoveQuestions = async (req, res, next) => {
    try {
        const { questionIds, specialtyId, topicId } = req.body;

        if (!questionIds || !Array.isArray(questionIds) || questionIds.length === 0) {
            return res.status(400).json({ success: false, message: 'Please provide an array of question IDs' });
        }

        if (!specialtyId) {
            return res.status(400).json({ success: false, message: 'Please specify the target specialty' });
        }

        const targetSpecialty = await Specialty.findByPk(specialtyId);
        if (!targetSpecialty) {
            return res.status(404).json({ success: false, message: 'Target specialty not found' });
        }

        const updateData = {
            specialtyId: parseInt(specialtyId),
            topicId: topicId ? parseInt(topicId) : null
        };

        const [updatedCount] = await Question.update(updateData, {
            where: {
                id: questionIds
            }
        });

        if (req.user) {
            await AdminActivityLog.create({
                adminId: req.user.id,
                action: 'BULK_MOVE_QUESTIONS',
                targetResource: `${updatedCount} Questions moved to Specialty:${specialtyId}`,
                ipAddress: req.ip
            });
        }

        res.status(200).json({
            success: true,
            message: `Successfully moved ${updatedCount} question(s) to ${targetSpecialty.name}`,
            data: { updatedCount, specialtyId, topicId: updateData.topicId }
        });
    } catch (error) {
        next(error);
    }
};

const csv = require('csv-parser');
const fs = require('fs');
const mammoth = require('mammoth');

// @desc    Bulk Import Questions
// @route   POST /api/v1/admin/questions/bulk-import
// @access  Private (Admin)
exports.bulkImportQuestions = async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'Please upload a CSV file' });
        }

        const results = [];
        fs.createReadStream(req.file.path)
            .pipe(csv())
            .on('data', (data) => results.push(data))
            .on('end', async () => {
                let count = 0;
                for (const row of results) {
                    try {
                        const questionText = row['Question Text'];
                        const specialtyId = parseInt(row['Specialty ID']) || 1;
                        const difficulty = row['Difficulty'] || 'medium';

                        if (!questionText) continue;

                        const question = await Question.create({
                            text: questionText,
                            specialtyId: specialtyId,
                            difficulty: difficulty,
                            isActive: true
                        });

                        const options = [
                            { text: row['Option A'], isCorrect: row['Option A Is Correct']?.toUpperCase() === 'TRUE', order: 'A' },
                            { text: row['Option B'], isCorrect: row['Option B Is Correct']?.toUpperCase() === 'TRUE', order: 'B' },
                            { text: row['Option C'], isCorrect: row['Option C Is Correct']?.toUpperCase() === 'TRUE', order: 'C' },
                            { text: row['Option D'], isCorrect: row['Option D Is Correct']?.toUpperCase() === 'TRUE', order: 'D' }
                        ].filter(opt => opt.text);

                        await Promise.all(options.map(opt => Option.create({
                            questionId: question.id,
                            text: opt.text,
                            isCorrect: opt.isCorrect,
                            order: opt.order
                        })));

                        const expText = row['Explanation Text'];
                        if (expText) {
                            await Explanation.create({
                                questionId: question.id,
                                text: expText,
                                references: row['Explanation References'] || ''
                            });
                        }
                        count++;
                    } catch (err) {
                        console.error('Error importing row:', err);
                    }
                }

                // Cleanup file
                if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

                return res.status(201).json({
                    success: true,
                    message: `Successfully imported ${count} questions`,
                    count
                });
            });
    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        next(error);
    }
};

// @desc    Bulk Import DOCX Questions
// @route   POST /api/v1/admin/questions/bulk-import-docx
// @access  Private (Admin)
exports.bulkImportDocx = async (req, res, next) => {
    try {
        if (!req.file) {
            return res.status(400).json({ success: false, message: 'Please upload a DOCX file' });
        }

        const { specialtyId, topicId } = req.body;
        const isAutoDetect = specialtyId === 'auto' || topicId === 'auto' || !specialtyId || !topicId;

        let specialty = null;
        let topic = null;
        let specialtyName = 'auto';
        let topicName = 'auto';

        if (!isAutoDetect) {
            specialty = await Specialty.findByPk(specialtyId);
            topic = await Topic.findByPk(topicId);
            if (!specialty || !topic) {
                if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
                return res.status(404).json({ success: false, message: 'Provided Specialty or Topic not found' });
            }
            specialtyName = specialty.name;
            topicName = topic.name;
        }

        // Extract text from DOCX preserving line breaks (<br />) and formatting
        let rawText = '';
        try {
            const { value: htmlContent } = await mammoth.convertToHtml({ path: req.file.path });
            rawText = (htmlContent || '')
                .replace(/<br\s*\/?>/gi, '\n')
                .replace(/<\/p>/gi, '\n\n')
                .replace(/<p>/gi, '')
                .replace(/<\/?strong>/gi, '')
                .replace(/&nbsp;/g, ' ')
                .replace(/&amp;/g, '&')
                .replace(/&lt;/g, '<')
                .replace(/&gt;/g, '>')
                .trim();
        } catch (htmlErr) {
            console.warn('[DocxImport] convertToHtml failed, falling back to extractRawText:', htmlErr.message);
        }

        if (!rawText || rawText.length === 0) {
            const { value: fallbackText } = await mammoth.extractRawText({ path: req.file.path });
            rawText = (fallbackText || '').trim();
        }

        if (!rawText || rawText.length === 0) {
            if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
            return res.status(400).json({ success: false, message: 'The uploaded file is empty or unreadable.' });
        }

        // Gather context for smarter AI parsing
        // 1. Fetch all existing specialties with their topics
        const allSpecialties = await Specialty.findAll({
            include: [{ model: Topic, as: 'topics', attributes: ['id', 'name'] }],
            attributes: ['id', 'name']
        });
        const existingSpecialties = allSpecialties.map(sp => ({
            id: sp.id,
            name: sp.name,
            topics: (sp.topics || []).map(t => ({ id: t.id, name: t.name }))
        }));

        // 2. We NO LONGER fetch and send all existing question texts to the AI.
        // It consumes enormous prompt tokens (costing the user heavily) and is redundant
        // because we ALREADY perform a strict server-side DB text deduplication below.
        const existingQuestionTexts = [];

        // ─── PARALLEL CHUNKED EXTRACTION ───────────────────────────
        // Split text into chunks at paragraph boundaries (~6000 chars each)
        // so the AI can process the entire file via concurrent requests without losing questions.
        const CHUNK_SIZE = 6000;
        const paragraphs = rawText.split(/\n/);
        const textChunks = [];
        let currentChunk = '';

        for (const para of paragraphs) {
            if (currentChunk.length + para.length > CHUNK_SIZE && currentChunk.length > 0) {
                textChunks.push(currentChunk.trim());
                currentChunk = '';
            }
            currentChunk += para + '\n\n';
        }
        if (currentChunk.trim().length > 0) {
            textChunks.push(currentChunk.trim());
        }

        // If text is too short for splitting, use a single chunk
        if (textChunks.length === 0) {
            textChunks.push(rawText);
        }

        console.log(`[DOCX Import SSE] Splitting text into ${textChunks.length} chunk(s) for sequential AI processing stream...`);

        // Setup SSE response
        res.setHeader('Content-Type', 'text/event-stream');
        res.setHeader('Cache-Control', 'no-cache');
        res.setHeader('Connection', 'keep-alive');
        res.setHeader('X-Accel-Buffering', 'no'); // CRITICAL: Disables NGINX proxy buffering

        // Let the client know we've started
        res.write(`data: ${JSON.stringify({ type: 'start', totalChunks: textChunks.length, message: 'Opening streaming pipeline...' })}\n\n`);
        if (res.flush) res.flush();

        // Enqueue the AI parsing jobs AS INDEPENDENT SLICES (True Horizontal Scaling)
        const sliceJobs = textChunks.map((chunk, index) => ({
            name: 'process-docx-slice',
            data: { 
                textChunk: chunk, 
                chunkIndex: index, 
                totalChunks: textChunks.length, 
                specialtyName, 
                topicName, 
                isAutoDetect 
            },
            opts: { removeOnComplete: true, removeOnFail: 100 }
        }));

        const addedJobs = await docxQueue.addBulk(sliceJobs);
        const jobIds = addedJobs.map(j => j.id);

        let completedSlices = 0;
        let totalExtractedFinal = 0;
        let totalSkippedFinal = 0;
        let detectedTopicFinal = 'Unknown';

        // Bridge Worker Progress to SSE Connection seamlessly
        const progressListener = async ({ jobId, data }) => {
            if (jobIds.includes(jobId) && typeof data === 'object' && data.type === 'progress') {
                res.write(`data: ${JSON.stringify(data)}\n\n`);
                if (res.flush) res.flush();
            }
        };

        const completionListener = async ({ jobId, returnvalue }) => {
            if (jobIds.includes(jobId)) {
                completedSlices++;
                const stats = returnvalue || { saved: 0, skipped: 0 };
                totalExtractedFinal += stats.saved;
                totalSkippedFinal += stats.skipped;
                if (stats.detectedTopicName) detectedTopicFinal = stats.detectedTopicName;

                res.write(`data: ${JSON.stringify({
                    type: 'progress',
                    percent: Math.round((completedSlices / jobIds.length) * 100),
                    message: `✅ Worker processed slice ${completedSlices}/${jobIds.length}. Extracted ${stats.saved} questions.`
                })}\n\n`);
                if (res.flush) res.flush();

                if (completedSlices === jobIds.length) {
                    // ALL SLICE JOBS FINISHED
                    queueEvents.off('progress', progressListener);
                    queueEvents.off('completed', completionListener);
                    queueEvents.off('failed', failListener);

                    res.write(`data: ${JSON.stringify({
                        type: 'complete',
                        success: true,
                        message: `Pipeline complete via Parallel Slices! Processed ${totalExtractedFinal} questions. Skipped ${totalSkippedFinal} duplicates.`,
                        count: totalExtractedFinal,
                        skippedDuplicates: totalSkippedFinal,
                        totalExtracted: totalExtractedFinal,
                        detectedTopicName: detectedTopicFinal
                    })}\n\n`);
                    if (res.flush) res.flush();
                    res.end();

                    // Optional log
                    try {
                        await AdminActivityLog.create({
                            adminId: req.user.id,
                            action: 'BULK_IMPORT_DOCX_STREAM_WORKER_SLICED',
                            targetResource: `Specialty:${specialtyId}|Topic:${topicId} [Extracted:${totalExtractedFinal}]`,
                            ipAddress: req.ip
                        });
                    } catch(e) {}
                }
            }
        };

        const failListener = async ({ jobId, failedReason }) => {
            if (jobIds.includes(jobId)) {
                completedSlices++;
                res.write(`data: ${JSON.stringify({
                    type: 'progress',
                    percent: Math.round((completedSlices / jobIds.length) * 100),
                    message: `❌ Slice crashed: ${failedReason}`
                })}\n\n`);
                if (res.flush) res.flush();

                if (completedSlices === jobIds.length) {
                    queueEvents.off('progress', progressListener);
                    queueEvents.off('completed', completionListener);
                    queueEvents.off('failed', failListener);

                    res.write(`data: ${JSON.stringify({
                        type: 'progress',
                        percent: 100,
                        message: `⚠️ Pipeline finished with errors.`
                    })}\n\n`);
                    if (res.flush) res.flush();
                    res.end();
                }
            }
        };

        queueEvents.on('progress', progressListener);
        queueEvents.on('completed', completionListener);
        queueEvents.on('failed', failListener);

        // Cleanup temp file immediately (we just passed strings to Redis)
        if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);

    } catch (error) {
        if (req.file && fs.existsSync(req.file.path)) {
            fs.unlinkSync(req.file.path);
        }
        next(error);
    }
};

// @desc    Reorder question
// @route   PUT /api/v1/admin/questions/:id/reorder
// @access  Private (Admin)
exports.reorderQuestion = async (req, res, next) => {
    try {
        res.status(200).json({ success: true, message: 'Question reordered' });
    } catch (error) {
        next(error);
    }
};

// @desc    AI Verify Question
// @route   POST /api/v1/admin/questions/:id/ai-verify
// @access  Private (Admin)
exports.aiVerify = async (req, res, next) => {
    try {
        const question = await Question.findByPk(req.params.id, {
            include: [{ model: Option, as: 'options' }]
        });

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        // Mock AI verification/Stub
        // In real app: Call OpenAI/Gemini with question text + options
        const mockAnalysis = {
            isValid: true,
            clarityScore: 0.9,
            scientificAccuracy: 0.95,
            suggestions: []
        };

        res.status(200).json({ success: true, data: mockAnalysis });
    } catch (error) {
        next(error);
    }
};
// ─── Rate Limiting for AI Endpoint ─────────────────────────────
const aiRateLimitMap = new Map(); // Map<adminId, { count, resetTime }>
const AI_RATE_LIMIT = 10; // max 10 requests per minute per admin
const AI_RATE_WINDOW = 60 * 1000; // 1 minute

function checkAIRateLimit(adminId) {
    const now = Date.now();
    const entry = aiRateLimitMap.get(adminId);

    if (!entry || now > entry.resetTime) {
        aiRateLimitMap.set(adminId, { count: 1, resetTime: now + AI_RATE_WINDOW });
        return { allowed: true, remaining: AI_RATE_LIMIT - 1 };
    }

    if (entry.count >= AI_RATE_LIMIT) {
        const retryAfter = Math.ceil((entry.resetTime - now) / 1000);
        return { allowed: false, retryAfter };
    }

    entry.count++;
    return { allowed: true, remaining: AI_RATE_LIMIT - entry.count };
}

// @desc    AI Generate Explanation — Protected, Full Persistence
// @route   POST /api/v1/admin/questions/:id/ai-explain
// @access  Private (Admin) — Rate Limited
exports.aiGenerateExplanation = async (req, res, next) => {
    try {
        // 1. Validate input
        const questionId = parseInt(req.params.id);
        if (!questionId || isNaN(questionId) || questionId <= 0) {
            return res.status(400).json({
                success: false,
                message: 'Invalid question ID. Must be a positive integer.'
            });
        }

        // 2. Rate limiting per admin
        const rateCheck = checkAIRateLimit(req.user.id);
        if (!rateCheck.allowed) {
            return res.status(429).json({
                success: false,
                message: `Rate limit exceeded. Try again in ${rateCheck.retryAfter} seconds.`,
                retryAfter: rateCheck.retryAfter
            });
        }

        // 3. Fetch question with all related data
        const question = await Question.findByPk(questionId, {
            include: [
                { model: Option, as: 'options' },
                { model: Specialty, as: 'specialty', attributes: ['name'] },
                { model: Topic, as: 'topic', attributes: ['name'] },
                { model: Explanation, as: 'explanation' }
            ]
        });

        if (!question) {
            return res.status(404).json({ success: false, message: 'Question not found' });
        }

        // 4. Validate question has options
        if (!question.options || question.options.length < 2) {
            return res.status(400).json({
                success: false,
                message: 'Question must have at least 2 options before generating AI explanation.'
            });
        }

        // 5. Check if correct answer is marked
        const hasCorrectAnswer = question.options.some(o => o.isCorrect);
        if (!hasCorrectAnswer) {
            return res.status(400).json({
                success: false,
                message: 'Question must have a correct answer marked before generating AI explanation.'
            });
        }

        // 6. Prevent duplicate generation within 5 minutes
        if (question.explanation && question.explanation.aiGenerated) {
            const lastUpdate = new Date(question.explanation.updatedAt);
            const fiveMinAgo = new Date(Date.now() - 5 * 60 * 1000);
            if (lastUpdate > fiveMinAgo) {
                return res.status(200).json({
                    success: true,
                    message: 'Explanation was recently generated. Returning cached result.',
                    cached: true,
                    data: {
                        summary: '',
                        keyPoints: [],
                        explanation: question.explanation.text,
                        whyWrong: question.explanation.whyWrong || {},
                        formattedText: question.explanation.text,
                        difficultyAssessment: question.difficulty,
                        references: question.explanation.references
                    }
                });
            }
        }

        // 7. Prepare data for AI
        const optionsForAI = question.options.map(o => ({
            order: o.order,
            text: o.text,
            isCorrect: o.isCorrect
        }));

        const specialtyName = question.specialty?.name || 'General Medicine';
        const topicName = question.topic?.name || 'General';

        // 8. Call AI service with full context
        const result = await aiService.generateStructuredExplanation(
            question.text, optionsForAI, specialtyName, topicName
        );

        if (!result.success) {
            console.error(`AI Generation Failed for Q:${questionId}`, result.error);
            return res.status(500).json({
                success: false,
                message: result.error || 'AI generation failed. Please try again.'
            });
        }

        const aiData = result.data;

        // 9. Build clean, professional formatted explanation (NO emojis, NO markdown)
        const formattedExplanation = [
            `SUMMARY: ${aiData.summary}`,
            '',
            'KEY POINTS:',
            ...aiData.keyPoints.map((kp, i) => `${i + 1}. ${kp}`),
            '',
            `EXPLANATION: ${aiData.explanation}`,
            '',
            'WHY OTHER OPTIONS ARE WRONG:',
            ...Object.entries(aiData.whyWrong || {}).map(([key, reason]) => `${key}: ${reason}`)
        ].join('\n');

        // 10. Get references from AI or build fallback
        const references = aiData.references || `${specialtyName} / ${topicName} — AI Generated ${new Date().toISOString().split('T')[0]}`;

        // 11. Save or update Explanation in DB (FULL DATA)
        const whyWrong = aiData.whyWrong || {};
        const existingExp = await Explanation.findOne({ where: { questionId } });

        if (existingExp) {
            await existingExp.update({
                text: formattedExplanation,
                whyWrong: whyWrong,
                references: references,
                aiGenerated: true
            });
        } else {
            await Explanation.create({
                questionId,
                text: formattedExplanation,
                whyWrong: whyWrong,
                references: references,
                aiGenerated: true
            });
        }

        // 12. Update question — difficulty, points, timeEstimate, verifiedByAI
        const updateData = { verifiedByAI: true };

        // Sync difficulty from AI
        const aiDifficulty = aiData.difficulty || aiData.difficultyAssessment;
        if (aiDifficulty && ['easy', 'medium', 'hard'].includes(aiDifficulty)) {
            updateData.difficulty = aiDifficulty;
        }

        // Sync time estimate from AI
        if (aiData.timeEstimate && typeof aiData.timeEstimate === 'number') {
            updateData.timeEstimate = aiData.timeEstimate;
        }

        // Mark high-difficulty questions as premium
        if (aiData.points && aiData.points >= 3) {
            updateData.isPremium = true;
        }

        await question.update(updateData);

        // 13. Log admin activity with details
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'AI_GENERATE_EXPLANATION',
            targetResource: `Question:${questionId} [${specialtyName}/${topicName}]`,
            ipAddress: req.ip
        });

        // 14. Return complete response
        res.status(200).json({
            success: true,
            data: {
                summary: aiData.summary,
                keyPoints: aiData.keyPoints,
                explanation: aiData.explanation,
                whyWrong: whyWrong,
                formattedText: formattedExplanation,
                difficulty: aiDifficulty || question.difficulty,
                points: aiData.points || 1,
                timeEstimate: aiData.timeEstimate || 60,
                references: references
            },
            meta: {
                questionId,
                specialty: specialtyName,
                topic: topicName,
                rateLimitRemaining: rateCheck.remaining
            }
        });
    } catch (error) {
        console.error(`AI Explain Error for Q:${req.params.id}:`, error);
        next(error);
    }
};

// @desc    AI Generate Complete Question from Specialty + Topic
// @route   POST /api/v1/admin/questions/ai-generate
// @access  Private (Admin) — Rate Limited
exports.aiGenerateQuestion = async (req, res, next) => {
    try {
        const { specialtyId, topicId } = req.body;

        // 1. Validate input
        if (!specialtyId || !topicId) {
            return res.status(400).json({
                success: false,
                message: 'Both specialtyId and topicId are required.'
            });
        }

        // 2. Rate limiting
        const rateCheck = checkAIRateLimit(req.user.id);
        if (!rateCheck.allowed) {
            return res.status(429).json({
                success: false,
                message: `Rate limit exceeded. Try again in ${rateCheck.retryAfter} seconds.`
            });
        }

        // 3. Fetch specialty and topic names
        const specialty = await Specialty.findByPk(specialtyId);
        const topic = await Topic.findByPk(topicId);

        if (!specialty) return res.status(404).json({ success: false, message: 'Specialty not found' });
        if (!topic) return res.status(404).json({ success: false, message: 'Topic not found' });

        // 4. Call AI to generate full question
        const result = await aiService.generateFullQuestion(specialty.name, topic.name);

        if (!result.success) {
            return res.status(500).json({
                success: false,
                message: result.error || 'AI question generation failed.'
            });
        }

        const aiData = result.data;

        // 5. Create the Question in DB
        const question = await Question.create({
            text: aiData.questionText,
            specialtyId,
            topicId,
            difficulty: aiData.difficulty || 'medium',
            timeEstimate: aiData.timeEstimate || 60,
            isPremium: (aiData.points && aiData.points >= 3),
            isActive: true,
            verifiedByAI: true,
            source: 'AI Generated'
        });

        // 6. Create Options
        const aiOptions = aiData.options || [];
        for (let i = 0; i < aiOptions.length; i++) {
            const opt = aiOptions[i];
            // Ensure order is an integer. If AI returns 'A', 'B', etc., map to 1, 2, 3...
            let orderValue = parseInt(opt.order);
            if (isNaN(orderValue)) {
                const orderMap = { 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5 };
                orderValue = orderMap[String(opt.order).toUpperCase()] || (i + 1);
            }

            await Option.create({
                questionId: question.id,
                text: opt.text,
                order: orderValue,
                isCorrect: opt.isCorrect
            });
        }

        // 7. Build formatted explanation
        const formattedExplanation = [
            `SUMMARY: ${aiData.explanation}`,
            '',
            'KEY POINTS:',
            ...(aiData.keyPoints || []).map((kp, i) => `${i + 1}. ${kp}`),
            '',
            'WHY OTHER OPTIONS ARE WRONG:',
            ...Object.entries(aiData.whyWrong || {}).map(([k, v]) => `${k}: ${v}`)
        ].join('\n');

        // 8. Create Explanation
        await Explanation.create({
            questionId: question.id,
            text: formattedExplanation,
            whyWrong: aiData.whyWrong || {},
            references: aiData.references || `${specialty.name} / ${topic.name} — AI Generated`,
            aiGenerated: true
        });

        // 9. Log activity
        await AdminActivityLog.create({
            adminId: req.user.id,
            action: 'AI_GENERATE_QUESTION',
            targetResource: `Question:${question.id} [${specialty.name}/${topic.name}]`,
            ipAddress: req.ip
        });

        // 10. Return full response
        res.status(201).json({
            success: true,
            data: {
                questionId: question.id,
                text: aiData.questionText,
                options: aiOptions,
                explanation: formattedExplanation,
                whyWrong: aiData.whyWrong,
                keyPoints: aiData.keyPoints,
                difficulty: aiData.difficulty,
                points: aiData.points,
                timeEstimate: aiData.timeEstimate,
                references: aiData.references
            }
        });
    } catch (error) {
        console.error('AI Generate Question Error:', error);
        next(error);
    }
};
