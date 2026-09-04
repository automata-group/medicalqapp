const fs = require('fs');
const mammoth = require('mammoth');

function norm(t) {
    return (t || '').toLowerCase().replace(/^\d{1,4}[\.\-\)]\s*/, '').replace(/[^a-z0-9]/g, '').trim();
}

async function run() {
    const sql1 = fs.readFileSync('backend/insert_1137_questions_production.sql', 'utf8');
    const sql2 = fs.readFileSync('backend/insert_second_file_production.sql', 'utf8');
    const dbQuestions = new Set();
    const regex = /INSERT INTO Questions \([^)]+\) VALUES \([^,]+, '((?:[^']|'')*)'/g;
    let m;
    while ((m = regex.exec(sql1)) !== null) dbQuestions.add(norm(m[1].replace(/''/g, "'")));
    while ((m = regex.exec(sql2)) !== null) dbQuestions.add(norm(m[1].replace(/''/g, "'")));

    const res = await mammoth.convertToHtml({ path: 'اساله جديده.docx' });
    const cleanText = res.value
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
    const docxQuestions = [];
    let currentQTextLines = [];
    let currentOptions = [];
    let currentExplanation = '';

    function finalize() {
        if (currentOptions.length >= 2) {
            let qText = currentQTextLines.join(' ').trim().replace(/^\d{1,4}[\.\-\)]?\s*/, '').trim().replace(/^(أسفل النموذج|أعلى النموذج)\s*/g, '').trim();
            let hasCorrect = false;
            const cleanedOpts = [];
            for (const opt of currentOptions) {
                let text = opt.text;
                let isCorrect = false;
                if (text.includes('✅') || text.includes('*') || /[\(\[]\s*(correct|صح)\s*[\)\]]/i.test(text)) {
                    isCorrect = true;
                    hasCorrect = true;
                    text = text.replace(/✅|\*|[\(\[]\s*(correct|صح)\s*[\)\]]/gi, '').trim();
                }
                cleanedOpts.push({ label: opt.label, text, isCorrect });
            }
            if (qText.length > 5 && cleanedOpts.length >= 2) {
                docxQuestions.push({ text: qText, options: cleanedOpts, hasCorrect, explanation: currentExplanation.trim() });
            }
        }
        currentQTextLines = [];
        currentOptions = [];
        currentExplanation = '';
    }

    const optRegex = /^([A-D|a-d])[\.\-\)]\s*(.*)$/;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.includes('أسفل النموذج') || line.includes('أعلى النموذج')) continue;
        const optMatch = line.match(optRegex);
        if (optMatch) {
            const label = optMatch[1].toUpperCase();
            if (label === 'A' && currentOptions.length >= 2) finalize();
            currentOptions.push({ label, text: optMatch[2] || '' });
        } else if (line.toLowerCase().startsWith('explanation:') || line.startsWith('الشرح:')) {
            currentExplanation += ' ' + line.replace(/^(explanation|الشرح)\s*:\s*/i, '');
        } else if (currentOptions.length > 0) {
            const nextIsOpt = i + 1 < lines.length && lines[i + 1].match(optRegex);
            if (line.length < 100 && !line.includes('?') && !nextIsOpt) {
                currentOptions[currentOptions.length - 1].text += ' ' + line;
            } else {
                finalize();
                currentQTextLines.push(line);
            }
        } else {
            currentQTextLines.push(line);
        }
    }
    finalize();

    const missing = docxQuestions.filter(q => !dbQuestions.has(norm(q.text)));
    console.log('Total missing:', missing.length);
    let noCorrect = 0;
    missing.forEach((q, i) => {
        if (!q.hasCorrect) {
            noCorrect++;
            console.log(`[Missing without correct mark #${i + 1}]: ${q.text.slice(0, 80)}`);
        }
    });
    console.log('Missing without explicit correct mark:', noCorrect);
}
run();
