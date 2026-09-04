const fs = require('fs');
const path = require('path');
const mammoth = require('mammoth');
require('dotenv').config();
const { Question, Option, Explanation, Specialty, sequelize } = require('../src/models');

// Classification rules for the 9 dental specialties
const specialtyRules = [
    {
        name: 'Endodontics',
        keywords: [
            'root canal', 'pulp', 'endodontic', 'apex', 'periapical', 'obturation',
            'gutta-percha', 'sealer', 'pulpotomy', 'pulpectomy', 'k-file', 'hedstrom',
            'sodium hypochlorite', 'naocl', 'edta', 'working length', 'apical foramen',
            'pulpitis', 'internal resorption', 'external resorption', 'apexification',
            'apexogenesis', 'spreader', 'plugger', 'smear layer'
        ]
    },
    {
        name: 'Orthodontics',
        keywords: [
            'orthodontic', 'malocclusion', 'class i ', 'class ii', 'class iii',
            'cephalometric', 'bracket', 'archwire', 'crossbite', 'open bite', 'deep bite',
            'overjet', 'overbite', 'crowding', 'spacing', 'headgear', 'anchorage',
            'skeletal class', 'anb', 'sna', 'snb', 'diastema', 'expansion',
            'retainer', 'hawley', 'leway space', 'angulation of tooth'
        ]
    },
    {
        name: 'Periodontics',
        keywords: [
            'periodontal', 'gingiv', 'pocket', 'attachment loss', 'calculus',
            'plaque', 'scaling', 'root planing', 'furcation', 'bone loss',
            'graft', 'flap', 'junctional epithelium', 'periodontitis', 'papilla',
            'keratinized gingiva', 'attached gingiva', 'biological width', 'chlorhexidine',
            'infrabony', 'suprabony', 'frenum', 'frenectomy', 'mucogingival'
        ]
    },
    {
        name: 'Prosthodontics',
        keywords: [
            'denture', 'prostho', 'pontic', 'abutment', 'crown', 'bridge',
            'impression', 'alginate', 'elastomer', 'custom tray', 'cast',
            'occlusion', 'articulator', 'centric relation', 'vertical dimension',
            'rest seat', 'clasp', 'major connector', 'minor connector', 'rpd',
            'complete denture', 'post and core', 'margin', 'chamfer', 'shoulder',
            'retromolar pad', 'post dam', 'vibrating line', 'facebow'
        ]
    },
    {
        name: 'Restorative',
        keywords: [
            'composite', 'amalgam', 'resin', 'glass ionomer', 'gic', 'etch',
            'bond', 'caries', 'cavity', 'restoration', 'curing', 'polymerization',
            'matrix band', 'wedge', 'class i', 'class ii', 'class iii', 'class iv', 'class v',
            'marginal leakage', 'microleakage', 'smear layer', 'hybrid layer', 'bleaching'
        ]
    },
    {
        name: 'Dental Surgery',
        keywords: [
            'extraction', 'implant', 'surgical', 'forceps', 'elevator', 'suture',
            'local anesthesia', 'lidocaine', 'mepivacaine', 'bupivacaine', 'vasoconstrictor',
            'epinephrine', 'nerve block', 'inferior alveolar', 'dry socket',
            'alveolitis', 'osteotomy', 'flap design', 'biopsy', 'sinus lift',
            'luxation', 'third molar', 'impaction', 'bleeding', 'socket preservation'
        ]
    },
    {
        name: 'Oral Medicine & Pathology',
        keywords: [
            'lesion', 'ulcer', 'carcinoma', 'leukoplakia', 'erythroplakia',
            'lichen planus', 'pemphigus', 'pemphigoid', 'candidiasis', 'herpes',
            'cyst', 'ameloblastoma', 'odontoma', 'radiopacity', 'radiolucency',
            'biopsy', 'salivary gland', 'sjogren', 'xerostomia', 'syndrome',
            'osteosarcoma', 'necrosis', 'burning mouth', 'aphthous', 'squamous cell'
        ]
    },
    {
        name: 'Pediatric Dentistry',
        keywords: [
            'primary tooth', 'primary teeth', 'deciduous', 'child', 'pediatric',
            'space maintainer', 'stainless steel crown', 'ssc', 'formocresol',
            'mTA in primary', 'early childhood caries', 'ecc', 'nolla', 'eruption',
            'fluoride varnish', 'pit and fissure', 'behavior management', 'frankl',
            'avulsion in primary', 'pulpotomy in primary'
        ]
    },
    {
        name: 'Dental Ethics',
        keywords: [
            'ethics', 'consent', 'informed consent', 'confidentiality', 'autonomy',
            'beneficence', 'non-maleficence', 'justice', 'veracity', 'infection control',
            'autoclave', 'sterilization', 'disinfection', 'ppe', 'sharps',
            'needlestick', 'hazard', 'malpractice', 'negligence', 'patient rights',
            'cdc', 'osha', 'standard precautions'
        ]
    }
];

function normalizeForComparison(str) {
    if (!str) return '';
    return str
        .toLowerCase()
        .replace(/^\d{1,4}[\.\-\)]\s*/, '') // remove leading question numbers
        .replace(/[^a-z0-9]/g, '') // keep only alphanumeric
        .trim();
}

function classify(qText, options) {
    const fullSearchText = (qText + ' ' + options.map(o => o.text).join(' ')).toLowerCase();
    let bestSpecialty = null;
    let maxScore = -1;

    specialtyRules.forEach(rule => {
        let score = 0;
        rule.keywords.forEach(kw => {
            if (fullSearchText.includes(kw.toLowerCase())) {
                score += kw.length > 7 ? 2 : 1;
            }
        });
        if (score > maxScore) {
            maxScore = score;
            bestSpecialty = rule;
        }
    });

    if (maxScore <= 0 || !bestSpecialty) {
        bestSpecialty = specialtyRules.find(r => r.name === 'Restorative');
    }

    let difficulty = 'medium';
    if (qText.length > 250 || fullSearchText.includes('syndrome') || fullSearchText.includes('complication')) {
        difficulty = 'hard';
    } else if (qText.length < 90 && !fullSearchText.includes('except')) {
        difficulty = 'easy';
    }

    return { specialtyName: bestSpecialty.name, difficulty };
}

async function parseDocx(filePath) {
    const result = await mammoth.convertToHtml({ path: filePath });
    const html = result.value;

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
    const questions = [];
    let currentQTextLines = [];
    let currentOptions = [];
    let currentExplanation = '';
    let state = 'SEEKING_QUESTION';

    function finalize() {
        if (currentOptions.length >= 2) {
            let qText = currentQTextLines.join(' ').trim();
            qText = qText.replace(/^\d{1,4}[\.\-\)]?\s*/, '').trim();
            qText = qText.replace(/^(أسفل النموذج|أعلى النموذج)\s*/g, '').trim();

            let hasCorrect = false;
            const cleanedOpts = [];
            const seen = {};

            for (const opt of currentOptions) {
                let text = opt.text;
                let isCorrect = false;
                if (text.includes('✅') || text.includes('*') || /[\(\[]\s*(correct|صح)\s*[\)\]]/i.test(text)) {
                    isCorrect = true;
                    hasCorrect = true;
                    text = text.replace(/✅|\*|[\(\[]\s*(correct|صح)\s*[\)\]]/gi, '').trim();
                }
                if (!seen[opt.label]) {
                    seen[opt.label] = true;
                    cleanedOpts.push({ label: opt.label, text, isCorrect });
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
        state = 'SEEKING_QUESTION';
    }

    const optRegex = /^([A-D|a-d])[\.\-\)]\s*(.*)$/;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.includes('أسفل النموذج') || line.includes('أعلى النموذج')) continue;

        const m = line.match(optRegex);
        if (m) {
            const label = m[1].toUpperCase();
            if (label === 'A' && currentOptions.length >= 2) {
                finalize();
            }
            currentOptions.push({ label, text: m[2] || '' });
            state = 'IN_OPTIONS';
        } else if (line.toLowerCase().startsWith('explanation:') || line.startsWith('الشرح:')) {
            state = 'IN_EXPLANATION';
            currentExplanation += ' ' + line.replace(/^(explanation|الشرح)\s*:\s*/i, '');
        } else if (state === 'IN_EXPLANATION') {
            const nextIsOpt = i + 1 < lines.length && lines[i + 1].match(optRegex);
            if (nextIsOpt) finalize();
            else currentExplanation += ' ' + line;
        } else if (state === 'IN_OPTIONS') {
            const nextIsOpt = i + 1 < lines.length && lines[i + 1].match(optRegex);
            if (line.length < 100 && !line.includes('?') && !nextIsOpt && currentOptions.length > 0) {
                currentOptions[currentOptions.length - 1].text += ' ' + line;
            } else {
                finalize();
                currentQTextLines.push(line);
                state = 'IN_QUESTION';
            }
        } else {
            currentQTextLines.push(line);
            state = 'IN_QUESTION';
        }
    }
    finalize();
    return questions;
}

async function importDocxSafe(filePath, dryRun = false) {
    const resolvedPath = path.resolve(filePath);
    if (!fs.existsSync(resolvedPath)) {
        console.error(`❌ File not found: ${resolvedPath}`);
        process.exit(1);
    }

    const fileName = path.basename(resolvedPath);
    console.log(`\n======================================================`);
    console.log(`🚀 SAFE QUESTION IMPORTER & DEDUPLICATOR`);
    console.log(`📁 Target File: ${fileName}`);
    console.log(`⚙️ Mode: ${dryRun ? 'DRY-RUN (Inspection Only)' : 'LIVE INGESTION'}`);
    console.log(`======================================================\n`);

    // 1. Parse Questions from DOCX
    console.log('1. Extracting questions from DOCX...');
    const parsedQuestions = await parseDocx(resolvedPath);
    console.log(`✅ Extracted ${parsedQuestions.length} raw questions from file.`);

    // 2. Fetch existing questions from database
    console.log('2. Connecting to database and fetching existing questions...');
    await sequelize.authenticate();
    
    const [existingRows] = await sequelize.query('SELECT id, text FROM Questions;');
    console.log(`✅ Found ${existingRows.length} questions currently in database.`);

    const existingNormSet = new Set();
    existingRows.forEach(row => {
        const norm = normalizeForComparison(row.text);
        if (norm) existingNormSet.add(norm);
    });

    // 3. Fetch Specialties Map
    const specialties = await Specialty.findAll();
    const specialtyMap = {};
    specialties.forEach(s => {
        specialtyMap[s.name.toLowerCase()] = s.id;
    });

    // 4. Filter and Deduplicate
    console.log('3. Filtering out existing duplicates...');
    const newQuestions = [];
    let skippedDuplicates = 0;

    parsedQuestions.forEach(q => {
        const norm = normalizeForComparison(q.text);
        if (existingNormSet.has(norm)) {
            skippedDuplicates++;
        } else {
            existingNormSet.add(norm); // prevent in-file duplicates too
            newQuestions.push(q);
        }
    });

    console.log(`\n======================================================`);
    console.log(`📊 DEDUPLICATION REPORT:`);
    console.log(`======================================================`);
    console.log(`📄 Total Questions in Word file:   ${parsedQuestions.length}`);
    console.log(`⚠️ Existing Duplicates SKIPPED:     ${skippedDuplicates}`);
    console.log(`✨ NEW Questions to be Inserted:    ${newQuestions.length}`);
    console.log(`======================================================\n`);

    if (dryRun || newQuestions.length === 0) {
        if (newQuestions.length === 0) {
            console.log('ℹ️ All questions in this file already exist in database! Nothing to insert.');
        } else {
            console.log('ℹ️ Dry-run completed. No database changes were made.');
        }
        process.exit(0);
    }

    // 5. Ingest New Questions in Transaction
    console.log(`4. Ingesting ${newQuestions.length} new questions into database...`);
    const t = await sequelize.transaction();
    try {
        let insertedQ = 0;
        let insertedOpt = 0;
        let insertedExp = 0;

        for (const q of newQuestions) {
            const { specialtyName, difficulty } = classify(q.text, q.options);
            const specialtyId = specialtyMap[specialtyName.toLowerCase()] || specialtyMap['restorative'];

            const createdQ = await Question.create({
                specialtyId,
                text: q.text,
                difficulty,
                timeEstimate: 60,
                isActive: true,
                isPremium: false,
                source: fileName,
                verifiedByAI: true
            }, { transaction: t });

            insertedQ++;

            for (const opt of q.options) {
                await Option.create({
                    questionId: createdQ.id,
                    order: opt.label,
                    text: opt.text,
                    isCorrect: opt.isCorrect ? 1 : 0
                }, { transaction: t });
                insertedOpt++;
            }

            if (q.explanation && q.explanation.length > 0) {
                await Explanation.create({
                    questionId: createdQ.id,
                    text: q.explanation,
                    references: `${fileName} - SDLE QBank`,
                    aiGenerated: true
                }, { transaction: t });
                insertedExp++;
            }
        }

        await t.commit();
        console.log(`\n🎉 TRANSACTION COMMITTED SUCCESSFULLY!`);
        console.log(`✅ Questions Added:     ${insertedQ}`);
        console.log(`✅ Options Added:       ${insertedOpt}`);
        console.log(`✅ Explanations Added:  ${insertedExp}`);

        const [finalCount] = await sequelize.query('SELECT COUNT(*) as cnt FROM Questions;');
        console.log(`\n🎯 FINAL TOTAL QUESTIONS IN DATABASE: ${finalCount[0].cnt} questions!\n`);

    } catch (err) {
        await t.rollback();
        console.error('❌ Ingestion failed, transaction rolled back:', err);
        process.exit(1);
    }

    process.exit(0);
}

const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const fileArg = args.find(a => !a.startsWith('--')) || path.join(__dirname, '../../اساله جديده.docx');

importDocxSafe(fileArg, isDryRun).catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
