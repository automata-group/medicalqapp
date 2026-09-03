const fs = require('fs');

const questions = JSON.parse(fs.readFileSync('classified_1137_questions.json', 'utf8'));

let sql = `-- ==============================================================================
-- BATCH IMPORT OF 1,137 CLASSIFIED DENTAL EXAM QUESTIONS
-- Source: اساله جديده 22.docx
-- Generated on: ${new Date().toISOString()}
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Ensure the 9 Specialties Exist
INSERT INTO specialties (specialty_name, specialty_code, description, is_active)
VALUES 
    ('Orthodontics', 'ORTHO', 'تقويم الأسنان والفكين', 1),
    ('Endodontics', 'ENDO', 'علاج عصب وجذور الأسنان', 1),
    ('Prosthodontics', 'PROSTHO', 'الاستعاضة السنية والتركيبات الثابتة والمتحركة', 1),
    ('Periodontics', 'PERIO', 'أمراض وجراحة اللثة والأنسجة الداعمة', 1),
    ('Pediatric Dentistry', 'PEDO', 'طب أسنان الأطفال والوقاية', 1),
    ('Restorative', 'RESTO', 'طب الأسنان التحفظي والترميم والمواد الحيوية', 1),
    ('Dental Surgery', 'SURG', 'جراحة الفم والفكين والخلع والتخدير', 1),
    ('Oral Medicine & Pathology', 'ORALMED', 'طب الفم والأمراض والآفات الفموية', 1),
    ('Dental Ethics', 'ETHICS', 'أخلاقيات المهنة ومكافحة العدوى والسلامة', 1)
ON DUPLICATE KEY UPDATE specialty_name = VALUES(specialty_name);

`;

function escapeSql(str) {
    if (!str) return "''";
    return "'" + str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\n/g, '\\n').replace(/\r/g, '\\r') + "'";
}

questions.forEach((q, idx) => {
    sql += `\n-- Question #${idx + 1} (${q.specialty} - ${q.difficulty})\n`;
    sql += `INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at)
VALUES (
    (SELECT specialty_id FROM specialties WHERE specialty_name = ${escapeSql(q.specialty)} LIMIT 1),
    ${escapeSql(q.text)},
    ${q.questionNumber},
    ${escapeSql(q.difficulty)},
    'اساله جديده 22.docx',
    60, 1, 0, 1, NOW(), NOW()
);
SET @new_qid = LAST_INSERT_ID();
`;

    q.options.forEach(opt => {
        sql += `INSERT INTO question_options (question_id, option_label, option_text, is_correct, created_at)
VALUES (@new_qid, ${escapeSql(opt.label)}, ${escapeSql(opt.text)}, ${opt.isCorrect ? 1 : 0}, NOW());\n`;
    });

    if (q.explanation) {
        sql += `INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, \`references\`, ai_generated, ai_model, created_at, updated_at)
VALUES (@new_qid, ${escapeSql(q.explanation)}, '', 'اساله جديده 22.docx - SDLE QBank', 1, 'Classified & Verified', NOW(), NOW());\n`;
    }
});

sql += `\n-- 3. Update total_questions on specialties
UPDATE specialties s
SET total_questions = (SELECT COUNT(*) FROM questions q WHERE q.specialty_id = s.specialty_id);

SET FOREIGN_KEY_CHECKS = 1;
`;

fs.writeFileSync('insert_1137_questions_production.sql', sql, 'utf8');
console.log(`Generated insert_1137_questions_production.sql (File size: ${(sql.length / 1024 / 1024).toFixed(2)} MB)`);
process.exit(0);
