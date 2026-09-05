const fs = require('fs');
const mammoth = require('../node_modules/mammoth');

async function findInDocx() {
    const list = JSON.parse(fs.readFileSync('backend/scripts/the_17_questions.json', 'utf8'));
    const res = await mammoth.extractRawText({ path: 'اساله جديده.docx' });
    const text = res.value;

    const results = [];
    list.forEach(q => {
        // Search for snippet of question text
        const snippet = q.text.slice(0, 40).replace(/[^a-zA-Z0-9 ]/g, '');
        const pos = text.indexOf(snippet.slice(0, 30));
        if (pos !== -1) {
            // grab 500 characters around it
            const slice = text.slice(pos, pos + 500).replace(/\r/g, '').split('\n').filter(Boolean).slice(0, 6).join('\n');
            results.push({
                num: q.num,
                snippet,
                slice
            });
        } else {
            results.push({
                num: q.num,
                snippet,
                slice: 'NOT FOUND'
            });
        }
    });

    console.log(`Found ${results.length} questions in docx raw text:`);
    results.forEach(r => {
        console.log(`\n================== Q #${r.num} ==================`);
        console.log(r.slice);
    });
}

findInDocx().catch(console.error);
