const fs = require('fs');
const path = require('path');

const mainSqlPath = path.join(__dirname, '../insert_missing_questions.sql');
const addSqlPath = path.join(__dirname, '../insert_missing_22_questions.sql');

let mainSql = fs.readFileSync(mainSqlPath, 'utf8');
const addSql = fs.readFileSync(addSqlPath, 'utf8');

// Strip headers and SET FOREIGN_KEY_CHECKS from addSql
const cleanAddSql = addSql
    .replace(/SET NAMES utf8mb4;\s*/g, '')
    .replace(/SET FOREIGN_KEY_CHECKS = 0;\s*/g, '')
    .replace(/SET FOREIGN_KEY_CHECKS = 1;\s*/g, '')
    .replace(/SELECT COUNT\(\*\) AS total_questions_after_import FROM Questions;\s*/g, '')
    .trim();

// Insert cleanAddSql right before "SET FOREIGN_KEY_CHECKS = 1;" in mainSql
const marker = 'SET FOREIGN_KEY_CHECKS = 1;';
if (mainSql.includes(marker)) {
    const parts = mainSql.split(marker);
    mainSql = parts[0] + '\n\n' + cleanAddSql + '\n\n' + marker + parts[1];
    fs.writeFileSync(mainSqlPath, mainSql, 'utf8');
    console.log('✅ Appended 19 questions from 22.docx into insert_missing_questions.sql successfully!');
} else {
    console.error('Marker not found in mainSql');
}
