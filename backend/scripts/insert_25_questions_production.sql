-- ==========================================
-- Production Database Import (healthlicenseprep.com)
-- ==========================================
DELIMITER $$
DROP PROCEDURE IF EXISTS ImportLesionQuestions$$
CREATE PROCEDURE ImportLesionQuestions()
BEGIN
    SET FOREIGN_KEY_CHECKS = 0;

    -- Clean up any prior import of this docx to avoid duplicates and ensure freshness
    DELETE FROM Options WHERE questionId IN (SELECT id FROM Questions WHERE source = 'What is this lesion Docx');
    DELETE FROM Explanations WHERE questionId IN (SELECT id FROM Questions WHERE source = 'What is this lesion Docx');
    DELETE FROM Questions WHERE source = 'What is this lesion Docx';


-- Question 1: What is this lesion?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions and Diagnosis' LIMIT 1),
  'Oral Lesions and Diagnosis',
  'What is this lesion?',
  '/uploads/questions/lesion_q01.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Mucocele', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Fordyce granules', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Leukoplakia', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Candidiasis', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Fordyce granules are ectopic sebaceous glands appearing as asymptomatic, small (1–2 mm), multiple yellowish-white papules commonly found on the buccal mucosa and vermilion border of the upper lip. They are normal anatomical variations and require no treatment.', JSON_QUOTE('Mucocele is a bluish fluctuant swelling caused by severed salivary duct trauma. Leukoplakia presents as a white plaque that cannot be wiped off. Candidiasis typically presents as curdy white plaques that wipe off leaving an erythematous base or as erythematous patches.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 2: What type of instrument grasp is shown i...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Periodontal Instruments and Techniques' LIMIT 1),
  'Periodontal Instruments and Techniques',
  'What type of instrument grasp is shown in the image?',
  '/uploads/questions/lesion_q02.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Palm grasp', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Modified pen grasp', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Pen grasp', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Reverse palm grasp', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'The modified pen grasp is the standard grasp used in dental hygiene and periodontal instrumentation. The pads of the thumb and index finger hold the instrument handle, while the pad of the middle finger rests on the shank to feel tactile vibrations and guide instrument movements.', JSON_QUOTE('Palm grasp is used for bulky surgical instruments or forceps. Standard pen grasp does not place the pad of the middle finger on the shank, resulting in less control and decreased tactile sensitivity. Reverse palm grasp is used in specific retracting situations.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 3: The image shows which periodontal proced...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Furcation Management' LIMIT 1),
  'Furcation Management',
  'The image shows which periodontal procedure?',
  '/uploads/questions/lesion_q03.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Root resection', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Hemisection', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Tunneling', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Guided tissue regeneration', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Tunneling (Tunnel preparation) is a surgical periodontal procedure performed in multi-rooted teeth (commonly mandibular molars with advanced Class III furcation involvement) to create an open tunnel through the furcation area that allows patient access for interdental cleaning aids (e.g. interdental brushes).', JSON_QUOTE('Root resection involves surgical removal of an entire root while retaining the crown. Hemisection is the division of a multi-rooted tooth and crown through the furcation with removal of one half. Guided tissue regeneration utilizes barrier membranes to regenerate periodontal apparatus.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 4: The image shows a patient with which sys...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Autoimmune Disorders and Oral Health' LIMIT 1),
  'Autoimmune Disorders and Oral Health',
  'The image shows a patient with which systemic disease?',
  '/uploads/questions/lesion_q04.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Lichen planus', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Pemphigus vulgaris', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Systemic lupus erythematosus', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Erythema multiforme', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'The classic malar or ''butterfly rash'' over the bridge of the nose and malar eminences sparing the nasolabial folds is characteristic of Systemic Lupus Erythematosus (SLE), a chronic autoimmune connective tissue disease that frequently features photosensitivity and oral ulcers.', JSON_QUOTE('Lichen planus presents with reticular or erosive oral lesions, Wickham''s striae, and polygonal pruritic purple papules on flexor surfaces. Pemphigus vulgaris manifests with flaccid cutaneous and mucosal bullae with a positive Nikolsky sign. Erythema multiforme characteristically presents with target (iris) lesions.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 5: The V-shaped gingival defect seen in the...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Gingival Recession Causes' LIMIT 1),
  'Gingival Recession Causes',
  'The V-shaped gingival defect seen in the image is called:',
  '/uploads/questions/lesion_q05.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'McCall’s festoon', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Gingival recession', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Stillman cleft', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Periodontal pocket', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'A Stillman''s cleft is a specific narrow, V-shaped or slit-like indentation/slit in the marginal gingiva that extends apically from the gingival margin toward or through the mucogingival junction, historically associated with trauma from occlusion or improper toothbrushing trauma.', JSON_QUOTE('McCall''s festoon is an exaggerated roll-shaped enlargement/thickening of the marginal gingiva, often seen in the canine and premolar areas. Generalized gingival recession refers to apical migration of the gingival margin without the characteristic narrow V-shaped cleft slit. A periodontal pocket is a pathological deepening of the gingival sulcus.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 6: What is the diagnosis of the vascular le...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesion Management' LIMIT 1),
  'Oral Lesion Management',
  'What is the diagnosis of the vascular lesion shown in the image?',
  '/uploads/questions/lesion_q06.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Mucocele', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Varicosity', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Caliber-persistent artery', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Pyogenic granuloma', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'A caliber-persistent artery is a vascular anomaly where a main arterial branch enters the superficial submucosa without a reduction in diameter, presenting clinically as a linear or papular pulsatile mucosal elevation, typically on the lower lip of older adults.', JSON_QUOTE('Mucocele is a non-pulsatile pseudocyst containing mucus due to severed salivary ducts. Varicosity (lingual varix) presents as a blue-purple dilatated vein, most common on the ventral tongue and non-pulsatile. Pyogenic granuloma is a lobulated, ulcerated reactive vascular hyperplasia.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 7: What is the diagnosis of the lesion show...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions and Diagnosis' LIMIT 1),
  'Oral Lesions and Diagnosis',
  'What is the diagnosis of the lesion shown in the image?',
  '/uploads/questions/lesion_q07.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Peripheral giant cell granuloma', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Pyogenic granuloma', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Peripheral ossifying fibroma', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Fibroma', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Pyogenic granuloma is a benign, reactive vascular proliferation occurring in response to local irritation or hormonal factors (e.g. pregnancy tumor). Clinically, it appears as an erythematous, lobulated, soft, highly vascular exophytic gingival mass that bleeds easily on touch.', JSON_QUOTE('Peripheral giant cell granuloma typically exhibits a deeper red-purple to bluish color and arises exclusively from the periosteum or periodontal ligament. Peripheral ossifying fibroma usually has a paler, firmer surface with calcifications. Irritation fibroma is pale pink, firm, and non-bleeding.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 8: What is the diagnosis of the oral lesion...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions' LIMIT 1),
  'Oral Lesions',
  'What is the diagnosis of the oral lesion shown in the image?',
  '/uploads/questions/lesion_q08.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Pemphigus vulgaris', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Angina bullosa hemorrhagica', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Mucocele', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Herpes simplex', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Angina bullosa hemorrhagica (ABH) is a benign oral condition characterized by the sudden onset of blood-filled blisters (blood blisters) on the oral mucosa, particularly the soft palate, typically provoked by minor trauma (eating hard or hot food). It bursts rapidly, leaving a painless superficial ulcer that heals without scarring.', JSON_QUOTE('Pemphigus vulgaris produces clear fluid-filled flaccid blisters and painful erosions with a chronic progressive course. Mucoceles are translucent or blue cystic swellings with mucus, rarely on the soft palate. Herpes simplex manifests as clusters of small vesicles on keratinized mucosa preceded by prodromal tingling.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 9: What is the dental finding shown in the ...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Pediatric Dentistry%' OR name LIKE '%Pediatric Dentistry%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Infectious Diseases in Children' LIMIT 1),
  'Infectious Diseases in Children',
  'What is the dental finding shown in the image and which disease is it associated with?',
  '/uploads/questions/lesion_q09.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Fusion – Amelogenesis imperfecta', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Hutchinson teeth – Congenital syphilis', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Peg lateral – Down syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Enamel hypoplasia – Rickets', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Hutchinson''s incisors (screwdriver-shaped incisors with a central incisal notch) and Mulberry molars are part of Hutchinson''s triad (interstitial keratitis, eighth-nerve deafness, and notched incisors) diagnostic of congenital syphilis caused by Treponema pallidum.', JSON_QUOTE('Amelogenesis imperfecta causes generalized enamel defects across all teeth without the specific screwdriver notch. Peg laterals can occur as an isolated microdontia or in various syndromes, but do not show notched incisal edges. Rickets leads to delayed eruption and hypoplasia, but not screwdriver incisors.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 10: What is the lesion shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions and Diagnosis' LIMIT 1),
  'Oral Lesions and Diagnosis',
  'What is the lesion shown in the image?',
  '/uploads/questions/lesion_q10.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Pyogenic granuloma', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Epulis fissuratum', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Fibroma', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Peripheral giant cell granuloma', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Epulis fissuratum (inflammatory fibrous hyperplasia / denture-induced hyperplasia) presents as elongated, fold-like redundant fibrous tissue folds in the vestibule along the ill-fitting border of an overextended complete or partial denture.', JSON_QUOTE('Pyogenic granuloma is a vascular, red, easily bleeding mass rather than multiple firm tissue folds. Irritation fibroma is a discrete, smooth nodule. Peripheral giant cell granuloma is localized to the gingiva and contains multinucleated osteoclast-like giant cells.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 11: What syndrome is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Pediatric Dentistry%' OR name LIKE '%Pediatric Dentistry%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1),
  'Craniofacial Syndromes and Their Dental Implicatio',
  'What syndrome is shown in the image?',
  '/uploads/questions/lesion_q11.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Down syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Treacher Collins syndrome', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Pierre Robin syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Crouzon syndrome', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Treacher Collins syndrome (mandibulofacial dysostosis) is characterized by downward-slanting palpebral fissures, coloboma of the lower eyelids, hypoplasia of the zygomatic arches and mandible (bird-like face), microtia/malformed external ears, and conductive hearing loss.', JSON_QUOTE('Down syndrome shows up-slanting palpebral fissures, epicanthal folds, and macroglossia. Pierre Robin sequence features micrognathia, glossoptosis, and cleft palate without lower eyelid colobomas. Crouzon syndrome features craniosynostosis with ocular proptosis and midface hypoplasia.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 12: What syndrome is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Pediatric Dentistry%' OR name LIKE '%Pediatric Dentistry%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1),
  'Craniofacial Syndromes and Their Dental Implicatio',
  'What syndrome is shown in the image?',
  '/uploads/questions/lesion_q12.png',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Down syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Cleidocranial dysplasia', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Crouzon syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Treacher Collins syndrome', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Cleidocranial dysplasia (CCD) is an autosomal dominant condition caused by RUNX2 mutations. Hallmark features include aplasia or hypoplasia of the clavicles (enabling patients to touch their shoulders together), delayed fontanelle closure, and multiple impacted supernumerary teeth.', JSON_QUOTE('Patients with Down, Crouzon, or Treacher Collins syndromes possess intact clavicles and cannot approximate their shoulders anteriorly in this characteristic manner.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 13: What is the lesion shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions in Children' LIMIT 1),
  'Oral Lesions in Children',
  'What is the lesion shown in the image?',
  '/uploads/questions/lesion_q13.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Epstein pearls', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Bohn nodules', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Mucocele', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Ranula', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Bohn''s nodules are keratin-filled cysts derived from remnants of salivary gland tissue found scattered along the buccal and lingual aspects of the dental ridges (away from the midline) in infants.', JSON_QUOTE('Epstein''s pearls are located strictly along the median palatal raphe. Mucoceles and ranulas occur from salivary gland duct disruption and are translucent blue/cystic rather than tiny keratin cysts.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 14: What is the lesion shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Medicine & Pathology%' OR name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Oral Lesions in Children' LIMIT 1),
  'Oral Lesions in Children',
  'What is the lesion shown in the image?',
  '/uploads/questions/lesion_q14.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Bohn nodules', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Epstein pearls', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Dental lamina cyst', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Mucocele', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Epstein''s pearls are small, white-yellow epithelial inclusion cysts occurring along the median palatal raphe of newborns, formed by entrapped epithelium during palatal fusion.', JSON_QUOTE('Bohn nodules are found on the alveolar ridge (buccal/lingual), not on the palatal midline. Dental lamina cysts occur on the crest of the alveolar ridge. Mucoceles are uncommon in newborns and are not midline inclusion cysts.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 15: What condition is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Surgery%' OR name LIKE '%Oral Surgery%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Maxillofacial Infections and Their Complications' LIMIT 1),
  'Maxillofacial Infections and Their Complications',
  'What condition is shown in the image?',
  '/uploads/questions/lesion_q15.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Peritonsillar abscess', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Ludwig’s angina', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Cellulitis', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Submandibular abscess', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Ludwig''s angina is a rapidly spreading, bilateral cellulitis involving the submandibular, sublingual, and submental spaces (often arising from lower molar odontogenic infections). The massive bilateral ''woody'' induration elevates the floor of the mouth and tongue, creating an acute airway emergency.', JSON_QUOTE('Peritonsillar abscess is unilateral and located near the soft palate/tonsillar pillar. Unilateral submandibular abscess lacks the bilateral multi-space involvement and rapid airway compromise of Ludwig''s.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 16: What instrument is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Prosthodontics%' OR name LIKE '%Prosthodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Removable Partial Denture Design' LIMIT 1),
  'Removable Partial Denture Design',
  'What instrument is shown in the image?',
  '/uploads/questions/lesion_q16.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Analyzing rod', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Carbon marker', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Undercut gauge', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Wax trimmer', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'An undercut gauge (typically 0.010", 0.020", or 0.030") is an accessory attached to a dental surveyor used in removable partial denture (RPD) design to measure and locate the exact depth of retentive undercuts on abutment teeth.', JSON_QUOTE('The analyzing rod is a straight metal tool with no lip/gauge at the tip used to parallel surfaces. The carbon marker is used to draw the height of contour. The wax trimmer has a blade to trim blockout wax.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 17: What surgical technique is shown in the ...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Periodontal Surgical Techniques' LIMIT 1),
  'Periodontal Surgical Techniques',
  'What surgical technique is shown in the image?',
  '/uploads/questions/lesion_q17.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Laterally positioned flap', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Coronally advanced flap', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Double papilla flap', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Free gingival graft', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'The double papilla flap (Cohen and Ross technique) is a mucogingival surgical technique where interdental papillae from both sides of a recession defect are mobilized and joined together over the exposed root surface, useful when adjacent donor keratinized tissue is narrow.', JSON_QUOTE('A laterally positioned flap transposes a single donor flap sideways from an adjacent tooth. Coronally advanced flap mobilizes tissue coronally. Free gingival graft involves an unvascularized graft harvested from the palate.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 18: What component is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Prosthodontics%' OR name LIKE '%Prosthodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Implant Prosthesis Design' LIMIT 1),
  'Implant Prosthesis Design',
  'What component is shown in the image?',
  '/uploads/questions/lesion_q18.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Healing abutment', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'UCLA abutment', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Impression coping', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Cover screw', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'The UCLA abutment is a castable or machined plastic sleeve that allows direct waxing and casting of the crown/framework directly to the implant fixture, useful for screw-retained or custom-angle restorations where interocclusal space is limited.', JSON_QUOTE('Healing abutments are domed titanium components placed during soft tissue healing. Impression copings have specific transfer retentive grooves to transfer fixture position in an impression. Cover screws are flat screws placed flush with the implant fixture during submerged healing.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 19: What is the implant component shown in t...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Prosthodontics%' OR name LIKE '%Prosthodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Implant Prosthesis Design' LIMIT 1),
  'Implant Prosthesis Design',
  'What is the implant component shown in the image?',
  '/uploads/questions/lesion_q19.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Healing abutment', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Impression coping', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'UCLA abutment', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Cover screw', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'An impression coping (transfer coping) is screwed into the implant fixture or abutment to accurately record its 3D spatial position and orientation within the impression material.', JSON_QUOTE('Healing abutment guides soft tissue emergence without capturing fixture index. UCLA abutment is cast-to for fabrication. Cover screw seals the implant apex during submerged stage 1.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 20: What instrument is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Periodontal Instruments and Techniques' LIMIT 1),
  'Periodontal Instruments and Techniques',
  'What instrument is shown in the image?',
  '/uploads/questions/lesion_q20.png',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Nabers probe', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Williams probe', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Explorer', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Sickle scaler', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'The Nabers probe is a curved periodontal instrument specifically designed to examine and assess the degree of furcation involvement in multi-rooted teeth, featuring curved working ends with millimeter calibrations.', JSON_QUOTE('Williams probe is a straight probe with markings at 1, 2, 3, 5, 7, 8, 9, 10 mm. An explorer has a sharp pointed tip used for caries and calculus detection. A sickle scaler has a triangular cross-section and pointed tip used for supragingival scaling.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 21: What is the device shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Surgery%' OR name LIKE '%Oral Surgery%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Surgical Instruments and Techniques' LIMIT 1),
  'Surgical Instruments and Techniques',
  'What is the device shown in the image?',
  '/uploads/questions/lesion_q21.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Surgical stent', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Occlusal splint', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Bite registration', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Radiographic guide', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'A surgical stent (surgical template/guide) is an intraoral appliance fabricated to guide the surgeon during implant osteotomy placement or pre-prosthetic bone recontouring (alveolectomy) to ensure optimal prosthetically-driven implant positioning.', JSON_QUOTE('Occlusal splints (nightguards) cover occlusal surfaces to manage bruxism/TMD. Bite registration records interocclusal jaw relations. Radiographic guides contain radiopaque markers to plan implants on CBCT scans.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 22: What syndrome is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Pediatric Dentistry%' OR name LIKE '%Pediatric Dentistry%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1),
  'Craniofacial Syndromes and Their Dental Implicatio',
  'What syndrome is shown in the image?',
  '/uploads/questions/lesion_q22.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Treacher Collins syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Crouzon syndrome', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Down syndrome', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Apert syndrome', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Crouzon syndrome (craniofacial dysostosis) is characterized by premature closure of cranial sutures (craniosynostosis), midface hypoplasia, ocular proptosis (prominent bulging eyes), hypertelorism, and a beak-like nose without syndactyly (webbed digits).', JSON_QUOTE('Apert syndrome features craniosynostosis accompanied by severe syndactyly (mitten hands/feet). Treacher Collins syndrome exhibits downward-slanting eyes and lower eyelid colobomas. Down syndrome features flat facial profile and epicanthal folds.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 23: What instrument is shown in the image?...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Periodontics%' OR name LIKE '%Periodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Implant Maintenance and Care' LIMIT 1),
  'Implant Maintenance and Care',
  'What instrument is shown in the image?',
  '/uploads/questions/lesion_q23.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Sickle scaler', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Gracey curette', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Plastic scaler (implant scaler)', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Periodontal probe', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Plastic or composite/titanium-tipped scalers are non-metallic instruments designed specifically for implant debridement and maintenance to clean titanium implant abutments and restorations without scratching or gouging the polished implant surface.', JSON_QUOTE('Traditional stainless steel sickle scalers and Gracey curettes cause micro-scratches on titanium surfaces, leading to increased plaque retention and peri-implantitis risk.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 24: What instrument is shown in the image an...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Oral Surgery%' OR name LIKE '%Oral Surgery%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Surgical Instruments and Techniques' LIMIT 1),
  'Surgical Instruments and Techniques',
  'What instrument is shown in the image and what is its primary use?',
  '/uploads/questions/lesion_q24.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Hemostat – for controlling bleeding', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Chalazion forceps – for stabilizing the lip during minor oral surgery (e.g., biopsy)', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Tissue forceps – for suturing', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Needle holder – for holding sutures', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Chalazion forceps have a ring-shaped loop on one side and a solid flat plate on the other with a locking screw. In oral surgery, they are commonly used during minor labial surgery (such as lower lip mucocele excision or minor salivary gland biopsy) to stabilize the lip, provide hemostasis, and isolate the surgical field.', JSON_QUOTE('Hemostats have transverse serrations for clamping blood vessels. Standard tissue forceps have toothed tips for grasping tissues. Needle holders have cross-hatched jaws with a central groove to hold suture needles.'), 'Clinical Dental Examination', 1, NOW(), NOW());

-- Question 25: A patient presents with tissue growth be...
INSERT INTO Questions (specialtyId, topicId, subTopic, text, image, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt) VALUES (
  COALESCE((SELECT id FROM Specialties WHERE name LIKE '%Prosthodontics%' OR name LIKE '%Prosthodontics%' LIMIT 1), 14),
  (SELECT id FROM Topics WHERE name = 'Overdentures and Abutment Management' LIMIT 1),
  'Overdentures and Abutment Management',
  'A patient presents with tissue growth beneath a pontic of a fixed partial denture as shown in the image. What is the most likely diagnosis?',
  '/uploads/questions/lesion_q25.jpeg',
  'medium',
  60, 1, 0,
  'What is this lesion Docx',
  1, NOW(), NOW()
);
SET @prod_qid = LAST_INSERT_ID();

INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'A', 'Inflammatory fibrous hyperplasia', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'B', 'Subpontic osseous hyperplasia', 1, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'C', 'Pyogenic granuloma', 0, NOW(), NOW());
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt) VALUES (@prod_qid, 'D', 'Peripheral ossifying fibroma', 0, NOW(), NOW());
INSERT INTO Explanations (questionId, text, whyWrong, `references`, aiGenerated, createdAt, updatedAt) VALUES (@prod_qid, 'Subpontic osseous hyperplasia (subpontic hyperostosis) is a benign, reactive bone proliferation developing from the alveolar crest beneath the pontic of a fixed partial denture, typically in the posterior mandible, stimulated by mechanical forces and hygiene factors.', JSON_QUOTE('Inflammatory fibrous hyperplasia is soft tissue proliferation due to chronic friction. Pyogenic granuloma is a vascular, red, bleeding gingival mass. Peripheral ossifying fibroma occurs on the gingival margin rather than as a hard subpontic osseous mass.'), 'Clinical Dental Examination', 1, NOW(), NOW());

        SET FOREIGN_KEY_CHECKS = 1;
        SELECT 'Imported 25 lesion questions successfully' AS status;
END$$
DELIMITER ;

CALL ImportLesionQuestions();
DROP PROCEDURE IF EXISTS ImportLesionQuestions;
