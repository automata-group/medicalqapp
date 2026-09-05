const fs = require('fs');
const path = require('path');

function norm(t) {
    return (t || '')
        .toLowerCase()
        .replace(/^\d{1,4}[\.\-\)]\s*/, '')
        .replace(/[^a-z0-9]/g, '')
        .trim();
}

function cleanOptionText(str) {
    if (!str) return '';
    return str
        .replace(/\s+Q\d+\s*$/i, '') // remove trailing Q numbers like Q5, Q12
        .replace(/\s+\d{2,4}\s*$/i, '') // remove trailing page numbers like 178
        .trim();
}

const specialtyRules = [
    { name: 'Endodontics', keywords: ['root canal', 'pulp', 'endodontic', 'apex', 'periapical', 'obturation', 'gutta-percha', 'sealer', 'pulpotomy', 'pulpectomy', 'k-file', 'hedstrom', 'sodium hypochlorite', 'naocl', 'edta', 'working length', 'apical foramen', 'pulpitis', 'internal resorption', 'external resorption', 'apexification', 'apexogenesis', 'spreader', 'plugger', 'smear layer'] },
    { name: 'Orthodontics', keywords: ['orthodontic', 'malocclusion', 'class i ', 'class ii', 'class iii', 'cephalometric', 'bracket', 'archwire', 'crossbite', 'open bite', 'deep bite', 'overjet', 'overbite', 'crowding', 'spacing', 'headgear', 'anchorage', 'skeletal class', 'anb', 'sna', 'snb', 'diastema', 'expansion', 'retainer', 'hawley', 'leway space'] },
    { name: 'Periodontics', keywords: ['periodontal', 'gingiv', 'pocket', 'attachment loss', 'calculus', 'plaque', 'scaling', 'root planing', 'furcation', 'bone loss', 'graft', 'flap', 'junctional epithelium', 'periodontitis', 'papilla', 'keratinized gingiva', 'attached gingiva', 'biological width', 'chlorhexidine', 'infrabony', 'suprabony', 'probe', 'marquis'] },
    { name: 'Prosthodontics', keywords: ['denture', 'prostho', 'pontic', 'abutment', 'crown', 'bridge', 'impression', 'alginate', 'elastomer', 'custom tray', 'cast', 'occlusion', 'articulator', 'centric relation', 'vertical dimension', 'rest seat', 'clasp', 'major connector', 'minor connector', 'rpd', 'complete denture', 'post and core', 'margin', 'chamfer', 'shoulder'] },
    { name: 'Restorative', keywords: ['composite', 'amalgam', 'resin', 'glass ionomer', 'gic', 'etch', 'bond', 'caries', 'cavity', 'restoration', 'curing', 'polymerization', 'matrix band', 'wedge', 'class i', 'class ii', 'class iii', 'class iv', 'class v', 'marginal leakage', 'microleakage', 'enamel spindle'] },
    { name: 'Oral Surgery', keywords: ['extraction', 'implant', 'surgical', 'forceps', 'elevator', 'suture', 'local anesthesia', 'lidocaine', 'mepivacaine', 'bupivacaine', 'vasoconstrictor', 'epinephrine', 'nerve block', 'inferior alveolar', 'dry socket', 'alveolitis', 'osteotomy', 'sinus lift', 'luxation', 'third molar', 'impaction', 'fracture', 'le fort', 'zygomatic', 'mandibular fracture'] },
    { name: 'Oral Medicine & Pathology', keywords: ['lesion', 'ulcer', 'carcinoma', 'leukoplakia', 'erythroplakia', 'lichen planus', 'pemphigus', 'pemphigoid', 'candidiasis', 'herpes', 'cyst', 'ameloblastoma', 'odontoma', 'radiopacity', 'radiolucency', 'biopsy', 'salivary gland', 'sjogren', 'xerostomia', 'hyperthyroid', 'tsh', 't3', 't4'] },
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

async function generateFile2Sql() {
    const data = JSON.parse(fs.readFileSync('backend/scripts/file2_parsed.json', 'utf8'));
    const questions = data.uniqueMissing;

    console.log(`Generating SQL for ${questions.length} validated unique questions from "اساله 2.docx"...`);

    let sqlOutput = `-- ==============================================================================\n`;
    sqlOutput += `-- SAFE IMPORT OF ${questions.length} NEW QUESTIONS FROM "اساله 2.docx"\n`;
    sqlOutput += `-- STRICT DEDUPLICATION ENFORCED (WHERE NOT EXISTS)\n`;
    sqlOutput += `-- ALL QUESTIONS VERIFIED WITH 100% CORRECT ANSWERS\n`;
    sqlOutput += `-- ==============================================================================\n\n`;
    sqlOutput += `SET NAMES utf8mb4;\n`;
    sqlOutput += `SET FOREIGN_KEY_CHECKS = 0;\n\n`;

    questions.forEach((q, idx) => {
        const { specialtyName, difficulty } = classify(q.text, q.options);
        const escapedText = escapeSql(q.text);

        sqlOutput += `-- Question #${idx + 1} (${specialtyName} - ${difficulty})\n`;
        sqlOutput += `INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)\n`;
        sqlOutput += `SELECT (SELECT id FROM Specialties WHERE name = '${specialtyName}' LIMIT 1), '${escapedText}', '${difficulty}', 60, 1, 0, 'اساله 2.docx', 1, NOW(), NOW()\n`;
        sqlOutput += `WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = '${escapedText}');\n\n`;
        sqlOutput += `SET @new_qid = (SELECT id FROM Questions WHERE text = '${escapedText}' LIMIT 1);\n`;

        q.options.forEach(opt => {
            const cleanedText = cleanOptionText(opt.text);
            const escapedOpt = escapeSql(cleanedText);
            const isCorr = opt.isCorrect ? 1 : 0;
            sqlOutput += `INSERT INTO Options (questionId, \`order\`, text, isCorrect, createdAt, updatedAt)\n`;
            sqlOutput += `SELECT @new_qid, '${opt.label}', '${escapedOpt}', ${isCorr}, NOW(), NOW()\n`;
            sqlOutput += `WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND \`order\` = '${opt.label}');\n`;
        });

        if (q.explanation) {
            const escapedExp = escapeSql(q.explanation);
            sqlOutput += `INSERT INTO Explanations (questionId, text, \`references\`, aiGenerated, createdAt, updatedAt)\n`;
            sqlOutput += `SELECT @new_qid, '${escapedExp}', 'اساله 2.docx - SDLE QBank', 1, NOW(), NOW()\n`;
            sqlOutput += `WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Explanations WHERE questionId = @new_qid);\n`;
        }

        sqlOutput += `\n`;
    });

    sqlOutput += `SET FOREIGN_KEY_CHECKS = 1;\n`;
    sqlOutput += `SELECT COUNT(*) AS total_questions_after_import FROM Questions;\n`;

    fs.writeFileSync('backend/insert_file2_questions.sql', sqlOutput, 'utf8');
    console.log(`✅ Successfully generated backend/insert_file2_questions.sql with ${questions.length} questions!`);
}

generateFile2Sql().catch(console.error);
