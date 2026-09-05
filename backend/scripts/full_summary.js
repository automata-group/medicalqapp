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

async function parseDocx(fileName) {
    const res = await mammoth.convertToHtml({ path: fileName });
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
    const questions = [];
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
                questions.push({
                    text: qText,
                    norm: norm(qText),
                    options: cleanedOpts,
                    hasCorrect
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
    return questions;
}

async function fullSummary() {
    console.log('Reading File 1: اساله جديده 22.docx ...');
    const f1 = await parseDocx('اساله جديده 22.docx');

    console.log('Reading File 2: اساله جديده.docx ...');
    const f2 = await parseDocx('اساله جديده.docx');

    // Sets
    const set1 = new Set(f1.map(q => q.norm));
    const set2 = new Set(f2.map(q => q.norm));

    // Shared between both files
    let sharedCount = 0;
    f1.forEach(q => {
        if (set2.has(q.norm)) sharedCount++;
    });

    // Unique across both files
    const allUnique = new Set([...set1, ...set2]);

    console.log('\n======================================================');
    console.log('📊 COMPREHENSIVE OVERVIEW OF BOTH WORD FILES:');
    console.log('======================================================');
    console.log(`1️⃣ File 1 ("اساله جديده 22.docx"):     ${f1.length} questions`);
    console.log(`2️⃣ File 2 ("اساله جديده.docx"):        ${f2.length} questions`);
    console.log(`🔁 Duplicate questions shared in BOTH: ${sharedCount} questions`);
    console.log(`✨ Total UNIQUE questions across BOTH: ${allUnique.size} questions`);
    console.log('======================================================\n');
}

fullSummary().catch(console.error);
