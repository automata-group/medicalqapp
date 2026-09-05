const fs = require('fs');
const mammoth = require('../node_modules/mammoth');

async function inspectBoundaries() {
    const res = await mammoth.convertToHtml({ path: 'اساله جديده 22.docx' });
    const html = res.value;

    const cleanText = html
        .replace(/<br\s*\/?>/gi, '\n')
        .replace(/<\/p>/gi, '\n\n')
        .replace(/<p>/gi, '')
        .replace(/<\/?strong>/gi, '')
        .replace(/<\/?b>/gi, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>');

    const lines = cleanText.split('\n').map(l => l.trim()).filter(Boolean);

    // Let's check how many options A, B, C, D exist
    let countA = 0, countB = 0, countC = 0, countD = 0;
    const optRegex = /^([A-D|a-d])[\.\-\)]\s*(.*)$/;

    lines.forEach(l => {
        const m = l.match(optRegex);
        if (m) {
            const letter = m[1].toUpperCase();
            if (letter === 'A') countA++;
            if (letter === 'B') countB++;
            if (letter === 'C') countC++;
            if (letter === 'D') countD++;
        }
    });

    console.log(`Option Counts in 22.docx:
      A: ${countA}
      B: ${countB}
      C: ${countC}
      D: ${countD}
    `);

    // Let's also check what questions were already in `insert_1137_questions_production.sql`
    const sql1 = fs.readFileSync('backend/insert_1137_questions_production.sql', 'utf8');
    const sql1Lines = sql1.split('\n').filter(l => l.includes('INSERT INTO Questions'));
    console.log(`Questions originally in insert_1137_questions_production.sql: ${sql1Lines.length}`);
}

inspectBoundaries().catch(console.error);
