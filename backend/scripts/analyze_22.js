const fs = require('fs');
const path = require('path');
const mammoth = require('../node_modules/mammoth');

function norm(t) {
    return (t || '')
        .toLowerCase()
        .replace(/^\d{1,4}[\.\-\)]\s*/, '')
        .replace(/[^a-z0-9]/g, '')
        .trim();
}

async function analyze22() {
    const filePath = path.join(__dirname, '../../اساله جديده 22.docx');
    if (!fs.existsSync(filePath)) {
        console.error('File not found:', filePath);
        return;
    }

    console.log('======================================================');
    console.log('🔍 ANALYZING: اساله جديده 22.docx');
    console.log('======================================================\n');

    const res = await mammoth.convertToHtml({ path: filePath });
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
            let qText = currentQTextLines.join(' ').trim();
            qText = qText.replace(/^\d{1,4}[\.\-\)]?\s*/, '').trim();
            qText = qText.replace(/^(أسفل النموذج|أعلى النموذج)\s*/g, '').trim();

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
                docxQuestions.push({
                    text: qText,
                    options: cleanedOpts,
                    hasCorrect,
                    explanation: currentExplanation.trim()
                });
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

    console.log(`📄 Total Parsed Questions in "اساله جديده 22.docx": ${docxQuestions.length}`);
    const noAnswer = docxQuestions.filter(q => !q.hasCorrect);
    console.log(`⚠️ Questions WITHOUT explicit correct answer:     ${noAnswer.length}`);
    console.log(`✅ Questions WITH explicit correct answer:        ${docxQuestions.length - noAnswer.length}`);

    // Load existing DB questions
    const sql1 = fs.readFileSync(path.join(__dirname, '../insert_1137_questions_production.sql'), 'utf8');
    const sql2 = fs.readFileSync(path.join(__dirname, '../insert_second_file_production.sql'), 'utf8');
    const sql3 = fs.readFileSync(path.join(__dirname, '../insert_missing_questions.sql'), 'utf8');

    const dbQuestions = new Set();
    const regex = /INSERT INTO Questions \([^)]+\) VALUES \([^,]+, '((?:[^']|'')*)'/g;
    let m;
    while ((m = regex.exec(sql1)) !== null) dbQuestions.add(norm(m[1].replace(/''/g, "'")));
    while ((m = regex.exec(sql2)) !== null) dbQuestions.add(norm(m[1].replace(/''/g, "'")));

    const qInSql3 = sql3.split('INSERT INTO Questions').slice(1);
    qInSql3.forEach(block => {
        const tm = block.match(/LIMIT 1\),\s*'([\s\S]*?)',\s*'(?:easy|medium|hard)'/);
        if (tm) dbQuestions.add(norm(tm[1].replace(/\\'/g, "'").replace(/''/g, "'")));
    });

    console.log(`\n🗄️ Total unique questions in DB reference:        ${dbQuestions.size}`);

    const alreadyInDb = [];
    const missingFromDb = [];

    docxQuestions.forEach(q => {
        const n = norm(q.text);
        if (dbQuestions.has(n)) {
            alreadyInDb.push(q);
        } else {
            missingFromDb.push(q);
        }
    });

    console.log(`\n======================================================`);
    console.log(`📊 DEDUPLICATION COMPARISON FOR "اساله جديده 22.docx":`);
    console.log(`======================================================`);
    console.log(`🔁 Already in DB (Duplicates):                    ${alreadyInDb.length}`);
    console.log(`✨ MISSING from DB (New questions to upload):      ${missingFromDb.length}`);
    console.log(`======================================================\n`);

    if (missingFromDb.length > 0) {
        console.log(`Sample missing questions (${missingFromDb.length} total):`);
        missingFromDb.slice(0, 5).forEach((q, idx) => {
            console.log(`--- [Missing #${idx + 1}] hasCorrect: ${q.hasCorrect} ---`);
            console.log(`Text: ${q.text.slice(0, 100)}...`);
            console.log(`Options (${q.options.length}):`);
            q.options.forEach(o => console.log(`  ${o.label}) ${o.text} ${o.isCorrect ? '✅' : ''}`));
        });
    }

    if (noAnswer.length > 0) {
        console.log(`\nSample questions lacking answer (${noAnswer.length} total):`);
        noAnswer.slice(0, 5).forEach((q, idx) => {
            console.log(`--- [No Answer #${idx + 1}] ---`);
            console.log(`Text: ${q.text.slice(0, 100)}...`);
            q.options.forEach(o => console.log(`  ${o.label}) ${o.text}`));
        });
    }
}

analyze22().catch(console.error);
