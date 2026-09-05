const fs = require('fs');
const mammoth = require('mammoth');

function norm(t) {
    return (t || '').toLowerCase().replace(/^\d{1,4}[\.\-\)]\s*/, '').replace(/[^a-z0-9]/g, '').trim();
}

const specialtyRules = [
    { name: 'Endodontics', keywords: ['root canal', 'pulp', 'endodontic', 'apex', 'periapical', 'obturation', 'gutta-percha', 'sealer', 'pulpotomy', 'pulpectomy', 'k-file', 'hedstrom', 'sodium hypochlorite', 'naocl', 'edta', 'working length', 'apical foramen', 'pulpitis', 'internal resorption', 'external resorption', 'apexification', 'apexogenesis', 'spreader', 'plugger', 'smear layer'] },
    { name: 'Orthodontics', keywords: ['orthodontic', 'malocclusion', 'class i ', 'class ii', 'class iii', 'cephalometric', 'bracket', 'archwire', 'crossbite', 'open bite', 'deep bite', 'overjet', 'overbite', 'crowding', 'spacing', 'headgear', 'anchorage', 'skeletal class', 'anb', 'sna', 'snb', 'diastema', 'expansion', 'retainer', 'hawley', 'leway space'] },
    { name: 'Periodontics', keywords: ['periodontal', 'gingiv', 'pocket', 'attachment loss', 'calculus', 'plaque', 'scaling', 'root planing', 'furcation', 'bone loss', 'graft', 'flap', 'junctional epithelium', 'periodontitis', 'papilla', 'keratinized gingiva', 'attached gingiva', 'biological width', 'chlorhexidine', 'infrabony', 'suprabony'] },
    { name: 'Prosthodontics', keywords: ['denture', 'prostho', 'pontic', 'abutment', 'crown', 'bridge', 'impression', 'alginate', 'elastomer', 'custom tray', 'cast', 'occlusion', 'articulator', 'centric relation', 'vertical dimension', 'rest seat', 'clasp', 'major connector', 'minor connector', 'rpd', 'complete denture', 'post and core', 'margin', 'chamfer', 'shoulder'] },
    { name: 'Restorative', keywords: ['composite', 'amalgam', 'resin', 'glass ionomer', 'gic', 'etch', 'bond', 'caries', 'cavity', 'restoration', 'curing', 'polymerization', 'matrix band', 'wedge', 'class i', 'class ii', 'class iii', 'class iv', 'class v', 'marginal leakage', 'microleakage'] },
    { name: 'Oral Surgery', keywords: ['extraction', 'implant', 'surgical', 'forceps', 'elevator', 'suture', 'local anesthesia', 'lidocaine', 'mepivacaine', 'bupivacaine', 'vasoconstrictor', 'epinephrine', 'nerve block', 'inferior alveolar', 'dry socket', 'alveolitis', 'osteotomy', 'sinus lift', 'luxation', 'third molar', 'impaction', 'fracture', 'le fort', 'zygomatic', 'mandibular fracture'] },
    { name: 'Oral Medicine & Pathology', keywords: ['lesion', 'ulcer', 'carcinoma', 'leukoplakia', 'erythroplakia', 'lichen planus', 'pemphigus', 'pemphigoid', 'candidiasis', 'herpes', 'cyst', 'ameloblastoma', 'odontoma', 'radiopacity', 'radiolucency', 'biopsy', 'salivary gland', 'sjogren', 'xerostomia'] },
    { name: 'Pediatric Dentistry', keywords: ['primary tooth', 'primary teeth', 'deciduous', 'child', 'pediatric', 'space maintainer', 'stainless steel crown', 'ssc', 'formocresol', 'mta in primary', 'early childhood caries', 'ecc', 'eruption', 'fluoride varnish'] },
    { name: 'Dental Ethics', keywords: ['ethics', 'consent', 'informed consent', 'confidentiality', 'autonomy', 'beneficence', 'non-maleficence', 'justice', 'veracity', 'malpractice', 'negligence', 'patient rights', 'criticism of a colleague', 'conflict of interest', 'paternalism', 'surrogate'] },
    { name: 'Sterilization and Infection Control', keywords: ['autoclave', 'sterilization', 'disinfection', 'disinfect', 'ppe', 'sharps', 'needlestick', 'hazard', 'infection control', 'spore test', 'biological indicator', 'chemical indicator', 'dry heat', 'ethylene oxide', 'glutaraldehyde', 'hand hygiene', 'cross contamination', 'cross-contamination', 'barrier', 'post-exposure prophylaxis', 'osha', 'cdc', 'standard precautions', 'asepsis', 'aseptic', 'quaternary ammonium', 'steam under pressure', 'critical instruments', 'semi-critical', 'non-critical'] }
];

function classify(qText, options) {
    const full = (qText + ' ' + options.map(o => o.text).join(' ')).toLowerCase();
    let best = null;
    let max = -1;
    specialtyRules.forEach(r => {
        let score = 0;
        r.keywords.forEach(k => {
            if (full.includes(k.toLowerCase())) score += k.length > 7 ? 2 : 1;
        });
        if (score > max) {
            max = score;
            best = r;
        }
    });
    if (max <= 0 || !best) best = specialtyRules.find(r => r.name === 'Restorative');
    let difficulty = 'medium';
    if (qText.length > 250) difficulty = 'hard';
    else if (qText.length < 90) difficulty = 'easy';
    return { specialtyName: best.name, difficulty };
}

function escapeSql(str) {
    if (!str) return '';
    return str.replace(/'/g, "''").replace(/\\/g, '\\\\');
}

async function generateMissingSql() {
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

    // Filter missing and ensure they are real questions (must have valid text and at least 1 correct option)
    const validMissing = [];
    docxQuestions.forEach(q => {
        if (!dbQuestions.has(norm(q.text))) {
            // Check if it has a correct answer or if it's not just a note
            if (q.hasCorrect && q.options.length >= 2 && q.text.length > 15) {
                validMissing.push(q);
            }
        }
    });

    console.log(`Valid, verified missing questions: ${validMissing.length}`);

    // Build SQL statements
    let sqlOutput = `-- ==============================================================================\n`;
    sqlOutput += `-- SAFE IMPORT OF ${validMissing.length} MISSING QUESTIONS (STRICT DEDUPLICATION)\n`;
    sqlOutput += `-- Source: اساله جديده.docx\n`;
    sqlOutput += `-- ==============================================================================\n\n`;
    sqlOutput += `SET NAMES utf8mb4;\n`;
    sqlOutput += `SET FOREIGN_KEY_CHECKS = 0;\n\n`;

    validMissing.forEach((q, idx) => {
        const { specialtyName, difficulty } = classify(q.text, q.options);
        const escapedText = escapeSql(q.text);

        sqlOutput += `-- Question #${idx + 1} (${specialtyName} - ${difficulty})\n`;
        sqlOutput += `INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)\n`;
        sqlOutput += `SELECT (SELECT id FROM Specialties WHERE name = '${specialtyName}' LIMIT 1), '${escapedText}', '${difficulty}', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()\n`;
        sqlOutput += `WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = '${escapedText}');\n\n`;
        sqlOutput += `SET @new_qid = (SELECT id FROM Questions WHERE text = '${escapedText}' LIMIT 1);\n`;

        // If newly inserted
        q.options.forEach(opt => {
            const escapedOpt = escapeSql(opt.text);
            const isCorr = opt.isCorrect ? 1 : 0;
            sqlOutput += `INSERT INTO Options (questionId, \`order\`, text, isCorrect, createdAt, updatedAt)\n`;
            sqlOutput += `SELECT @new_qid, '${opt.label}', '${escapedOpt}', ${isCorr}, NOW(), NOW()\n`;
            sqlOutput += `WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND \`order\` = '${opt.label}');\n`;
        });

        if (q.explanation) {
            const escapedExp = escapeSql(q.explanation);
            sqlOutput += `INSERT INTO Explanations (questionId, text, \`references\`, aiGenerated, createdAt, updatedAt)\n`;
            sqlOutput += `SELECT @new_qid, '${escapedExp}', 'اساله جديده.docx - SDLE QBank', 1, NOW(), NOW()\n`;
            sqlOutput += `WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Explanations WHERE questionId = @new_qid);\n`;
        }

        sqlOutput += `\n`;
    });

    sqlOutput += `SET FOREIGN_KEY_CHECKS = 1;\n`;
    sqlOutput += `SELECT COUNT(*) AS total_questions_after_import FROM Questions;\n`;

    fs.writeFileSync('backend/insert_missing_questions.sql', sqlOutput, 'utf8');
    console.log(`✅ Successfully generated backend/insert_missing_questions.sql with ${validMissing.length} questions.`);
}

generateMissingSql().catch(console.error);
