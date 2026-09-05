const fs = require('fs');
const path = require('path');
const sequelize = require('../src/config/database');

const questionsData = JSON.parse(
    fs.readFileSync(path.join(__dirname, 'structured_25_questions.json'), 'utf8')
);

function escapeSql(str) {
    if (!str) return '';
    return str.replace(/'/g, "''").replace(/\\/g, '\\\\');
}

async function run() {
    console.log(`Starting import of ${questionsData.length} clinical image questions...`);

    let localSql = '-- ==========================================\n-- Local Database Import (medical_qbank)\n-- ==========================================\nSET FOREIGN_KEY_CHECKS = 0;\n\n';
    let prodSql = '-- ==========================================\n-- Production Database Import (healthlicenseprep.com)\n-- ==========================================\nSET FOREIGN_KEY_CHECKS = 0;\n\n';

    await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');

    let insertedCount = 0;

    for (const q of questionsData) {
        const specName = q.specialty === 'Oral Surgery' ? 'Dental Surgery' : q.specialty;
        const prodSpecName = q.specialty === 'Dental Surgery' ? 'Oral Surgery' : q.specialty;

        // Resolve specialtyId in local DB
        const [specRows] = await sequelize.query(
            `SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%${escapeSql(specName)}%' OR specialty_name LIKE '%${escapeSql(q.specialty)}%' LIMIT 1`
        );
        const specialtyId = specRows.length > 0 ? specRows[0].specialty_id : 18;

        // Insert Question into local DB
        const [qInsertRes] = await sequelize.query(
            `INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
                ${specialtyId},
                '${escapeSql(q.text)}',
                ${q.num},
                'medium',
                'What is this lesion Docx',
                '${q.image}',
                60, 1, 1, 1, NOW(), NOW()
            )`
        );
        const questionId = qInsertRes; // or insertId

        // Insert options
        for (const opt of q.options) {
            const optExp = opt.isCorrect ? escapeSql(q.explanation) : '';
            await sequelize.query(
                `INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (
                    ${questionId}, '${opt.label}', '${escapeSql(opt.text)}', ${opt.isCorrect ? 1 : 0}, '${optExp}', NOW()
                )`
            );
        }

        // Insert explanation
        await sequelize.query(
            `INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, \`references\`, ai_generated, ai_model, created_at, updated_at) VALUES (
                ${questionId}, '${escapeSql(q.explanation)}', '${escapeSql(q.whyWrong)}', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW()
            )`
        );

        // Insert tag
        await sequelize.query(
            `INSERT IGNORE INTO question_tags (tag_name) VALUES ('${escapeSql(q.topic)}')`
        );
        await sequelize.query(
            `INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (
                ${questionId}, (SELECT tag_id FROM question_tags WHERE tag_name = '${escapeSql(q.topic)}' LIMIT 1)
            )`
        );

        insertedCount++;
        console.log(`[${insertedCount}/25] Inserted Q${q.num}: ${q.text.substring(0, 35)}... (Spec ID: ${specialtyId}, Topic: ${q.topic})`);

        // --- Accumulate SQL for files ---
        // 1. Local SQL
        localSql += `-- Question ${q.num}: ${escapeSql(q.text.substring(0, 40))}...\n`;
        localSql += `INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (\n`;
        localSql += `  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%${escapeSql(specName)}%' OR specialty_name LIKE '%${escapeSql(q.specialty)}%' LIMIT 1), 18),\n`;
        localSql += `  '${escapeSql(q.text)}',\n`;
        localSql += `  ${q.num},\n`;
        localSql += `  'medium',\n`;
        localSql += `  'What is this lesion Docx',\n`;
        localSql += `  '${q.image}',\n`;
        localSql += `  60, 1, 1, 1, NOW(), NOW()\n`;
        localSql += `);\n`;
        localSql += `SET @qid = LAST_INSERT_ID();\n\n`;

        for (const opt of q.options) {
            const optExp = opt.isCorrect ? escapeSql(q.explanation) : '';
            localSql += `INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, '${opt.label}', '${escapeSql(opt.text)}', ${opt.isCorrect ? 1 : 0}, '${optExp}', NOW());\n`;
        }
        localSql += `INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, \`references\`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, '${escapeSql(q.explanation)}', '${escapeSql(q.whyWrong)}', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());\n`;
        localSql += `INSERT IGNORE INTO question_tags (tag_name) VALUES ('${escapeSql(q.topic)}');\n`;
        localSql += `INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = '${escapeSql(q.topic)}' LIMIT 1));\n\n`;

        // 2. Production SQL
        prodSql += `-- Question ${q.num}: ${escapeSql(q.text.substring(0, 40))}...\n`;
        prodSql += `INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (\n`;
        prodSql += `  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%${escapeSql(prodSpecName)}%' OR name LIKE '%${escapeSql(q.specialty)}%' LIMIT 1), 14),\n`;
        prodSql += `  (SELECT id FROM Topics WHERE name = '${escapeSql(q.topic)}' LIMIT 1),\n`;
        prodSql += `  '${escapeSql(q.topic)}',\n`;
        prodSql += `  '${escapeSql(q.text)}',\n`;
        prodSql += `  '${q.image}',\n`;
        prodSql += `  'medium',\n`;
        prodSql += `  60, 1, 0,\n`;
        prodSql += `  'What is this lesion Docx',\n`;
        prodSql += `  1, NOW(), NOW()\n`;
        prodSql += `);\n`;
        prodSql += `SET @prod_qid = LAST_INSERT_ID();\n\n`;

        for (const opt of q.options) {
            prodSql += `INSERT INTO Options (questionId, \`order\`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, '${opt.label}', '${escapeSql(opt.text)}', ${opt.isCorrect ? 1 : 0}, NOW(), NOW());\n`;
        }
        prodSql += `INSERT INTO Explanations (questionId, text, whyWrong, \`references\`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, '${escapeSql(q.explanation)}', '${escapeSql(q.whyWrong)}', 'Clinical Dental Examination', 1, NOW(), NOW());\n\n`;
    }

    localSql += 'SET FOREIGN_KEY_CHECKS = 1;\n';
    prodSql += 'SET FOREIGN_KEY_CHECKS = 1;\n';

    await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');

    fs.writeFileSync(path.join(__dirname, 'insert_25_questions_local.sql'), localSql, 'utf8');
    fs.writeFileSync(path.join(__dirname, 'insert_25_questions_production.sql'), prodSql, 'utf8');

    console.log(`\n🎉 Success! All ${insertedCount} questions inserted into local database!`);
    console.log(`Saved insert_25_questions_local.sql and insert_25_questions_production.sql`);

    process.exit(0);
}

run().catch(err => {
    console.error('Import error:', err);
    process.exit(1);
});
