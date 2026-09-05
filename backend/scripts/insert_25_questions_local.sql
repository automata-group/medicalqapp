-- ==========================================
-- Local Database Import (medical_qbank)
-- ==========================================
SET FOREIGN_KEY_CHECKS = 0;

-- Question 1: What is this lesion?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is this lesion?',
  1,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q01.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Mucocele', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Fordyce granules', 1, 'Fordyce granules are ectopic sebaceous glands appearing as asymptomatic, small (1–2 mm), multiple yellowish-white papules commonly found on the buccal mucosa and vermilion border of the upper lip. They are normal anatomical variations and require no treatment.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Leukoplakia', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Candidiasis', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Fordyce granules are ectopic sebaceous glands appearing as asymptomatic, small (1–2 mm), multiple yellowish-white papules commonly found on the buccal mucosa and vermilion border of the upper lip. They are normal anatomical variations and require no treatment.', 'Mucocele is a bluish fluctuant swelling caused by severed salivary duct trauma. Leukoplakia presents as a white plaque that cannot be wiped off. Candidiasis typically presents as curdy white plaques that wipe off leaving an erythematous base or as erythematous patches.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions and Diagnosis');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions and Diagnosis' LIMIT 1));

-- Question 2: What type of instrument grasp is shown i...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'What type of instrument grasp is shown in the image?',
  2,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q02.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Palm grasp', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Modified pen grasp', 1, 'The modified pen grasp is the standard grasp used in dental hygiene and periodontal instrumentation. The pads of the thumb and index finger hold the instrument handle, while the pad of the middle finger rests on the shank to feel tactile vibrations and guide instrument movements.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Pen grasp', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Reverse palm grasp', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'The modified pen grasp is the standard grasp used in dental hygiene and periodontal instrumentation. The pads of the thumb and index finger hold the instrument handle, while the pad of the middle finger rests on the shank to feel tactile vibrations and guide instrument movements.', 'Palm grasp is used for bulky surgical instruments or forceps. Standard pen grasp does not place the pad of the middle finger on the shank, resulting in less control and decreased tactile sensitivity. Reverse palm grasp is used in specific retracting situations.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Periodontal Instruments and Techniques');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Periodontal Instruments and Techniques' LIMIT 1));

-- Question 3: The image shows which periodontal proced...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'The image shows which periodontal procedure?',
  3,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q03.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Root resection', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Hemisection', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Tunneling', 1, 'Tunneling (Tunnel preparation) is a surgical periodontal procedure performed in multi-rooted teeth (commonly mandibular molars with advanced Class III furcation involvement) to create an open tunnel through the furcation area that allows patient access for interdental cleaning aids (e.g. interdental brushes).', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Guided tissue regeneration', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Tunneling (Tunnel preparation) is a surgical periodontal procedure performed in multi-rooted teeth (commonly mandibular molars with advanced Class III furcation involvement) to create an open tunnel through the furcation area that allows patient access for interdental cleaning aids (e.g. interdental brushes).', 'Root resection involves surgical removal of an entire root while retaining the crown. Hemisection is the division of a multi-rooted tooth and crown through the furcation with removal of one half. Guided tissue regeneration utilizes barrier membranes to regenerate periodontal apparatus.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Furcation Management');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Furcation Management' LIMIT 1));

-- Question 4: The image shows a patient with which sys...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'The image shows a patient with which systemic disease?',
  4,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q04.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Lichen planus', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Pemphigus vulgaris', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Systemic lupus erythematosus', 1, 'The classic malar or ''butterfly rash'' over the bridge of the nose and malar eminences sparing the nasolabial folds is characteristic of Systemic Lupus Erythematosus (SLE), a chronic autoimmune connective tissue disease that frequently features photosensitivity and oral ulcers.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Erythema multiforme', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'The classic malar or ''butterfly rash'' over the bridge of the nose and malar eminences sparing the nasolabial folds is characteristic of Systemic Lupus Erythematosus (SLE), a chronic autoimmune connective tissue disease that frequently features photosensitivity and oral ulcers.', 'Lichen planus presents with reticular or erosive oral lesions, Wickham''s striae, and polygonal pruritic purple papules on flexor surfaces. Pemphigus vulgaris manifests with flaccid cutaneous and mucosal bullae with a positive Nikolsky sign. Erythema multiforme characteristically presents with target (iris) lesions.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Autoimmune Disorders and Oral Health');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Autoimmune Disorders and Oral Health' LIMIT 1));

-- Question 5: The V-shaped gingival defect seen in the...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'The V-shaped gingival defect seen in the image is called:',
  5,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q05.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'McCall’s festoon', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Gingival recession', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Stillman cleft', 1, 'A Stillman''s cleft is a specific narrow, V-shaped or slit-like indentation/slit in the marginal gingiva that extends apically from the gingival margin toward or through the mucogingival junction, historically associated with trauma from occlusion or improper toothbrushing trauma.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Periodontal pocket', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'A Stillman''s cleft is a specific narrow, V-shaped or slit-like indentation/slit in the marginal gingiva that extends apically from the gingival margin toward or through the mucogingival junction, historically associated with trauma from occlusion or improper toothbrushing trauma.', 'McCall''s festoon is an exaggerated roll-shaped enlargement/thickening of the marginal gingiva, often seen in the canine and premolar areas. Generalized gingival recession refers to apical migration of the gingival margin without the characteristic narrow V-shaped cleft slit. A periodontal pocket is a pathological deepening of the gingival sulcus.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Gingival Recession Causes');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Gingival Recession Causes' LIMIT 1));

-- Question 6: What is the diagnosis of the vascular le...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the diagnosis of the vascular lesion shown in the image?',
  6,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q06.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Mucocele', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Varicosity', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Caliber-persistent artery', 1, 'A caliber-persistent artery is a vascular anomaly where a main arterial branch enters the superficial submucosa without a reduction in diameter, presenting clinically as a linear or papular pulsatile mucosal elevation, typically on the lower lip of older adults.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Pyogenic granuloma', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'A caliber-persistent artery is a vascular anomaly where a main arterial branch enters the superficial submucosa without a reduction in diameter, presenting clinically as a linear or papular pulsatile mucosal elevation, typically on the lower lip of older adults.', 'Mucocele is a non-pulsatile pseudocyst containing mucus due to severed salivary ducts. Varicosity (lingual varix) presents as a blue-purple dilatated vein, most common on the ventral tongue and non-pulsatile. Pyogenic granuloma is a lobulated, ulcerated reactive vascular hyperplasia.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesion Management');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesion Management' LIMIT 1));

-- Question 7: What is the diagnosis of the lesion show...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the diagnosis of the lesion shown in the image?',
  7,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q07.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Peripheral giant cell granuloma', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Pyogenic granuloma', 1, 'Pyogenic granuloma is a benign, reactive vascular proliferation occurring in response to local irritation or hormonal factors (e.g. pregnancy tumor). Clinically, it appears as an erythematous, lobulated, soft, highly vascular exophytic gingival mass that bleeds easily on touch.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Peripheral ossifying fibroma', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Fibroma', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Pyogenic granuloma is a benign, reactive vascular proliferation occurring in response to local irritation or hormonal factors (e.g. pregnancy tumor). Clinically, it appears as an erythematous, lobulated, soft, highly vascular exophytic gingival mass that bleeds easily on touch.', 'Peripheral giant cell granuloma typically exhibits a deeper red-purple to bluish color and arises exclusively from the periosteum or periodontal ligament. Peripheral ossifying fibroma usually has a paler, firmer surface with calcifications. Irritation fibroma is pale pink, firm, and non-bleeding.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions and Diagnosis');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions and Diagnosis' LIMIT 1));

-- Question 8: What is the diagnosis of the oral lesion...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the diagnosis of the oral lesion shown in the image?',
  8,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q08.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Pemphigus vulgaris', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Angina bullosa hemorrhagica', 1, 'Angina bullosa hemorrhagica (ABH) is a benign oral condition characterized by the sudden onset of blood-filled blisters (blood blisters) on the oral mucosa, particularly the soft palate, typically provoked by minor trauma (eating hard or hot food). It bursts rapidly, leaving a painless superficial ulcer that heals without scarring.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Mucocele', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Herpes simplex', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Angina bullosa hemorrhagica (ABH) is a benign oral condition characterized by the sudden onset of blood-filled blisters (blood blisters) on the oral mucosa, particularly the soft palate, typically provoked by minor trauma (eating hard or hot food). It bursts rapidly, leaving a painless superficial ulcer that heals without scarring.', 'Pemphigus vulgaris produces clear fluid-filled flaccid blisters and painful erosions with a chronic progressive course. Mucoceles are translucent or blue cystic swellings with mucus, rarely on the soft palate. Herpes simplex manifests as clusters of small vesicles on keratinized mucosa preceded by prodromal tingling.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions' LIMIT 1));

-- Question 9: What is the dental finding shown in the ...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Pediatric Dentistry%' OR specialty_name LIKE '%Pediatric Dentistry%' LIMIT 1), 18),
  'What is the dental finding shown in the image and which disease is it associated with?',
  9,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q09.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Fusion – Amelogenesis imperfecta', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Hutchinson teeth – Congenital syphilis', 1, 'Hutchinson''s incisors (screwdriver-shaped incisors with a central incisal notch) and Mulberry molars are part of Hutchinson''s triad (interstitial keratitis, eighth-nerve deafness, and notched incisors) diagnostic of congenital syphilis caused by Treponema pallidum.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Peg lateral – Down syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Enamel hypoplasia – Rickets', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Hutchinson''s incisors (screwdriver-shaped incisors with a central incisal notch) and Mulberry molars are part of Hutchinson''s triad (interstitial keratitis, eighth-nerve deafness, and notched incisors) diagnostic of congenital syphilis caused by Treponema pallidum.', 'Amelogenesis imperfecta causes generalized enamel defects across all teeth without the specific screwdriver notch. Peg laterals can occur as an isolated microdontia or in various syndromes, but do not show notched incisal edges. Rickets leads to delayed eruption and hypoplasia, but not screwdriver incisors.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Infectious Diseases in Children');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Infectious Diseases in Children' LIMIT 1));

-- Question 10: What is the lesion shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the lesion shown in the image?',
  10,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q10.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Pyogenic granuloma', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Epulis fissuratum', 1, 'Epulis fissuratum (inflammatory fibrous hyperplasia / denture-induced hyperplasia) presents as elongated, fold-like redundant fibrous tissue folds in the vestibule along the ill-fitting border of an overextended complete or partial denture.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Fibroma', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Peripheral giant cell granuloma', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Epulis fissuratum (inflammatory fibrous hyperplasia / denture-induced hyperplasia) presents as elongated, fold-like redundant fibrous tissue folds in the vestibule along the ill-fitting border of an overextended complete or partial denture.', 'Pyogenic granuloma is a vascular, red, easily bleeding mass rather than multiple firm tissue folds. Irritation fibroma is a discrete, smooth nodule. Peripheral giant cell granuloma is localized to the gingiva and contains multinucleated osteoclast-like giant cells.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions and Diagnosis');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions and Diagnosis' LIMIT 1));

-- Question 11: What syndrome is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Pediatric Dentistry%' OR specialty_name LIKE '%Pediatric Dentistry%' LIMIT 1), 18),
  'What syndrome is shown in the image?',
  11,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q11.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Down syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Treacher Collins syndrome', 1, 'Treacher Collins syndrome (mandibulofacial dysostosis) is characterized by downward-slanting palpebral fissures, coloboma of the lower eyelids, hypoplasia of the zygomatic arches and mandible (bird-like face), microtia/malformed external ears, and conductive hearing loss.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Pierre Robin syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Crouzon syndrome', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Treacher Collins syndrome (mandibulofacial dysostosis) is characterized by downward-slanting palpebral fissures, coloboma of the lower eyelids, hypoplasia of the zygomatic arches and mandible (bird-like face), microtia/malformed external ears, and conductive hearing loss.', 'Down syndrome shows up-slanting palpebral fissures, epicanthal folds, and macroglossia. Pierre Robin sequence features micrognathia, glossoptosis, and cleft palate without lower eyelid colobomas. Crouzon syndrome features craniosynostosis with ocular proptosis and midface hypoplasia.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Craniofacial Syndromes and Their Dental Implicatio');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1));

-- Question 12: What syndrome is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Pediatric Dentistry%' OR specialty_name LIKE '%Pediatric Dentistry%' LIMIT 1), 18),
  'What syndrome is shown in the image?',
  12,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q12.png',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Down syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Cleidocranial dysplasia', 1, 'Cleidocranial dysplasia (CCD) is an autosomal dominant condition caused by RUNX2 mutations. Hallmark features include aplasia or hypoplasia of the clavicles (enabling patients to touch their shoulders together), delayed fontanelle closure, and multiple impacted supernumerary teeth.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Crouzon syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Treacher Collins syndrome', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Cleidocranial dysplasia (CCD) is an autosomal dominant condition caused by RUNX2 mutations. Hallmark features include aplasia or hypoplasia of the clavicles (enabling patients to touch their shoulders together), delayed fontanelle closure, and multiple impacted supernumerary teeth.', 'Patients with Down, Crouzon, or Treacher Collins syndromes possess intact clavicles and cannot approximate their shoulders anteriorly in this characteristic manner.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Craniofacial Syndromes and Their Dental Implicatio');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1));

-- Question 13: What is the lesion shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the lesion shown in the image?',
  13,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q13.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Epstein pearls', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Bohn nodules', 1, 'Bohn''s nodules are keratin-filled cysts derived from remnants of salivary gland tissue found scattered along the buccal and lingual aspects of the dental ridges (away from the midline) in infants.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Mucocele', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Ranula', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Bohn''s nodules are keratin-filled cysts derived from remnants of salivary gland tissue found scattered along the buccal and lingual aspects of the dental ridges (away from the midline) in infants.', 'Epstein''s pearls are located strictly along the median palatal raphe. Mucoceles and ranulas occur from salivary gland duct disruption and are translucent blue/cystic rather than tiny keratin cysts.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions in Children');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions in Children' LIMIT 1));

-- Question 14: What is the lesion shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Oral Medicine & Pathology%' OR specialty_name LIKE '%Oral Medicine & Pathology%' LIMIT 1), 18),
  'What is the lesion shown in the image?',
  14,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q14.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Bohn nodules', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Epstein pearls', 1, 'Epstein''s pearls are small, white-yellow epithelial inclusion cysts occurring along the median palatal raphe of newborns, formed by entrapped epithelium during palatal fusion.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Dental lamina cyst', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Mucocele', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Epstein''s pearls are small, white-yellow epithelial inclusion cysts occurring along the median palatal raphe of newborns, formed by entrapped epithelium during palatal fusion.', 'Bohn nodules are found on the alveolar ridge (buccal/lingual), not on the palatal midline. Dental lamina cysts occur on the crest of the alveolar ridge. Mucoceles are uncommon in newborns and are not midline inclusion cysts.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Oral Lesions in Children');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Oral Lesions in Children' LIMIT 1));

-- Question 15: What condition is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Dental Surgery%' OR specialty_name LIKE '%Oral Surgery%' LIMIT 1), 18),
  'What condition is shown in the image?',
  15,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q15.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Peritonsillar abscess', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Ludwig’s angina', 1, 'Ludwig''s angina is a rapidly spreading, bilateral cellulitis involving the submandibular, sublingual, and submental spaces (often arising from lower molar odontogenic infections). The massive bilateral ''woody'' induration elevates the floor of the mouth and tongue, creating an acute airway emergency.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Cellulitis', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Submandibular abscess', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Ludwig''s angina is a rapidly spreading, bilateral cellulitis involving the submandibular, sublingual, and submental spaces (often arising from lower molar odontogenic infections). The massive bilateral ''woody'' induration elevates the floor of the mouth and tongue, creating an acute airway emergency.', 'Peritonsillar abscess is unilateral and located near the soft palate/tonsillar pillar. Unilateral submandibular abscess lacks the bilateral multi-space involvement and rapid airway compromise of Ludwig''s.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Maxillofacial Infections and Their Complications');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Maxillofacial Infections and Their Complications' LIMIT 1));

-- Question 16: What instrument is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Prosthodontics%' OR specialty_name LIKE '%Prosthodontics%' LIMIT 1), 18),
  'What instrument is shown in the image?',
  16,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q16.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Analyzing rod', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Carbon marker', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Undercut gauge', 1, 'An undercut gauge (typically 0.010", 0.020", or 0.030") is an accessory attached to a dental surveyor used in removable partial denture (RPD) design to measure and locate the exact depth of retentive undercuts on abutment teeth.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Wax trimmer', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'An undercut gauge (typically 0.010", 0.020", or 0.030") is an accessory attached to a dental surveyor used in removable partial denture (RPD) design to measure and locate the exact depth of retentive undercuts on abutment teeth.', 'The analyzing rod is a straight metal tool with no lip/gauge at the tip used to parallel surfaces. The carbon marker is used to draw the height of contour. The wax trimmer has a blade to trim blockout wax.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Removable Partial Denture Design');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Removable Partial Denture Design' LIMIT 1));

-- Question 17: What surgical technique is shown in the ...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'What surgical technique is shown in the image?',
  17,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q17.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Laterally positioned flap', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Coronally advanced flap', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Double papilla flap', 1, 'The double papilla flap (Cohen and Ross technique) is a mucogingival surgical technique where interdental papillae from both sides of a recession defect are mobilized and joined together over the exposed root surface, useful when adjacent donor keratinized tissue is narrow.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Free gingival graft', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'The double papilla flap (Cohen and Ross technique) is a mucogingival surgical technique where interdental papillae from both sides of a recession defect are mobilized and joined together over the exposed root surface, useful when adjacent donor keratinized tissue is narrow.', 'A laterally positioned flap transposes a single donor flap sideways from an adjacent tooth. Coronally advanced flap mobilizes tissue coronally. Free gingival graft involves an unvascularized graft harvested from the palate.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Periodontal Surgical Techniques');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Periodontal Surgical Techniques' LIMIT 1));

-- Question 18: What component is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Prosthodontics%' OR specialty_name LIKE '%Prosthodontics%' LIMIT 1), 18),
  'What component is shown in the image?',
  18,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q18.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Healing abutment', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'UCLA abutment', 1, 'The UCLA abutment is a castable or machined plastic sleeve that allows direct waxing and casting of the crown/framework directly to the implant fixture, useful for screw-retained or custom-angle restorations where interocclusal space is limited.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Impression coping', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Cover screw', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'The UCLA abutment is a castable or machined plastic sleeve that allows direct waxing and casting of the crown/framework directly to the implant fixture, useful for screw-retained or custom-angle restorations where interocclusal space is limited.', 'Healing abutments are domed titanium components placed during soft tissue healing. Impression copings have specific transfer retentive grooves to transfer fixture position in an impression. Cover screws are flat screws placed flush with the implant fixture during submerged healing.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Implant Prosthesis Design');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Implant Prosthesis Design' LIMIT 1));

-- Question 19: What is the implant component shown in t...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Prosthodontics%' OR specialty_name LIKE '%Prosthodontics%' LIMIT 1), 18),
  'What is the implant component shown in the image?',
  19,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q19.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Healing abutment', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Impression coping', 1, 'An impression coping (transfer coping) is screwed into the implant fixture or abutment to accurately record its 3D spatial position and orientation within the impression material.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'UCLA abutment', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Cover screw', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'An impression coping (transfer coping) is screwed into the implant fixture or abutment to accurately record its 3D spatial position and orientation within the impression material.', 'Healing abutment guides soft tissue emergence without capturing fixture index. UCLA abutment is cast-to for fabrication. Cover screw seals the implant apex during submerged stage 1.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Implant Prosthesis Design');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Implant Prosthesis Design' LIMIT 1));

-- Question 20: What instrument is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'What instrument is shown in the image?',
  20,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q20.png',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Nabers probe', 1, 'The Nabers probe is a curved periodontal instrument specifically designed to examine and assess the degree of furcation involvement in multi-rooted teeth, featuring curved working ends with millimeter calibrations.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Williams probe', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Explorer', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Sickle scaler', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'The Nabers probe is a curved periodontal instrument specifically designed to examine and assess the degree of furcation involvement in multi-rooted teeth, featuring curved working ends with millimeter calibrations.', 'Williams probe is a straight probe with markings at 1, 2, 3, 5, 7, 8, 9, 10 mm. An explorer has a sharp pointed tip used for caries and calculus detection. A sickle scaler has a triangular cross-section and pointed tip used for supragingival scaling.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Periodontal Instruments and Techniques');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Periodontal Instruments and Techniques' LIMIT 1));

-- Question 21: What is the device shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Dental Surgery%' OR specialty_name LIKE '%Oral Surgery%' LIMIT 1), 18),
  'What is the device shown in the image?',
  21,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q21.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Surgical stent', 1, 'A surgical stent (surgical template/guide) is an intraoral appliance fabricated to guide the surgeon during implant osteotomy placement or pre-prosthetic bone recontouring (alveolectomy) to ensure optimal prosthetically-driven implant positioning.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Occlusal splint', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Bite registration', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Radiographic guide', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'A surgical stent (surgical template/guide) is an intraoral appliance fabricated to guide the surgeon during implant osteotomy placement or pre-prosthetic bone recontouring (alveolectomy) to ensure optimal prosthetically-driven implant positioning.', 'Occlusal splints (nightguards) cover occlusal surfaces to manage bruxism/TMD. Bite registration records interocclusal jaw relations. Radiographic guides contain radiopaque markers to plan implants on CBCT scans.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Surgical Instruments and Techniques');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Surgical Instruments and Techniques' LIMIT 1));

-- Question 22: What syndrome is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Pediatric Dentistry%' OR specialty_name LIKE '%Pediatric Dentistry%' LIMIT 1), 18),
  'What syndrome is shown in the image?',
  22,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q22.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Treacher Collins syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Crouzon syndrome', 1, 'Crouzon syndrome (craniofacial dysostosis) is characterized by premature closure of cranial sutures (craniosynostosis), midface hypoplasia, ocular proptosis (prominent bulging eyes), hypertelorism, and a beak-like nose without syndactyly (webbed digits).', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Down syndrome', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Apert syndrome', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Crouzon syndrome (craniofacial dysostosis) is characterized by premature closure of cranial sutures (craniosynostosis), midface hypoplasia, ocular proptosis (prominent bulging eyes), hypertelorism, and a beak-like nose without syndactyly (webbed digits).', 'Apert syndrome features craniosynostosis accompanied by severe syndactyly (mitten hands/feet). Treacher Collins syndrome exhibits downward-slanting eyes and lower eyelid colobomas. Down syndrome features flat facial profile and epicanthal folds.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Craniofacial Syndromes and Their Dental Implicatio');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Craniofacial Syndromes and Their Dental Implicatio' LIMIT 1));

-- Question 23: What instrument is shown in the image?...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Periodontics%' OR specialty_name LIKE '%Periodontics%' LIMIT 1), 18),
  'What instrument is shown in the image?',
  23,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q23.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Sickle scaler', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Gracey curette', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Plastic scaler (implant scaler)', 1, 'Plastic or composite/titanium-tipped scalers are non-metallic instruments designed specifically for implant debridement and maintenance to clean titanium implant abutments and restorations without scratching or gouging the polished implant surface.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Periodontal probe', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Plastic or composite/titanium-tipped scalers are non-metallic instruments designed specifically for implant debridement and maintenance to clean titanium implant abutments and restorations without scratching or gouging the polished implant surface.', 'Traditional stainless steel sickle scalers and Gracey curettes cause micro-scratches on titanium surfaces, leading to increased plaque retention and peri-implantitis risk.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Implant Maintenance and Care');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Implant Maintenance and Care' LIMIT 1));

-- Question 24: What instrument is shown in the image an...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Dental Surgery%' OR specialty_name LIKE '%Oral Surgery%' LIMIT 1), 18),
  'What instrument is shown in the image and what is its primary use?',
  24,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q24.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Hemostat – for controlling bleeding', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Chalazion forceps – for stabilizing the lip during minor oral surgery (e.g., biopsy)', 1, 'Chalazion forceps have a ring-shaped loop on one side and a solid flat plate on the other with a locking screw. In oral surgery, they are commonly used during minor labial surgery (such as lower lip mucocele excision or minor salivary gland biopsy) to stabilize the lip, provide hemostasis, and isolate the surgical field.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Tissue forceps – for suturing', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Needle holder – for holding sutures', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Chalazion forceps have a ring-shaped loop on one side and a solid flat plate on the other with a locking screw. In oral surgery, they are commonly used during minor labial surgery (such as lower lip mucocele excision or minor salivary gland biopsy) to stabilize the lip, provide hemostasis, and isolate the surgical field.', 'Hemostats have transverse serrations for clamping blood vessels. Standard tissue forceps have toothed tips for grasping tissues. Needle holders have cross-hatched jaws with a central groove to hold suture needles.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Surgical Instruments and Techniques');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Surgical Instruments and Techniques' LIMIT 1));

-- Question 25: A patient presents with tissue growth be...
INSERT INTO questions (specialty_id, question_text, question_number, difficulty_level, question_source, image_url, estimated_time_seconds, is_active, is_free, ai_verified, created_at, updated_at) VALUES (
  COALESCE((SELECT specialty_id FROM specialties WHERE specialty_name LIKE '%Prosthodontics%' OR specialty_name LIKE '%Prosthodontics%' LIMIT 1), 18),
  'A patient presents with tissue growth beneath a pontic of a fixed partial denture as shown in the image. What is the most likely diagnosis?',
  25,
  'medium',
  'What is this lesion Docx',
  '/uploads/questions/lesion_q25.jpeg',
  60, 1, 1, 1, NOW(), NOW()
);
SET @qid = LAST_INSERT_ID();

INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'A', 'Inflammatory fibrous hyperplasia', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'B', 'Subpontic osseous hyperplasia', 1, 'Subpontic osseous hyperplasia (subpontic hyperostosis) is a benign, reactive bone proliferation developing from the alveolar crest beneath the pontic of a fixed partial denture, typically in the posterior mandible, stimulated by mechanical forces and hygiene factors.', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'C', 'Pyogenic granuloma', 0, '', NOW());
INSERT INTO question_options (question_id, option_label, option_text, is_correct, explanation, created_at) VALUES (@qid, 'D', 'Peripheral ossifying fibroma', 0, '', NOW());
INSERT INTO question_explanations (question_id, correct_explanation, why_others_wrong, `references`, ai_generated, ai_model, created_at, updated_at) VALUES (@qid, 'Subpontic osseous hyperplasia (subpontic hyperostosis) is a benign, reactive bone proliferation developing from the alveolar crest beneath the pontic of a fixed partial denture, typically in the posterior mandible, stimulated by mechanical forces and hygiene factors.', 'Inflammatory fibrous hyperplasia is soft tissue proliferation due to chronic friction. Pyogenic granuloma is a vascular, red, bleeding gingival mass. Peripheral ossifying fibroma occurs on the gingival margin rather than as a hard subpontic osseous mass.', 'Clinical Dental Examination', 1, 'Verified Clinical Expert', NOW(), NOW());
INSERT IGNORE INTO question_tags (tag_name) VALUES ('Overdentures and Abutment Management');
INSERT IGNORE INTO question_tag_mapping (question_id, tag_id) VALUES (@qid, (SELECT tag_id FROM question_tags WHERE tag_name = 'Overdentures and Abutment Management' LIMIT 1));

SET FOREIGN_KEY_CHECKS = 1;
