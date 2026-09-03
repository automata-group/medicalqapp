const fs = require('fs');

const questions = JSON.parse(fs.readFileSync('all_questions_state_machine.json', 'utf8'));
console.log(`Loaded ${questions.length} questions for classification.`);

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

const stats = {};
specialtyRules.forEach(r => { stats[r.name] = 0; });

const classifiedQuestions = questions.map((q, idx) => {
    const cl = classify(q);
    stats[cl.specialty] = (stats[cl.specialty] || 0) + 1;
    return {
        questionNumber: idx + 1,
        text: q.text,
        options: q.options,
        specialty: cl.specialty,
        topic: cl.topic,
        difficulty: cl.difficulty,
        explanation: q.explanation || `Core clinical concept in ${cl.specialty}.`
    };
});

console.log('\n--- Final Classification Statistics (1,137 Questions) ---');
Object.keys(stats).forEach(spec => {
    const count = stats[spec];
    const pct = ((count / questions.length) * 100).toFixed(1);
    console.log(`- ${spec.padEnd(28)}: ${count.toString().padStart(4)} questions (${pct}%)`);
});

fs.writeFileSync('classified_1137_questions.json', JSON.stringify(classifiedQuestions, null, 2), 'utf8');
console.log('\nSuccessfully saved classified_1137_questions.json!');
process.exit(0);
