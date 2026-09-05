const fs = require('fs');

function norm(t) {
    return (t || '')
        .toLowerCase()
        .replace(/^\d{1,4}[\.\-\)]\s*/, '')
        .replace(/[^a-z0-9]/g, '')
        .trim();
}

const sql1 = fs.readFileSync('backend/insert_1137_questions_production.sql', 'utf8');
const missing22 = fs.readFileSync('backend/insert_missing_22_questions.sql', 'utf8');

const s1Set = new Set();
const regex = /INSERT INTO Questions \([^)]+\) VALUES \([^,]+, '((?:[^']|'')*)'/g;
let m;
while ((m = regex.exec(sql1)) !== null) {
    s1Set.add(norm(m[1].replace(/''/g, "'")));
}

console.log('Total questions in sql1:', s1Set.size);

const qBlocks = missing22.split('INSERT INTO Questions').slice(1);
console.log('Total questions in missing22:', qBlocks.length);

let foundInSql1 = 0;
let notFoundInSql1 = 0;

qBlocks.forEach((b, idx) => {
    const tm = b.match(/LIMIT 1\),\s*'([\s\S]*?)',\s*'(?:easy|medium|hard)'/);
    if (tm) {
        const text = tm[1];
        const n = norm(text);
        if (s1Set.has(n)) {
            foundInSql1++;
        } else {
            notFoundInSql1++;
            console.log(`[Missing from sql1 #${idx + 1}]: ${text.slice(0, 80)}`);
        }
    }
});

console.log(`In SQL1: ${foundInSql1}, NOT in SQL1: ${notFoundInSql1}`);
