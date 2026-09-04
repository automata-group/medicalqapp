-- ==============================================================================
-- SAFE IMPORT OF 19 MISSING QUESTIONS FROM "اساله جديده 22.docx"
-- STRICT DEDUPLICATION ENFORCED (WHERE NOT EXISTS)
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Question #1 (Orthodontics - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'What does a dolichofacial facial pattern indicate?', 'easy', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'What does a dolichofacial facial pattern indicate?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'What does a dolichofacial facial pattern indicate?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Short face', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Long face', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Broad face', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Asymmetrical face', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #2 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A consultant disagrees with a treatment plan prepared by a general practitioner and tells the patient directly that the GP''s treatment plan is wrong. What professional violation has occurred?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A consultant disagrees with a treatment plan prepared by a general practitioner and tells the patient directly that the GP''s treatment plan is wrong. What professional violation has occurred?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A consultant disagrees with a treatment plan prepared by a general practitioner and tells the patient directly that the GP''s treatment plan is wrong. What professional violation has occurred?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Direct criticism of a colleague', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Violation of patient autonomy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Breach of confidentiality', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Conflict of interest', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #3 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'Application of approximately 400 g of force during canine retraction is most likely to result in:', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Application of approximately 400 g of force during canine retraction is most likely to result in:');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Application of approximately 400 g of force during canine retraction is most likely to result in:' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Hyalinization', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Frontal resorption', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Physiologic tooth movement', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'No periodontal response', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #4 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'An intern discusses the serious medical condition of the medical director''s wife with a colleague who is not involved in her care. What has been violated?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'An intern discusses the serious medical condition of the medical director''s wife with a colleague who is not involved in her care. What has been violated?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'An intern discusses the serious medical condition of the medical director''s wife with a colleague who is not involved in her care. What has been violated?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Confidentiality', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Autonomy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Justice', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Beneficence', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #5 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A dentist repeatedly persuades a child and his mother to change their preferred treatment option until they agree with the dentist''s choice. Which ethical principle has been violated?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A dentist repeatedly persuades a child and his mother to change their preferred treatment option until they agree with the dentist''s choice. Which ethical principle has been violated?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A dentist repeatedly persuades a child and his mother to change their preferred treatment option until they agree with the dentist''s choice. Which ethical principle has been violated?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Autonomy', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Beneficence', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Justice', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Non-maleficence', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #6 (Dental Ethics - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'Caseating granulomas of the lungs are characteristic of which disease?', 'easy', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Caseating granulomas of the lungs are characteristic of which disease?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Caseating granulomas of the lungs are characteristic of which disease?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Tuberculosis', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Sarcoidosis', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Pneumonia', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Asthma', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #7 (Oral Medicine & Pathology - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Oral Medicine & Pathology' LIMIT 1), 'What is the best storage/fixation medium for a routine biopsy specimen?', 'easy', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'What is the best storage/fixation medium for a routine biopsy specimen?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'What is the best storage/fixation medium for a routine biopsy specimen?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Formalin', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Normal saline', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Distilled water', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Hydrogen peroxide', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #8 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A female dentist invites a male dental technician into the clinic to evaluate a patient''s shade without informing the patient beforehand. The patient becomes upset. What has been breached?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A female dentist invites a male dental technician into the clinic to evaluate a patient''s shade without informing the patient beforehand. The patient becomes upset. What has been breached?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A female dentist invites a male dental technician into the clinic to evaluate a patient''s shade without informing the patient beforehand. The patient becomes upset. What has been breached?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Privacy', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Confidentiality', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Justice', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Veracity', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #9 (Oral Medicine & Pathology - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Oral Medicine & Pathology' LIMIT 1), 'A patient is diagnosed with a malignant tumor. The patient''s son asks the dentist to hide the diagnosis and tell the patient it is only an ulcer. What should the dentist do?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient is diagnosed with a malignant tumor. The patient''s son asks the dentist to hide the diagnosis and tell the patient it is only an ulcer. What should the dentist do?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient is diagnosed with a malignant tumor. The patient''s son asks the dentist to hide the diagnosis and tell the patient it is only an ulcer. What should the dentist do?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Follow the son''s request', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Ask a colleague to conceal the diagnosis', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Tell the patient the truth', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Tell another family member instead', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #10 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A mother reports that her son''s mandible has started to protrude, and his grandfather had a similar prognathic mandible. Which appliance is most appropriate for growth modification?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A mother reports that her son''s mandible has started to protrude, and his grandfather had a similar prognathic mandible. Which appliance is most appropriate for growth modification?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A mother reports that her son''s mandible has started to protrude, and his grandfather had a similar prognathic mandible. Which appliance is most appropriate for growth modification?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Fixed appliance', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Expansion appliance', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Twin block', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Chin cup', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #11 (Dental Ethics - hard)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'Note: Based on the available information, the acute chest pain takes priority over investigating the weight loss. 225. A patient presents with rapidly progressing bilateral submandibular and sublingual swelling with elevation of the tongue and difficulty breathing. What is the most likely diagnosis?', 'hard', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Note: Based on the available information, the acute chest pain takes priority over investigating the weight loss. 225. A patient presents with rapidly progressing bilateral submandibular and sublingual swelling with elevation of the tongue and difficulty breathing. What is the most likely diagnosis?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Note: Based on the available information, the acute chest pain takes priority over investigating the weight loss. 225. A patient presents with rapidly progressing bilateral submandibular and sublingual swelling with elevation of the tongue and difficulty breathing. What is the most likely diagnosis?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Peritonsillar abscess', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Ludwig''s angina', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Buccal space infection', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Submasseteric space infection', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #12 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'What is the best imaging modality for identifying the source and extent of infection in Ludwig''s angina?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'What is the best imaging modality for identifying the source and extent of infection in Ludwig''s angina?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'What is the best imaging modality for identifying the source and extent of infection in Ludwig''s angina?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Contrast-enhanced CT', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Panoramic radiograph', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'MRI without contrast', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Periapical radiograph', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #13 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A mother requests replacement of her child''s satisfactory amalgam restoration. The dentist explains that replacement is unnecessary and successfully convinces her not to replace it. Which ethical principle is demonstrated?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A mother requests replacement of her child''s satisfactory amalgam restoration. The dentist explains that replacement is unnecessary and successfully convinces her not to replace it. Which ethical principle is demonstrated?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A mother requests replacement of her child''s satisfactory amalgam restoration. The dentist explains that replacement is unnecessary and successfully convinces her not to replace it. Which ethical principle is demonstrated?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Veracity', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Autonomy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Justice', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Confidentiality', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #14 (Restorative - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'Note: Depending on the exact Class III etiology, chin cup or Frankel III may also appear as appropriate options. 273. What are the recommended minimum distances between adjacent implants and between an implant and a natural tooth?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Note: Depending on the exact Class III etiology, chin cup or Frankel III may also appear as appropriate options. 273. What are the recommended minimum distances between adjacent implants and between an implant and a natural tooth?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Note: Depending on the exact Class III etiology, chin cup or Frankel III may also appear as appropriate options. 273. What are the recommended minimum distances between adjacent implants and between an implant and a natural tooth?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Implant–implant: 3 mm; implant–tooth: 1.5 mm', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Implant–implant: 1.5 mm; implant–tooth: 3 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Implant–implant: 2 mm; implant–tooth: 2 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Implant–implant: 4 mm; implant–tooth: 3 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #15 (Dental Surgery - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'A CBCT shows an impacted maxillary canine. How should the impaction be classified?', 'easy', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A CBCT shows an impacted maxillary canine. How should the impaction be classified?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A CBCT shows an impacted maxillary canine. How should the impaction be classified?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'According to its actual three-dimensional position on the CBCT', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Buccal in every case', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Horizontal in every case', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Mid-ridge in every case', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #16 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A patient with hypothyroidism presents to the emergency department with severe odontogenic pain and swelling. Intravenous antibiotics have already been administered. What is the most appropriate definitive management?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with hypothyroidism presents to the emergency department with severe odontogenic pain and swelling. Intravenous antibiotics have already been administered. What is the most appropriate definitive management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with hypothyroidism presents to the emergency department with severe odontogenic pain and swelling. Intravenous antibiotics have already been administered. What is the most appropriate definitive management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Continue antibiotics and postpone dental treatment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Administer hydrocortisone', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Incision and drainage only', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Incision and drainage with antibiotic therapy  93.', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #17 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'A patient continues to bleed from an extraction socket despite suturing. What is the most appropriate next step?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient continues to bleed from an extraction socket despite suturing. What is the most appropriate next step?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient continues to bleed from an extraction socket despite suturing. What is the most appropriate next step?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Place a local hemostatic agent in the socket', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Prescribe antibiotics', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Remove the sutures', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Irrigate vigorously with saline 105.', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #18 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A dentist forces a patient to undergo orthodontic treatment despite the patient''s refusal. Which ethical principle has been violated?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A dentist forces a patient to undergo orthodontic treatment despite the patient''s refusal. Which ethical principle has been violated?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A dentist forces a patient to undergo orthodontic treatment despite the patient''s refusal. Which ethical principle has been violated?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Autonomy', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Beneficence', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Justice', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Veracity', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #19 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'After extraction of the maxillary first molar, a 2-mm oroantral communication is detected. What is the appropriate management?', 'medium', 60, 1, 0, 'اساله جديده 22.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'After extraction of the maxillary first molar, a 2-mm oroantral communication is detected. What is the appropriate management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'After extraction of the maxillary first molar, a 2-mm oroantral communication is detected. What is the appropriate management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Place Gelfoam and secure it with a figure-of-eight suture', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'No additional treatment is required', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Leave the socket open until a clot forms', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Perform a buccal advancement flap 2.', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

SET FOREIGN_KEY_CHECKS = 1;
SELECT COUNT(*) AS total_questions_after_import FROM Questions;
