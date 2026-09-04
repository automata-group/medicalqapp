const fs = require('fs');
const path = require('path');
const mammoth = require('mammoth');

function norm(t) {
    return (t || '')
        .toLowerCase()
        .replace(/^\d{1,4}[\.\-\)]\s*/, '')
        .replace(/[^a-z0-9]/g, '')
        .trim();
}

async function analyze() {
    // 1. Read already uploaded SQL files (Batch 1 + Batch 2)
    const sql1 = fs.readFileSync('backend/insert_1137_questions_production.sql', 'utf8');
    const sql2 = fs.readFileSync('backend/insert_second_file_production.sql', 'utf8');

    const dbQuestions = new Set();
    const regex = /INSERT INTO Questions \([^)]+\) VALUES \([^,]+, '((?:[^']|'')*)'/g;

    let m;
    while ((m = regex.exec(sql1)) !== null) {
        dbQuestions.add(norm(m[1].replace(/''/g, "'")));
    }
    const countSql1 = dbQuestions.size;
    console.log(`Questions loaded from SQL 1: ${countSql1}`);

    let countFromSql2 = 0;
    while ((m = regex.exec(sql2)) !== null) {
        const text = norm(m[1].replace(/''/g, "'"));
        if (!dbQuestions.has(text)) {
            countFromSql2++;
        }
        dbQuestions.add(text);
    }
    console.log(`New questions added from SQL 2: ${countFromSql2}`);
    console.log(`Total unique questions in DB from both files: ${dbQuestions.size}`);

    // 2. Parse all questions from "اساله جديده.docx"
    const docxPath = 'اساله جديده.docx';
    const result = await mammoth.convertToHtml({ path: docxPath });
    const cleanText = result.value
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
            if (label === 'A' && currentOptions.length >= 2) {
                finalize();
            }
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

    console.log(`\nDocx Parsed Questions: ${docxQuestions.length}`);

    // Check which ones are in DB vs which ones are NOT
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

    console.log(`Already in DB (Duplicates): ${alreadyInDb.length}`);
    console.log(`MISSING from DB (Truly New Questions): ${missingFromDb.length}`);

    if (missingFromDb.length > 0) {
        console.log(`\nSample missing questions:`);
        missingFromDb.slice(0, 5).forEach((q, idx) => {
            console.log(`--- [Missing ${idx + 1}] ---`);
            console.log(`Text: ${q.text.slice(0, 100)}...`);
            console.log(`Options: ${q.options.length} (hasCorrect: ${q.hasCorrect})`);
        });
    }
}

analyze().catch(console.error);
