const OpenAI = require('openai');

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY || 'dummy_key',
});

exports.generateExplanation = async (questionText, correctOption) => {
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
        return "AI Explanation Generation requires API Key. (Stub Response)";
    }

    try {
        const completion = await openai.chat.completions.create({
            messages: [
                { role: "system", content: "You are a medical expert helper." },
                { role: "user", content: `Explain why the answer '${correctOption}' is correct for the question: '${questionText}'. Keep it concise.` }
            ],
            model: "gpt-4o-mini",
        });

        return completion.choices[0].message.content;
    } catch (error) {
        console.error('AI Service Error:', error);
        return "Failed to generate explanation.";
    }
};

exports.verifyQuestion = async (questionText, options) => {
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
        return { verified: false, reason: "No API Key" };
    }

    try {
        const completion = await openai.chat.completions.create({
            messages: [
                { role: "system", content: "You are a medical question auditor." },
                { role: "user", content: `Verify if this medical question is accurate and clear. Question: ${questionText}. Options: ${JSON.stringify(options)}.` }
            ],
            model: "gpt-4o-mini",
        });

        return {
            verified: true,
            analysis: completion.choices[0].message.content
        };
    } catch (error) {
        console.error('AI Service Error:', error);
        return { verified: false, reason: "AI connection failed" };
    }
};

/**
 * Generate a structured explanation for a medical question using AI.
 * @param {string} questionText - The question text
 * @param {Array} options - Array of {order, text, isCorrect}
 * @param {string} specialtyName - e.g. "Cardiology", "Neurology"
 * @param {string} topicName - e.g. "Heart Failure", "Stroke Management"
 */
exports.generateStructuredExplanation = async (questionText, options, specialtyName, topicName) => {
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
        const correctOpt = options.find(o => o.isCorrect);
        const incorrectOpts = options.filter(o => !o.isCorrect);
        const whyWrong = {};
        incorrectOpts.forEach(opt => {
            whyWrong[opt.order] = `This option "${opt.text}" is incorrect. (Stub: configure OPENAI_API_KEY for real AI analysis)`;
        });
        return {
            success: true,
            data: {
                summary: `[${specialtyName} - ${topicName}] ${questionText.substring(0, 80)}...`,
                keyPoints: [
                    "Configure OPENAI_API_KEY in .env for real AI-generated key points.",
                    "The AI will extract the most relevant medical concepts.",
                    "Key points help students focus on critical knowledge areas."
                ],
                explanation: `The correct answer is "${correctOpt?.text || 'N/A'}" because it aligns with the established medical guidelines. (Stub Response)`,
                whyWrong,
                difficultyAssessment: "medium"
            }
        };
    }

    try {
        const correctOpt = options.find(o => o.isCorrect);
        const optionsText = options.map(o =>
            `${o.order}. ${o.text} ${o.isCorrect ? '[CORRECT]' : ''}`
        ).join('\n');

        const systemPrompt = `You are a Senior Medical Professor and Board-Certified Physician with 25+ years of clinical and academic experience in ${specialtyName || 'General Medicine'}.

STRICT RULES:
- You are writing official medical exam explanations for a question bank.
- Use formal, clinical language only.
- Do NOT use emojis, symbols, hashtags, markdown headers (##), or any decorative formatting.
- Do NOT use asterisks for bold (**text**) or any markdown syntax.
- Write plain, clean, professional text only.
- Every statement must be medically accurate and evidence-based.
- Reference established medical sources (Harrison's Principles of Internal Medicine, Robbins Pathology, Guyton Physiology, First Aid for USMLE, UpToDate) when applicable.
- Be direct and authoritative. No filler words or vague statements.
- You respond ONLY in valid JSON format.`;

        const userPrompt = `Generate a complete, structured medical explanation for the following question.

Specialty: ${specialtyName || 'General Medicine'}
Topic: ${topicName || 'General'}

Question:
${questionText}

Options:
${optionsText}

Correct Answer: ${correctOpt ? `${correctOpt.order}. ${correctOpt.text}` : 'Not specified'}

Respond in valid JSON with this EXACT structure:

{
  "summary": "One sentence describing what medical concept or clinical principle this question tests. Be specific to the specialty and topic.",
  "keyPoints": [
    "First critical medical fact relevant to this question.",
    "Second critical fact — include pathophysiology, mechanism, or diagnostic criteria.",
    "Third fact — mention relevant clinical guidelines, drug interactions, or treatment protocols.",
    "Fourth fact (optional) — additional high-yield information for exam preparation.",
    "Fifth fact (optional) — common clinical pitfalls or differential diagnosis considerations."
  ],
  "explanation": "A thorough 3-5 sentence explanation of why the correct answer is right. Include the underlying pathophysiological mechanism, pharmacological basis, or clinical reasoning. Cite specific medical principles. Do not use emojis or markdown formatting.",
  "whyWrong": {
    "A": "Precise medical reason why option A is incorrect. Explain the specific misconception. OMIT this key entirely if A is the correct answer.",
    "B": "Precise medical reason why option B is incorrect. OMIT if correct.",
    "C": "Precise medical reason why option C is incorrect. OMIT if correct.",
    "D": "Precise medical reason why option D is incorrect. OMIT if correct."
  },
  "difficulty": "easy or medium or hard — based on the depth of medical knowledge and clinical reasoning required.",
  "points": 1,
  "timeEstimate": 60,
  "references": "Relevant textbook or guideline references, comma-separated. Example: Harrison's Ch.264, Robbins Ch.12, First Aid 2026 p.340"
}

FIELD RULES:
- difficulty: must be exactly one of "easy", "medium", or "hard"
- points: integer, 1 for easy, 2 for medium, 3 for hard
- timeEstimate: estimated seconds to solve — 45 for easy, 60 for medium, 90 for hard
- references: real medical textbook chapters or guideline names relevant to this question
- whyWrong: ONLY include keys for INCORRECT options, SKIP the correct answer's key entirely
- Do NOT include any emojis, markdown, or decorative characters anywhere in the response
- Every explanation must be specific to ${specialtyName || 'medicine'} and ${topicName || 'this topic'}, not generic`;

        const completion = await openai.chat.completions.create({
            messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: userPrompt }
            ],
            model: "gpt-4o-mini",
            temperature: 1,
            response_format: { type: "json_object" }
        });

        const rawContent = completion.choices[0].message.content;
        const parsed = JSON.parse(rawContent);

        return {
            success: true,
            data: parsed
        };
    } catch (error) {
        console.error('AI Structured Explanation Error:', error);
        return {
            success: false,
            error: error.message || "Failed to generate structured explanation."
        };
    }
};

/**
 * Generate a complete medical question with options and explanation from scratch.
 * @param {string} specialtyName - e.g. "Cardiology"
 * @param {string} topicName - e.g. "Heart Failure"
 */
exports.generateFullQuestion = async (specialtyName, topicName) => {
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
        return {
            success: true,
            data: {
                questionText: `[STUB] Sample question about ${topicName} in ${specialtyName}. Configure OPENAI_API_KEY for real generation.`,
                options: [
                    { order: "A", text: "Option A (correct)", isCorrect: true },
                    { order: "B", text: "Option B", isCorrect: false },
                    { order: "C", text: "Option C", isCorrect: false },
                    { order: "D", text: "Option D", isCorrect: false }
                ],
                explanation: "Stub explanation. Configure OPENAI_API_KEY for AI-generated content.",
                keyPoints: ["Stub key point 1", "Stub key point 2"],
                whyWrong: { "B": "Stub reason B is wrong", "C": "Stub reason C is wrong", "D": "Stub reason D is wrong" },
                difficulty: "medium",
                points: 2,
                timeEstimate: 60,
                references: "Configure API key for real references"
            }
        };
    }

    try {
        const systemPrompt = `You are a Senior Medical Professor creating exam questions for a medical question bank. You specialize in ${specialtyName}.

STRICT RULES:
- Create realistic, clinically accurate medical exam questions.
- Use formal, clinical language only.
- Do NOT use emojis, symbols, hashtags, markdown headers, or decorative formatting.
- Do NOT use asterisks for bold or any markdown syntax.
- Questions must test understanding, not just memorization.
- All options must be plausible to a medical student.
- Only ONE option should be correct.
- You respond ONLY in valid JSON format.`;

        const userPrompt = `Generate a complete medical exam question for the following:

Specialty: ${specialtyName}
Topic: ${topicName}

Respond in valid JSON with this EXACT structure:

{
  "questionText": "A clinical scenario or direct medical question. Make it realistic with patient details (age, sex, symptoms, vitals, lab results) when appropriate. 2-4 sentences.",
  "options": [
    { "order": "A", "text": "First option text", "isCorrect": false },
    { "order": "B", "text": "Second option text", "isCorrect": true },
    { "order": "C", "text": "Third option text", "isCorrect": false },
    { "order": "D", "text": "Fourth option text", "isCorrect": false }
  ],
  "explanation": "Thorough 3-5 sentence explanation of why the correct answer is right. Include pathophysiological mechanism, clinical reasoning, or pharmacological basis.",
  "keyPoints": [
    "First critical medical fact.",
    "Second critical fact with pathophysiology or mechanism.",
    "Third fact with clinical guideline or treatment protocol."
  ],
  "whyWrong": {
    "A": "Why A is wrong (skip if A is correct)",
    "C": "Why C is wrong (skip if C is correct)",
    "D": "Why D is wrong (skip if D is correct)"
  },
  "difficulty": "easy or medium or hard",
  "points": 2,
  "timeEstimate": 60,
  "references": "Relevant textbook chapters or guidelines, comma-separated"
}

RULES:
- Exactly ONE option must have isCorrect: true
- The correct answer position should vary (not always B)
- difficulty must be exactly "easy", "medium", or "hard"
- points: 1 for easy, 2 for medium, 3 for hard
- timeEstimate: 45 for easy, 60 for medium, 90 for hard
- whyWrong must SKIP the correct answer's key
- Make the question specific to ${specialtyName} / ${topicName}
- No emojis, no markdown, no decorations`;

        const completion = await openai.chat.completions.create({
            messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: userPrompt }
            ],
            model: "gpt-4o-mini",
            temperature: 1,
            response_format: { type: "json_object" }
        });

        const rawContent = completion.choices[0].message.content;
        const parsed = JSON.parse(rawContent);

        return {
            success: true,
            data: parsed
        };
    } catch (error) {
        console.error('AI Question Generation Error:', error);
        return {
            success: false,
            error: error.message || "Failed to generate question."
        };
    }
};

// =====================================================================
// DOCX QUESTION EXTRACTION ENGINE (V3 — Clean Rebuild)
// =====================================================================
exports.parseDocxQuestions = async (rawText, specialtyName, topicName, context = {}) => {
    const isAutoDetect = specialtyName === 'auto' || topicName === 'auto' || !specialtyName;
    const maxQuestions = context.maxQuestions || 10;
    const existingSpecialties = context.existingSpecialties || [];
    const existingQuestionTexts = context.existingQuestionTexts || [];

    // --- Stub fallback when no API key ---
    if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
        return {
            success: true,
            data: {
                questions: [{
                    reasoning_and_analysis: "Stub",
                    detectedSpecialty: isAutoDetect ? "General Medicine" : specialtyName,
                    detectedTopic: isAutoDetect ? "Stub Topic" : topicName,
                    mappedToExistingSystemCategory: false,
                    isDuplicate: false,
                    questionText: `[STUB] ${rawText.substring(0, 50)}...`,
                    options: [
                        { order: "A", text: "Option A", isCorrect: true },
                        { order: "B", text: "Option B", isCorrect: false },
                        { order: "C", text: "Option C", isCorrect: false },
                        { order: "D", text: "Option D", isCorrect: false }
                    ],
                    explanation: "Stub explanation. Configure OPENAI_API_KEY.",
                    references: "اطباؤنا",
                    difficulty: "medium",
                    points: 2
                }]
            }
        };
    }

    try {
        // ========== 1. BUILD TAXONOMY CATALOG ==========
        let catalogSection = '';
        if (existingSpecialties.length > 0) {
            catalogSection = `\nEXISTING SPECIALTIES & TOPICS:\n`;
            existingSpecialties.forEach(sp => {
                const topicList = (sp.topics || []).map(t => t.name);
                if (topicList.length > 0) {
                    catalogSection += `- "${sp.name}" -> Topics: [${topicList.join(', ')}]\n`;
                } else {
                    catalogSection += `- "${sp.name}" -> Topics: [NONE — Create specific topic names]\n`;
                }
            });
            catalogSection += `
TAXONOMY RULES:
1. SPECIALTIES ARE LOCKED. Use EXACT names from above. NEVER invent new ones.
2. If a relevant topic exists under the specialty, use its EXACT name. Otherwise CREATE a specific clinical subject name.
3. GOOD topic names: "Infection Control & Professional Conduct", "Local Anesthesia Techniques", "Pulpal Biology & Diagnosis"
4. BAD topic names: "General", "Basics", "Other", or repeating the specialty name
5. Group related questions under the SAME topic name.\n`;
        }

        // ========== 2. BUILD EXISTING QUESTIONS LIST ==========
        let existingQuestionsSection = "None provided.";
        if (existingQuestionTexts && existingQuestionTexts.length > 0) {
            existingQuestionsSection = existingQuestionTexts.map((text, i) => `${i + 1}. ${text}`).join('\n');
        }

        // ========== 3. SYSTEM PROMPT ==========
        const systemPrompt = `You are a World-Class Expert Medical/Dental Educator and Question Bank Architect. Extract questions from raw text and generate premium educational content.

===========================
TAXONOMY
===========================
${catalogSection}

===========================
EXPLANATION FORMAT (MANDATORY)
===========================
For EVERY question, write a full, clinically rich explanation with these exact sections inside the "explanation" field:

SUMMARY: [1-2 complete sentences explaining WHY the correct answer is correct, from a physiological or clinical standpoint.]

KEY POINTS:
- [High-yield clinical fact #1]
- [High-yield clinical fact #2]
- [High-yield clinical fact #3]

WHY OTHER OPTIONS ARE WRONG:
- [Option A - text]: [Full sentence with clinical reasoning why wrong.]
- [Option B - text]: [Full sentence with clinical reasoning why wrong.]
- [Option C - text]: [Full sentence with clinical reasoning why wrong.]

===========================
EXAMPLE OF EXPECTED QUALITY
===========================
Question: "First step after needle-stick injury?"
Correct: "Wash with water immediately"
explanation field value:
"SUMMARY: According to CDC and OSHA guidelines, the immediate first step following a needle-stick exposure is thorough washing with soap and water to physically remove the pathogen before reporting the incident.\\n\\nKEY POINTS:\\n- Needle-stick injuries must be reported per OSHA Bloodborne Pathogens Standard (29 CFR 1910.1030)\\n- Post-Exposure Prophylaxis (PEP) for HIV should be started within 72 hours\\n- Risk of HIV transmission from a single needle-stick from an HIV+ patient is approximately 0.3%\\n\\nWHY OTHER OPTIONS ARE WRONG:\\n- [Option A - Report incident]: Reporting is critical but NOT the immediate first step; washing must occur first to reduce pathogen load.\\n- [Option C - Induce bleeding]: Squeezing the wound is NOT recommended by CDC guidelines as it may increase tissue damage.\\n- [Option D - Take antibiotics]: Antibiotics are not the immediate response; bloodborne status of the source patient must be assessed first."

===========================
REFERENCES
===========================
- Word document / unknown source: use "اطباؤنا"
- Known textbook: cite it (e.g., "Malamed, Handbook of Local Anesthesia")

===========================
MONETIZATION
===========================
- Points 1-2 = Free (Easy/Medium)
- Points 3-5 = Premium (Hard/Complex)`;

        // ========== 4. USER PROMPT ==========
        const userPrompt = `Extract all questions from this text. Apply all taxonomy and explanation rules.

Existing Questions (mark isDuplicate: true if semantically identical):
${existingQuestionsSection}

---
RAW TEXT:
${rawText}
---`;

        // ========== 5. API CALL (WITH RETRY & BACKOFF) ==========
        let attempts = 0;
        const maxAttempts = 3;
        let completion;

        while (attempts < maxAttempts) {
            try {
                completion = await openai.chat.completions.create({
                    messages: [
                        { role: "system", content: systemPrompt },
                        { role: "user", content: userPrompt }
                    ],
                    model: "gpt-4o",
                    temperature: 0.2,
                    max_completion_tokens: 16384,
                    response_format: {
                        type: "json_schema",
                        json_schema: {
                            name: "medical_extraction_v3",
                            strict: true,
                            schema: {
                                type: "object",
                                properties: {
                                    questions: {
                                        type: "array",
                                        items: {
                                            type: "object",
                                            properties: {
                                                reasoning_and_analysis: {
                                                    type: "string",
                                                    description: "Your internal medical reasoning about this question. Analyze the concept, why the answer is correct, and classify the specialty/topic."
                                                },
                                                detectedSpecialty: {
                                                    type: "string",
                                                    description: "Exact specialty name from the catalog"
                                                },
                                                detectedTopic: {
                                                    type: "string",
                                                    description: "Specific clinical subject name. Never 'General'."
                                                },
                                                mappedToExistingSystemCategory: {
                                                    type: "boolean"
                                                },
                                                isDuplicate: {
                                                    type: "boolean"
                                                },
                                                questionText: {
                                                    type: "string"
                                                },
                                                options: {
                                                    type: "array",
                                                    items: {
                                                        type: "object",
                                                        properties: {
                                                            order: { type: "string" },
                                                            text: { type: "string" },
                                                            isCorrect: { type: "boolean" }
                                                        },
                                                        required: ["order", "text", "isCorrect"],
                                                        additionalProperties: false
                                                    }
                                                },
                                                explanation: {
                                                    type: "string",
                                                    description: "Full clinical explanation with SUMMARY, KEY POINTS, and WHY OTHER OPTIONS ARE WRONG. Must contain complete sentences, not just headers."
                                                },
                                                references: {
                                                    type: "string"
                                                },
                                                difficulty: {
                                                    type: "string",
                                                    enum: ["easy", "medium", "hard"]
                                                },
                                                points: {
                                                    type: "integer"
                                                }
                                            },
                                            required: ["reasoning_and_analysis", "detectedSpecialty", "detectedTopic", "mappedToExistingSystemCategory", "isDuplicate", "questionText", "options", "explanation", "references", "difficulty", "points"],
                                            additionalProperties: false
                                        }
                                    }
                                },
                                required: ["questions"],
                                additionalProperties: false
                            }
                        }
                    }
                });
                break; // Success!
            } catch (error) {
                if (error.status === 429 && attempts < maxAttempts - 1) {
                    attempts++;
                    const waitTime = Math.pow(2, attempts) * 15000; // 30s, 60s
                    console.warn(`[AI] Rate limit hit. Retrying in ${waitTime/1000}s... (Attempt ${attempts}/${maxAttempts})`);
                    await new Promise(resolve => setTimeout(resolve, waitTime));
                } else {
                    throw error;
                }
            }
        }


        // ========== 6. HANDLE RESPONSE ==========
        if (completion.choices[0].message.refusal) {
            console.error(`[AI] Refusal: ${completion.choices[0].message.refusal}`);
            throw new Error("AI refused to process the request.");
        }

        const rawContent = completion.choices[0].message.content;
        const parsed = JSON.parse(rawContent);

        if (!parsed.questions || !Array.isArray(parsed.questions)) {
            throw new Error("AI response missing questions array.");
        }

        if (parsed.questions.length > maxQuestions) {
            parsed.questions = parsed.questions.slice(0, maxQuestions);
        }

        console.log(`[AI] V3 Extraction complete: ${parsed.questions.length} questions extracted.`);

        return { success: true, data: parsed };
    } catch (error) {
        console.error('[AI] DOCX Parse Error:', error);
        return { success: false, error: error.message || "Failed to parse questions." };
    }
};
