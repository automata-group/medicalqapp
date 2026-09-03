const fs = require('fs');

const raw = fs.readFileSync('cleaned_docx_text.txt', 'utf8');

// We can parse the document line by line!
// A question consists of:
// - Question Text (one or more lines)
// - Options (lines starting with A., B., C., D., E.)
// - Optional Explanation/Note lines (lines starting with Note:, Explanation:, etc.)
// - Separator/garbage lines like "أسفل النموذج", "أعلى النموذج", "ss", etc.

const lines = raw.split('\n');

const questions = [];
let currentQTextLines = [];
let currentOptions = [];
let currentExplanation = '';
let state = 'SEEKING_QUESTION'; // 'SEEKING_QUESTION', 'SEEKING_OPTIONS'

function finalizeQuestion() {
    if (currentOptions.length >= 2) {
        let qText = currentQTextLines.join(' ').trim();
        // Remove leading numbers like "58.", "58 - ", "58)"
        qText = qText.replace(/^\d{1,4}[\.\-\)]?\s*/, '').trim();
        // Remove garbage words
        qText = qText.replace(/^(أسفل النموذج|أعلى النموذج)\s*/g, '').trim();

        // Ensure we have exactly 1 correct option if marked
        let hasCorrect = false;
        const cleanedOpts = [];
        const seenLabels = {};

        for (const opt of currentOptions) {
            let optText = opt.text;
            let isCorrect = false;
            if (optText.includes('✅') || optText.includes('*')) {
                isCorrect = true;
                hasCorrect = true;
                optText = optText.replace(/✅|\*/g, '').trim();
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

const optLineRegex = /^\s*([A-E])[\.\)]\s*(.*)$/;

for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;

    // Skip form boilerplate
    if (line === 'أسفل النموذج' || line === 'أعلى النموذج' || line === 'ss') {
        continue;
    }

    const optMatch = line.match(optLineRegex);

    if (optMatch) {
        const label = optMatch[1];
        const text = optMatch[2].trim();

        // If we see an 'A' and we already have options including an 'A', finalize previous question!
        if (label === 'A' && currentOptions.some(o => o.label === 'A')) {
            finalizeQuestion();
        }

        currentOptions.push({ label, text });
        state = 'SEEKING_OPTIONS';
    } else {
        // It's a non-option line
        if (state === 'SEEKING_OPTIONS') {
            // Did we just finish options and encounter a note?
            if (line.toLowerCase().startsWith('note:') || line.toLowerCase().startsWith('explanation:')) {
                currentExplanation += ' ' + line;
            } else {
                // It's the start of a new question!
                finalizeQuestion();
                currentQTextLines.push(line);
                state = 'SEEKING_QUESTION';
            }
        } else {
            // We are gathering question text
            currentQTextLines.push(line);
        }
    }
}

// Finalize last question
finalizeQuestion();

console.log(`Total questions parsed with state-machine: ${questions.length}`);
let correctCount = 0;
questions.forEach(q => { if (q.hasCorrect) correctCount++; });
console.log(`Questions with correct answer: ${correctCount}`);

// Check any question with duplicate labels
let dups = 0;
questions.forEach((q, i) => {
    const labels = {};
    q.options.forEach(o => {
        if (labels[o.label]) dups++;
        labels[o.label] = true;
    });
});
console.log(`Questions with duplicate option labels: ${dups}`);

fs.writeFileSync('all_questions_state_machine.json', JSON.stringify(questions, null, 2), 'utf8');
console.log('Saved all_questions_state_machine.json');
process.exit(0);
