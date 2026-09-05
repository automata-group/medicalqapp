const fs = require('fs');
const path = require('path');

const content = fs.readFileSync('backend/insert_second_file_production.sql', 'utf8');
const blocks = content.split('SET @new_qid = LAST_INSERT_ID();');
const missing = [];

for (let i = 1; i < blocks.length; i++) {
    const block = blocks[i];
    const optionLines = block.split('\n').filter(l => l.includes('INSERT INTO Options'));
    const hasCorrect = optionLines.some(l => /,\s*1,\s*NOW\(\),\s*NOW\(\)\);/.test(l));
    if (!hasCorrect) {
        const prev = blocks[i - 1];
        const lines = prev.trim().split('\n');
        const qLine = lines.find(l => l.includes('INSERT INTO Questions'));
        const textMatch = qLine.match(/LIMIT 1\),\s*'([\s\S]*?)',\s*'(?:easy|medium|hard)',\s*60/);

        const opts = [];
        optionLines.forEach(opt => {
            const m = opt.match(/VALUES \(@new_qid,\s*'([A-D])',\s*'([\s\S]*?)',\s*0/);
            if (m) opts.push({ label: m[1], text: m[2].replace(/\\'/g, "'") });
        });

        missing.push({
            num: i,
            text: textMatch ? textMatch[1].replace(/\\'/g, "'") : qLine,
            options: opts
        });
    }
}

console.log('Total questions with NO correct answer in second file:', missing.length);
fs.writeFileSync('backend/scripts/the_17_questions.json', JSON.stringify(missing, null, 2));
console.log('Saved to backend/scripts/the_17_questions.json');
