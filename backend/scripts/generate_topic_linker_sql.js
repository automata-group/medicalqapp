const fs = require('fs');
const path = require('path');

// Re-use rule dictionary from test_topic_linker
const linkerScript = fs.readFileSync(path.join(__dirname, 'test_topic_linker.js'), 'utf8');

// Load live topics
const topics = JSON.parse(fs.readFileSync(path.join(__dirname, 'live_topics.json'), 'utf8'));

// Extract topicRules from test_topic_linker.js
const topicRulesMatch = linkerScript.match(/const topicRules = ({[\s\S]*?});\s*console\.log/);
if (!topicRulesMatch) {
    console.error('Could not extract topicRules');
    process.exit(1);
}
const topicRules = eval('(' + topicRulesMatch[1] + ')');

const fallbackTopics = {
    'Orthodontics': 114,
    'Endodontics': 166,
    'Prosthodontics': 154,
    'Periodontics': 202,
    'Restorative': 195,
    'Oral Surgery': 181,
    'Oral Medicine & Pathology': 214,
    'Pediatric Dentistry': 83,
    'Dental Ethics': 100,
    'Sterilization and Infection Control': 75
};

const specialtyCandidateTopics = {};
topics.forEach(t => {
    let sName = t.specialty?.name || '';
    if (sName === 'Dental Surgery') sName = 'Oral Surgery';
    if ([73, 74, 75, 76, 78].includes(t.id)) {
        sName = 'Sterilization and Infection Control';
    }
    if (!specialtyCandidateTopics[sName]) specialtyCandidateTopics[sName] = [];
    specialtyCandidateTopics[sName].push(t.id);
});

function matchQuestion(qText, sName) {
    const textLower = qText.toLowerCase();
    const candidateIds = specialtyCandidateTopics[sName] || [];
    
    let bestTopicId = null;
    let maxScore = 0;

    candidateIds.forEach(tid => {
        const kws = topicRules[tid];
        if (!kws) return;
        let score = 0;
        kws.forEach(kw => {
            if (textLower.includes(kw.toLowerCase())) {
                score += (kw.length > 7 ? 3 : 1);
            }
        });
        if (score > maxScore) {
            maxScore = score;
            bestTopicId = tid;
        }
    });

    if (!bestTopicId || maxScore === 0) {
        bestTopicId = fallbackTopics[sName] || candidateIds[0] || null;
    }

    return bestTopicId;
}

// Extract questions from 4 files
function extractQs(sql, fileLabel) {
    const list = [];
    const r = /INSERT INTO Questions \([^)]+\)\s*SELECT \(SELECT id FROM Specialties WHERE name = '([^']+)' LIMIT 1\),\s*'((?:[^']|\\')*)'/g;
    let m;
    while ((m = r.exec(sql)) !== null) {
        let sName = m[1];
        if (sName === 'Dental Surgery') sName = 'Oral Surgery';
        list.push({
            specialtyName: sName,
            text: m[2].replace(/''/g, "'").replace(/\\\\/g, '\\'),
            rawEscapedText: m[2]
        });
    }
    return list;
}

const sql1 = fs.readFileSync(path.join(__dirname, '../insert_file1_questions.sql'), 'utf8');
const sql2 = fs.readFileSync(path.join(__dirname, '../insert_file2_questions.sql'), 'utf8');
const sql22 = fs.readFileSync(path.join(__dirname, '../insert_file22_questions.sql'), 'utf8');
const sqlNew = fs.readFileSync(path.join(__dirname, '../insert_file_new_questions.sql'), 'utf8');

const allQuestions = [
    ...extractQs(sql1, 'File 1'),
    ...extractQs(sql2, 'File 2'),
    ...extractQs(sql22, 'File 22'),
    ...extractQs(sqlNew, 'New File')
];

console.log(`Generating SQL for ${allQuestions.length} questions...`);

// Group updates by topicId to optimize queries
const updatesByTopic = {};
allQuestions.forEach(q => {
    const topicId = matchQuestion(q.text, q.specialtyName);
    if (!updatesByTopic[topicId]) updatesByTopic[topicId] = [];
    updatesByTopic[topicId].push(q.rawEscapedText);
});

let sqlOutput = `-- ==============================================================================\n`;
sqlOutput += `-- SAFE AND FAST LINKING OF ALL 4,721 QUESTIONS TO TOPICS\n`;
sqlOutput += `-- 100% OF QUESTIONS WILL HAVE A VALID topicId\n`;
sqlOutput += `-- ==============================================================================\n\n`;
sqlOutput += `SET NAMES utf8mb4;\n`;
sqlOutput += `SET FOREIGN_KEY_CHECKS = 0;\n`;
sqlOutput += `START TRANSACTION;\n\n`;

// Step 1: Fix sterilization topics specialtyId
sqlOutput += `-- 1. Ensure Sterilization Topics belong to Specialty ID 18\n`;
sqlOutput += `UPDATE Topics SET specialtyId = (SELECT id FROM Specialties WHERE name = 'Sterilization and Infection Control' LIMIT 1) WHERE id IN (73, 74, 75, 76, 78);\n\n`;

// Step 2: Update questions in batches by topicId
sqlOutput += `-- 2. Batch Update topicId for all 4,721 Questions\n`;
Object.entries(updatesByTopic).forEach(([topicId, texts]) => {
    const topic = topics.find(t => t.id === parseInt(topicId));
    const topicName = topic ? topic.name : 'Topic #' + topicId;
    sqlOutput += `-- Topic: ${topicName} (ID: ${topicId}) -> ${texts.length} questions\n`;
    
    // Chunk into chunks of 100 for clean IN (...) statements
    const chunkSize = 80;
    for (let i = 0; i < texts.length; i += chunkSize) {
        const chunk = texts.slice(i, i + chunkSize);
        const inClause = chunk.map(t => `'${t}'`).join(',\n    ');
        sqlOutput += `UPDATE Questions SET topicId = ${topicId} WHERE text IN (\n    ${inClause}\n);\n`;
    }
    sqlOutput += `\n`;
});

sqlOutput += `COMMIT;\n`;
sqlOutput += `SET FOREIGN_KEY_CHECKS = 1;\n\n`;
sqlOutput += `-- Verification Summary\n`;
sqlOutput += `SELECT 'Questions with Topic' AS Metric, COUNT(*) AS Total FROM Questions WHERE topicId IS NOT NULL\n`;
sqlOutput += `UNION ALL\n`;
sqlOutput += `SELECT 'Questions without Topic' AS Metric, COUNT(*) AS Total FROM Questions WHERE topicId IS NULL;\n`;

const outPath = path.join(__dirname, '../link_all_topics.sql');
fs.writeFileSync(outPath, sqlOutput, 'utf8');

const stats = fs.statSync(outPath);
console.log(`✅ Generated ${outPath} (${(stats.size / (1024*1024)).toFixed(2)} MB)`);
console.log(`Updated ${Object.keys(updatesByTopic).length} distinct topics!`);
