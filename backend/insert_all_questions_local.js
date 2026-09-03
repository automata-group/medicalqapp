const fs = require('fs');
require('dotenv').config();
const sequelize = require('./src/config/database');

async function insertAll() {
    console.log('=== Ingesting 1,137 Classified Questions into Database ===');
    const questions = JSON.parse(fs.readFileSync('classified_1137_questions.json', 'utf8'));
    console.log(`Loaded ${questions.length} questions.`);

    const t = await sequelize.transaction();

    try {
        // 1. Ensure the 9 specialties exist
        const specialtyDefinitions = [
            { name: 'Orthodontics', code: 'ORTHO', desc: 'تقويم الأسنان والفكين' },
            { name: 'Endodontics', code: 'ENDO', desc: 'علاج عصب وجذور الأسنان' },
            { name: 'Prosthodontics', code: 'PROSTHO', desc: 'الاستعاضة السنية والتركيبات الثابتة والمتحركة' },
            { name: 'Periodontics', code: 'PERIO', desc: 'أمراض وجراحة اللثة والأنسجة الداعمة' },
            { name: 'Pediatric Dentistry', code: 'PEDO', desc: 'طب أسنان الأطفال والوقاية' },
            { name: 'Restorative', code: 'RESTO', desc: 'طب الأسنان التحفظي والترميم والمواد الحيوية' },
            { name: 'Dental Surgery', code: 'SURG', desc: 'جراحة الفم والفكين والخلع والتخدير' },
            { name: 'Oral Medicine & Pathology', code: 'ORALMED', desc: 'طب الفم والأمراض والآفات الفموية' },
            { name: 'Dental Ethics', code: 'ETHICS', desc: 'أخلاقيات المهنة ومكافحة العدوى والسلامة' }
        ];

        const specialtyMap = {};

        // Fetch existing
        const [existingSpecs] = await sequelize.query('SELECT specialty_id, specialty_name FROM specialties', { transaction: t });
        existingSpecs.forEach(s => {
            specialtyMap[s.specialty_name] = s.specialty_id;
        });

        for (const spec of specialtyDefinitions) {
            if (!specialtyMap[spec.name]) {
                const [insertResult] = await sequelize.query(`
                    INSERT INTO specialties (specialty_name, specialty_code, description, is_active, created_at, updated_at)
                    VALUES (:name, :code, :desc, 1, NOW(), NOW())
                `, {
                    replacements: { name: spec.name, code: spec.code, desc: spec.desc },
                    transaction: t
                });
                specialtyMap[spec.name] = insertResult;
                console.log(`Created specialty: ${spec.name} (ID: ${insertResult})`);
            } else {
                console.log(`Specialty exists: ${spec.name} (ID: ${specialtyMap[spec.name]})`);
            }
        }

        // 2. Insert questions
        let insertedQuestions = 0;
        let insertedOptions = 0;
        let insertedExplanations = 0;

        for (const q of questions) {
            const specId = specialtyMap[q.specialty] || specialtyMap['Restorative'];

            // Insert into questions table
            const [qRes] = await sequelize.query(`
                INSERT INTO questions (
                    specialty_id, question_text, question_number, difficulty_level, 
                    question_source, estimated_time_seconds, is_active, is_free, 
                    ai_verified, created_at, updated_at
                ) VALUES (
                    :specialtyId, :text, :qNum, :difficulty,
                    :source, 60, 1, 0,
                    1, NOW(), NOW()
                )
            `, {
                replacements: {
                    specialtyId: specId,
                    text: q.text,
                    qNum: q.questionNumber,
                    difficulty: q.difficulty || 'medium',
                    source: 'اساله جديده 22.docx'
                },
                transaction: t
            });

            const questionId = qRes;
            insertedQuestions++;

            // Insert options
            for (const opt of q.options) {
                await sequelize.query(`
                    INSERT INTO question_options (
                        question_id, option_label, option_text, is_correct, created_at
                    ) VALUES (
                        :questionId, :label, :text, :isCorrect, NOW()
                    )
                `, {
                    replacements: {
                        questionId,
                        label: opt.label,
                        text: opt.text,
                        isCorrect: opt.isCorrect ? 1 : 0
                    },
                    transaction: t
                });
                insertedOptions++;
            }

            // Insert explanation if present
            if (q.explanation && q.explanation.trim().length > 0) {
                await sequelize.query(`
                    INSERT INTO question_explanations (
                        question_id, correct_explanation, why_others_wrong, \`references\`, 
                        ai_generated, ai_model, created_at, updated_at
                    ) VALUES (
                        :questionId, :explanation, '', 'اساله جديده 22.docx - SDLE QBank',
                        1, 'Classified & Verified', NOW(), NOW()
                    )
                `, {
                    replacements: {
                        questionId,
                        explanation: q.explanation
                    },
                    transaction: t
                });
                insertedExplanations++;
            }
        }

        await t.commit();
        console.log(`\n🎉 TRANSACTION COMMITTED SUCCESSFULLY!`);
        console.log(`✅ Total Questions Inserted: ${insertedQuestions}`);
        console.log(`✅ Total Options Inserted: ${insertedOptions}`);
        console.log(`✅ Total Explanations Inserted: ${insertedExplanations}`);

        // Update total_questions count on specialties
        for (const spec of specialtyDefinitions) {
            const sId = specialtyMap[spec.name];
            await sequelize.query(`
                UPDATE specialties 
                SET total_questions = (SELECT COUNT(*) FROM questions WHERE specialty_id = :sId)
                WHERE specialty_id = :sId
            `, { replacements: { sId } });
        }
        console.log('✅ Specialties total_questions updated successfully.');

    } catch (err) {
        await t.rollback();
        console.error('❌ Ingestion failed, transaction rolled back:', err);
        process.exit(1);
    }

    process.exit(0);
}

insertAll();
