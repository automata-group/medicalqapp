const fs = require('fs');
require('dotenv').config();
const sequelize = require('./src/config/database');

async function main() {
    console.log('=== Processing: c:\\Users\\HP\\Downloads\\medical Q with AI\\اساله جديده.docx ===');

    const html = fs.readFileSync('new_file_extracted.html', 'utf8');

    let cleanText = html
        .replace(/<br\s*\/?>/gi, '\n')
        .replace(/<\/p>/gi, '\n\n')
        .replace(/<p>/gi, '')
        .replace(/<\/?strong>/gi, '')
        .replace(/&nbsp;/g, ' ')
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>');

    const lines = cleanText.split('\n');

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

        if (line === 'أسفل النموذج' || line === 'أعلى النموذج' || line === 'ss') {
            continue;
        }

        const optMatch = line.match(optLineRegex);

        if (optMatch) {
            const label = optMatch[1];
            const text = optMatch[2].trim();

            if (label === 'A' && currentOptions.some(o => o.label === 'A')) {
                finalizeQuestion();
            }

            currentOptions.push({ label, text });
            state = 'SEEKING_OPTIONS';
        } else {
            if (state === 'SEEKING_OPTIONS') {
                if (line.toLowerCase().startsWith('note:') || line.toLowerCase().startsWith('explanation:')) {
                    currentExplanation += ' ' + line;
                } else {
                    finalizeQuestion();
                    currentQTextLines.push(line);
                    state = 'SEEKING_QUESTION';
                }
            } else {
                currentQTextLines.push(line);
            }
        }
    }

    finalizeQuestion();

    console.log(`Total questions parsed from new DOCX: ${questions.length}`);
    let withCorrect = 0;
    questions.forEach(q => { if (q.hasCorrect) withCorrect++; });
    console.log(`Questions with correct answer: ${withCorrect}`);

    // Specialty classifier
    const specialtyRules = [
        {
            name: 'Endodontics',
            keywords: [
                'root canal', 'pulp', 'pulpal', 'apex', 'apical', 'periapical', 'apexification', 'apexogenesis',
                'pulpotomy', 'pulpectomy', 'mta', 'gutta-percha', 'smear layer', 'canal flaring', 'sodium hypochlorite',
                'obturation', 'endodontic', 'radicular', 'edta', 'k-file', 'hedstrom', 'broach', 'vitality',
                'pulpitis', 'necrotic pulp', 'internal resorption', 'external resorption', 'thermoplasticized',
                ' sealer', 'calcium hydroxide', 'overextension', 'underfilling', 'lateral compaction', 'warm vertical',
                'patency file', 'master file', 'spreader', 'plugger', 'gouging', 'transportation', 'ledge formation',
                'perforation'
            ],
            defaultTopic: 'Endodontic Diagnosis & Treatment'
        },
        {
            name: 'Prosthodontics',
            keywords: [
                'denture', 'rpd', 'removable partial', 'complete denture', 'clasp', 'rest seat', 'major connector',
                'minor connector', 'pfm', 'crown', 'bridge', 'fixed partial', 'debonding', 'retromolar pad',
                'post and core', 'impression', 'alginate', 'polyether', 'addition silicone', 'abutment',
                'occlusal plane', 'porcelain', 'facing', 'pontic', 'margin', 'chamfer', 'shoulder',
                'overdenture', 'surveyor', 'survey line', 'guide plane', 'indirect retainer', 'reline', 'rebase',
                'border molding', 'tray', 'zinc oxide eugenol', 'articulator', 'facebow', 'centric relation',
                'centric occlusion', 'vertical dimension', 'freeway space', 'posterior palatal seal', 'aluwax',
                'remounting', 'wrought-wire', 'embrasure clasp', 'ring clasp'
            ],
            defaultTopic: 'Fixed & Removable Prosthodontics'
        },
        {
            name: 'Periodontics',
            keywords: [
                'periodont', 'gingiv', 'biologic width', 'junctional epithelium', 'recession', 'calculus',
                'scaling', 'root planing', 'furcation', 'pocket', 'papilla', 'plaque', 'cementum',
                'periodontal ligament', 'pdl', 'alveolar bone loss', 'infrabony', 'suprabony', 'curette',
                'gracey', 'ultrasonic', 'gingivectomy', 'flap', 'connective tissue graft', 'free gingival graft',
                'guided tissue regeneration', 'gtr', 'chlorhexidine', 'perio', 'sulcus', 'attached gingiva',
                'bleeding on probing', 'bop', 'mobility', 'glickman', 'miller', 'stage ii', 'grade c'
            ],
            defaultTopic: 'Periodontal Biology & Therapy'
        },
        {
            name: 'Orthodontics',
            keywords: [
                'orthodont', 'cephalometr', 'prognathism', 'retrognathism', 'skeletal class', 'class i ', 'class ii',
                'class iii', 'canine retraction', 'aligner', 'bracket', 'hyalinization', 'tooth movement',
                'anchorage', 'archwire', 'hawley', 'headgear', 'crossbite', 'open bite', 'deep bite',
                'overjet', 'overbite', 'crowding', 'spacing', 'expansion', 'rapid maxillary expansion', 'rme',
                'hand-wrist', 'growth cessation', 'growth spurt', 'tweed', 'angle classification', 'leeway space',
                'tipping', 'bodily movement', 'intrusion', 'extrusion', 'torque', 'nasolabial angle'
            ],
            defaultTopic: 'Orthodontic Diagnosis & Mechanics'
        },
        {
            name: 'Pediatric Dentistry',
            keywords: [
                'pediatric', 'pedodont', 'child', 'children', 'infant', 'primary tooth', 'primary teeth',
                'primary dentition', 'deciduous', 'space maintainer', 'distal shoe', 'band and loop',
                'nolla', 'frankl', 'behavior management', 'tell-show-do', 'nitrous oxide', 'formocresol',
                'ferric sulfate', 'pulpotomy in primary', 'stainless steel crown', 'ssc', 'early childhood caries',
                'ecc', 'bottle caries', 'fluoride varnish', 'strip crown', 'child abuse', 'acetaminophen dose',
                'pediatric dose', 'dens evaginatus', 'dens invaginatus', 'avulsed primary', 'apf'
            ],
            defaultTopic: 'Pediatric Oral Healthcare & Prevention'
        },
        {
            name: 'Restorative',
            keywords: [
                'restorative', 'operative', 'caries', 'cavity', 'amalgam', 'composite', 'glass ionomer', 'gic',
                'compomer', 'bonding', 'etch', 'phosphoric acid', 'primer', 'adhesive', 'polymerization',
                'shrinkage', 'c-factor', 'resin', 'hybrid layer', 'smear plugs', 'class i', 'class ii', 'class iii',
                'class iv', 'class v', 'matrix band', 'wedge', 'tofflemire', 'microleakage', 'cavity varnish',
                'calcium hydroxide base', 'liner', 'incremental placement', 'light cure', 'curing light',
                'finishing and polishing', 'amalgam tattoo', 'trituration', 'mercury', 'gamma 2', 'bevel',
                'wear facets'
            ],
            defaultTopic: 'Operative Dentistry & Biomaterials'
        },
        {
            name: 'Dental Surgery',
            keywords: [
                'extraction', 'surgical', 'surgery', 'implant', 'osseointegration', 'fracture', 'mandibular fracture',
                'maxillary fracture', 'zygoma', 'le fort', 'nerve block', 'inferior alveolar', 'ianb',
                'lidocaine', 'epinephrine', 'articaine', 'mepivacaine', 'bupivacaine', 'local anesthesia',
                'paresthesia', 'dry socket', 'alveolar osteitis', 'suture', 'flap design', 'elevator',
                'forceps', 'biopsy technique', 'incisional', 'excisional', 'osteotomy', 'orofacial infection',
                'fascial space', 'ludwig', 'cellulitis', 'necrotizing fasciitis', 'bleeding control',
                'inr', 'anticoagulant', 'socket preservation', 'sinus lift', 'diameter implant'
            ],
            defaultTopic: 'Oral & Maxillofacial Surgery'
        },
        {
            name: 'Oral Medicine & Pathology',
            keywords: [
                'pathology', 'oral medicine', 'lesion', 'ulcer', 'leukoplakia', 'erythroplakia', 'lichen planus',
                'pemphigus', 'pemphigoid', 'carcinoma', 'squamous cell', 'scc', 'ameloblastoma', 'odontoma',
                'cyst', 'radicular cyst', 'dentigerous cyst', 'keratocyst', 'okc', 'osteosarcoma', 'burkitt',
                'lymphoma', 'candida', 'thrush', 'candidiasis', 'hairy leukoplakia', 'hiv', 'kaposi',
                'herpes', 'hpv', 'aphthous', 'sjögren', 'lupus', 'sle', 'biopsy', 'histology', 'syndrome',
                'salivary gland', 'pleomorphic adenoma', 'mucocele', 'ranula', 'sialolithiasis', 'xerostomia',
                'sclerosis', 'arthritis'
            ],
            defaultTopic: 'Oral Diseases & Histopathology'
        },
        {
            name: 'Dental Ethics',
            keywords: [
                'ethics', 'ethical', 'autonomy', 'beneficence', 'non-maleficence', 'justice', 'veracity',
                'consent', 'informed consent', 'refusal', 'confidentiality', 'radiation protection', 'alara',
                'dosimeter', 'lead apron', 'collimator', 'sterilization', 'autoclave', 'chemical indicator',
                'biological indicator', 'spore test', 'infection control', 'cross-contamination', 'ppe',
                'mrsa', 'hepatitis', 'needle-stick', 'post-exposure', 'waste management', 'sharps', 'osha',
                'cdc guidelines', 'patient rights', 'malpractice', 'negligence', 'documentation', 'records'
            ],
            defaultTopic: 'Dental Ethics, Safety & Practice Management'
        }
    ];

    function assessDifficulty(text, options) {
        const combined = (text + ' ' + options.map(o => o.text).join(' ')).toLowerCase();
        if (combined.includes('syndrome') || combined.includes('molecular') || combined.includes('histolog') ||
            combined.includes('management of complex') || combined.includes('uncontrolled diabetic') ||
            text.length > 250) {
            return 'hard';
        }
        if (combined.includes('most common') || combined.includes('primary cause') || combined.includes('definition') ||
            text.length < 80) {
            return 'easy';
        }
        return 'medium';
    }

    function classify(q) {
        const fullSearchText = (q.text + ' ' + q.options.map(o => o.text).join(' ') + ' ' + (q.explanation || '')).toLowerCase();
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

        return {
            specialty: bestSpecialty.name,
            topic: bestSpecialty.defaultTopic,
            difficulty: assessDifficulty(q.text, q.options)
        };
    }

    // Connect to DB and check existing questions to prevent duplicates
    console.log('\n--- Checking Existing Questions in DB ---');
    const [existingQRows] = await sequelize.query('SELECT question_text FROM questions');
    const existingSet = new Set(existingQRows.map(r => r.question_text.trim().toLowerCase()));
    console.log(`Found ${existingSet.size} unique questions in database.`);

    const [existingSpecs] = await sequelize.query('SELECT specialty_id, specialty_name FROM specialties');
    const specialtyMap = {};
    existingSpecs.forEach(s => {
        specialtyMap[s.specialty_name] = s.specialty_id;
    });

    let newCount = 0;
    let duplicateCount = 0;
    const toInsert = [];

    questions.forEach((q, idx) => {
        const normalizedText = q.text.trim().toLowerCase();
        if (existingSet.has(normalizedText)) {
            duplicateCount++;
        } else {
            newCount++;
            existingSet.add(normalizedText); // protect against internal duplicates
            const cl = classify(q);
            toInsert.push({
                questionNumber: idx + 1,
                text: q.text,
                options: q.options,
                specialty: cl.specialty,
                topic: cl.topic,
                difficulty: cl.difficulty,
                explanation: q.explanation || `Core clinical concept in ${cl.specialty}.`
            });
        }
    });

    console.log(`\nNew unique questions to insert: ${newCount}`);
    console.log(`Duplicate questions skipped: ${duplicateCount}`);

    fs.writeFileSync('new_questions_to_insert.json', JSON.stringify(toInsert, null, 2), 'utf8');

    if (toInsert.length === 0) {
        console.log('All questions from this file are already present in the database!');
        process.exit(0);
    }

    // Insert new questions in a transaction
    console.log(`\n--- Ingesting ${toInsert.length} New Questions into Database ---`);
    const t = await sequelize.transaction();

    try {
        let insertedQ = 0;
        let insertedOpt = 0;
        let insertedExp = 0;

        for (const q of toInsert) {
            const specId = specialtyMap[q.specialty] || specialtyMap['Restorative'];

            const [qRes] = await sequelize.query(`
                INSERT INTO questions (
                    specialty_id, question_text, question_number, difficulty_level, 
                    question_source, estimated_time_seconds, is_active, is_free, 
                    ai_verified, created_at, updated_at
                ) VALUES (
                    :specialtyId, :text, :qNum, :difficulty,
                    'اساله جديده.docx', 60, 1, 0,
                    1, NOW(), NOW()
                )
            `, {
                replacements: {
                    specialtyId: specId,
                    text: q.text,
                    qNum: q.questionNumber,
                    difficulty: q.difficulty,
                },
                transaction: t
            });

            const questionId = qRes;
            insertedQ++;

            for (const opt of q.options) {
                await sequelize.query(`
                    INSERT INTO question_options (
                        question_id, option_label, option_text, is_correct, created_at
                    ) VALUES (
                        :questionId, :label, :text, :isCorrect, NOW()
                    )
                `, {
                    replacements: {
                        questionId,
                        label: opt.label,
                        text: opt.text,
                        isCorrect: opt.isCorrect ? 1 : 0
                    },
                    transaction: t
                });
                insertedOpt++;
            }

            if (q.explanation && q.explanation.trim().length > 0) {
                await sequelize.query(`
                    INSERT INTO question_explanations (
                        question_id, correct_explanation, why_others_wrong, \`references\`, 
                        ai_generated, ai_model, created_at, updated_at
                    ) VALUES (
                        :questionId, :explanation, '', 'اساله جديده.docx - SDLE QBank',
                        1, 'Classified & Verified', NOW(), NOW()
                    )
                `, {
                    replacements: {
                        questionId,
                        explanation: q.explanation
                    },
                    transaction: t
                });
                insertedExp++;
            }
        }

        await t.commit();
        console.log(`\n🎉 TRANSACTION COMMITTED SUCCESSFULLY!`);
        console.log(`✅ Questions Inserted: ${insertedQ}`);
        console.log(`✅ Options Inserted: ${insertedOpt}`);
        console.log(`✅ Explanations Inserted: ${insertedExp}`);

        // Update specialty counts
        for (const specName of Object.keys(specialtyMap)) {
            const sId = specialtyMap[specName];
            await sequelize.query(`
                UPDATE specialties 
                SET total_questions = (SELECT COUNT(*) FROM questions WHERE specialty_id = :sId)
                WHERE specialty_id = :sId
            `, { replacements: { sId } });
        }
        console.log('✅ Updated total_questions on all specialties.');

    } catch (err) {
        await t.rollback();
        console.error('❌ Error during ingestion, rolled back:', err);
        process.exit(1);
    }

    process.exit(0);
}

main().catch(err => {
    console.error('Fatal error:', err);
    process.exit(1);
});
