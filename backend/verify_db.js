require('dotenv').config();
const sequelize = require('./src/config/database');

async function verifyDB() {
    const [specs] = await sequelize.query(`
        SELECT s.specialty_id, s.specialty_name, s.specialty_code, s.total_questions,
               COUNT(q.question_id) as actual_question_count
        FROM specialties s
        LEFT JOIN questions q ON s.specialty_id = q.specialty_id
        GROUP BY s.specialty_id
        ORDER BY actual_question_count DESC
    `);
    console.log('--- Current Specialties and Question Counts in DB ---');
    console.table(specs);

    const [totalQ] = await sequelize.query('SELECT COUNT(*) as cnt FROM questions');
    const [totalOpt] = await sequelize.query('SELECT COUNT(*) as cnt FROM question_options');
    const [totalExp] = await sequelize.query('SELECT COUNT(*) as cnt FROM question_explanations');
    console.log(`Total Questions in Database: ${totalQ[0].cnt}`);
    console.log(`Total Options in Database: ${totalOpt[0].cnt}`);
    console.log(`Total Explanations in Database: ${totalExp[0].cnt}`);

    // Sample 2 questions inserted from the new docx
    const [sample] = await sequelize.query(`
        SELECT q.question_id, s.specialty_name, q.difficulty_level, q.question_text
        FROM questions q
        JOIN specialties s ON q.specialty_id = s.specialty_id
        WHERE q.question_source = 'اساله جديده 22.docx'
        ORDER BY q.question_id DESC
        LIMIT 3
    `);
    console.log('\nSample newly inserted questions:');
    console.log(JSON.stringify(sample, null, 2));

    process.exit(0);
}

verifyDB();
