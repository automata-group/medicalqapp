const fs = require('fs');
const path = require('path');
const mammoth = require('mammoth');

async function countDocxQuestions(filePath) {
    const resolvedPath = path.resolve(filePath);
    if (!fs.existsSync(resolvedPath)) {
        console.error(`❌ الملف غير موجود: ${resolvedPath}`);
        process.exit(1);
    }

    console.log(`\n======================================================`);
    console.log(`📖 جارٍ قراءة وتحليل ملف الوورد:`);
    console.log(`   ${path.basename(resolvedPath)}`);
    console.log(`   المسار: ${resolvedPath}`);
    console.log(`======================================================\n`);

    const result = await mammoth.convertToHtml({ path: resolvedPath });
    const html = result.value;

    // Normalize HTML to text lines
    const cleanText = html
        .replace(/<br\s*\/?>/gi, '\n')
        .replace(/<\/p>/gi, '\n\n')
        .replace(/<p>/gi, '')
        .replace(/<\/?strong>/gi, '')
        .replace(/<\/?b>/gi, '')
        .replace(/<\/?em>/gi, '')
        .replace(/<\/?i>/gi, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>');

    const rawLines = cleanText.split('\n');
    const lines = [];
    for (const l of rawLines) {
        const trimmed = l.trim();
        if (trimmed) {
            lines.push(trimmed);
        }
    }

    console.log(`📄 إجمالي الأسطر المستخرجة من الملف: ${lines.length} سطر.`);

    // State machine to parse questions
    const questions = [];
    let currentQTextLines = [];
    let currentOptions = [];
    let currentExplanation = '';
    let state = 'SEEKING_QUESTION';

    function finalizeQuestion() {
        if (currentOptions.length >= 2) {
            let qText = currentQTextLines.join(' ').trim();
            qText = qText.replace(/^\d{1,4}[\.\-\)]?\s*/, '').trim();
            qText = qText.replace(/^(أسفل النموذج|أعلى النموذج)\s*/g, '').trim();

            let hasCorrect = false;
            let correctOption = null;
            const cleanedOpts = [];
            const seenLabels = {};

            for (const opt of currentOptions) {
                let optText = opt.text;
                let isCorrect = false;
                if (optText.includes('✅') || optText.includes('*') || /[\(\[]\s*(correct|صح|إجابة صحيحة)\s*[\)\]]/i.test(optText)) {
                    isCorrect = true;
                    hasCorrect = true;
                    correctOption = opt.label;
                    optText = optText.replace(/✅|\*|[\(\[]\s*(correct|صح|إجابة صحيحة)\s*[\)\]]/gi, '').trim();
                }
                if (!seenLabels[opt.label]) {
                    seenLabels[opt.label] = true;
                    cleanedOpts.push({
                        label: opt.label,
                        text: optText,
                        isCorrect
                    });
                }
            }

            if (qText.length > 5 && cleanedOpts.length >= 2) {
                questions.push({
                    questionNumber: questions.length + 1,
                    text: qText,
                    options: cleanedOpts,
                    hasCorrectAnswer: hasCorrect,
                    correctOption: correctOption,
                    explanation: currentExplanation.trim()
                });
            }
        }
        currentQTextLines = [];
        currentOptions = [];
        currentExplanation = '';
        state = 'SEEKING_QUESTION';
    }

    const optRegex = /^([A-D|a-d])[\.\-\)]\s*(.*)$/;
    const altOptRegex = /^([أ-د])[\.\-\)]\s*(.*)$/;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];

        if (line.includes('أسفل النموذج') || line.includes('أعلى النموذج')) {
            continue;
        }

        const optMatch = line.match(optRegex) || line.match(altOptRegex);

        if (optMatch) {
            const rawLabel = optMatch[1].toUpperCase();
            let label = rawLabel;
            if (rawLabel === 'أ') label = 'A';
            if (rawLabel === 'ب') label = 'B';
            if (rawLabel === 'ج') label = 'C';
            if (rawLabel === 'د') label = 'D';

            const optText = optMatch[2] || '';

            if (state === 'IN_EXPLANATION') {
                finalizeQuestion();
            }

            // If we see Option A and we already have options, finalize previous question
            if (label === 'A' && currentOptions.length >= 2) {
                finalizeQuestion();
            }

            currentOptions.push({ label, text: optText });
            state = 'IN_OPTIONS';
        } else if (
            line.toLowerCase().startsWith('explanation:') ||
            line.toLowerCase().startsWith('expl:') ||
            line.startsWith('الشرح:') ||
            line.toLowerCase().startsWith('note:')
        ) {
            state = 'IN_EXPLANATION';
            currentExplanation += ' ' + line.replace(/^(explanation|expl|الشرح|note)\s*:\s*/i, '');
        } else if (state === 'IN_EXPLANATION') {
            const nextLineIsOption = i + 1 < lines.length && (lines[i + 1].match(optRegex) || lines[i + 1].match(altOptRegex));
            if (nextLineIsOption) {
                finalizeQuestion();
            } else {
                currentExplanation += ' ' + line;
            }
        } else if (state === 'IN_OPTIONS') {
            const nextLineIsOption = i + 1 < lines.length && (lines[i + 1].match(optRegex) || lines[i + 1].match(altOptRegex));
            const isShortContinuation = line.length < 120 && !line.includes('?') && !/^\d{1,4}[\.\-\)]/.test(line);

            if (isShortContinuation && !nextLineIsOption && currentOptions.length > 0) {
                currentOptions[currentOptions.length - 1].text += ' ' + line;
            } else {
                finalizeQuestion();
                currentQTextLines.push(line);
                state = 'IN_QUESTION';
            }
        } else {
            currentQTextLines.push(line);
            state = 'IN_QUESTION';
        }
    }

    finalizeQuestion();

    // Statistics
    const totalQuestions = questions.length;
    const withCorrect = questions.filter(q => q.hasCorrectAnswer).length;
    const with4Options = questions.filter(q => q.options.length >= 4).length;
    const withExplanation = questions.filter(q => q.explanation.length > 0).length;

    console.log(`\n======================================================`);
    console.log(`📊 النتيجة النهائية لتحليل الملف:`);
    console.log(`======================================================`);
    console.log(`🎯 إجمالي عدد الأسئلة في هذا الملف: ${totalQuestions} سؤالاً`);
    console.log(`✅ الأسئلة التي تم التعرف على إجابتها الصحيحة: ${withCorrect} سؤالاً (${((withCorrect / (totalQuestions || 1)) * 100).toFixed(1)}%)`);
    console.log(`🔢 الأسئلة التي تحتوي على 4 خيارات كاملة: ${with4Options} سؤالاً (${((with4Options / (totalQuestions || 1)) * 100).toFixed(1)}%)`);
    console.log(`💡 الأسئلة التي تحتوي على شرح توضيحي: ${withExplanation} سؤالاً`);
    console.log(`======================================================\n`);

    if (questions.length > 0) {
        console.log(`--- عينة من أول 2 سؤال في الملف ---`);
        for (let i = 0; i < Math.min(2, questions.length); i++) {
            const q = questions[i];
            console.log(`\n[سؤال #${q.questionNumber}] ${q.text}`);
            q.options.forEach(o => console.log(`   ${o.label}) ${o.text} ${o.isCorrect ? '✅ (الإجابة الصحيحة)' : ''}`));
            if (q.explanation) console.log(`   💡 الشرح: ${q.explanation}`);
        }

        console.log(`\n--- عينة من آخر سؤال في الملف ---`);
        const lastQ = questions[questions.length - 1];
        console.log(`[سؤال #${lastQ.questionNumber}] ${lastQ.text}`);
        lastQ.options.forEach(o => console.log(`   ${o.label}) ${o.text} ${o.isCorrect ? '✅ (الإجابة الصحيحة)' : ''}`));
        if (lastQ.explanation) console.log(`   💡 الشرح: ${lastQ.explanation}`);
    }

    return {
        totalQuestions,
        withCorrect,
        with4Options,
        withExplanation,
        questions
    };
}

const targetFile = process.argv[2] || path.join(__dirname, '../اساله جديده.docx');
countDocxQuestions(targetFile).catch(err => {
    console.error('❌ خطأ أثناء قراءة الملف:', err);
    process.exit(1);
});
