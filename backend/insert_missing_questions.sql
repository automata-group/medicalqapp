-- ==============================================================================
-- SAFE IMPORT OF 45 MISSING QUESTIONS (STRICT DEDUPLICATION)
-- Source: اساله جديده.docx
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Question #1 (Endodontics - hard)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'Note: EDTA is commonly used at a concentration of approximately 17%. Its contact time should be limited because prolonged exposure may cause excessive dentin demineralization. 89. Which of the following root canal sealers is considered resorbable and is commonly associated with temporary canal filling materials?', 'hard', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Note: EDTA is commonly used at a concentration of approximately 17%. Its contact time should be limited because prolonged exposure may cause excessive dentin demineralization. 89. Which of the following root canal sealers is considered resorbable and is commonly associated with temporary canal filling materials?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Note: EDTA is commonly used at a concentration of approximately 17%. Its contact time should be limited because prolonged exposure may cause excessive dentin demineralization. 89. Which of the following root canal sealers is considered resorbable and is commonly associated with temporary canal filling materials?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Zinc oxide–eugenol (ZOE) sealer', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Epoxy resin sealer', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Mineral trioxide aggregate (MTA)', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Resin-based sealer', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #2 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'A patient experiences postoperative pain following root canal treatment. Which of the following is generally considered the first-line analgesic for controlling endodontic pain?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient experiences postoperative pain following root canal treatment. Which of the following is generally considered the first-line analgesic for controlling endodontic pain?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient experiences postoperative pain following root canal treatment. Which of the following is generally considered the first-line analgesic for controlling endodontic pain?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'NSAID such as ibuprofen', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Acetaminophen only', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Antibiotics', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Corticosteroids', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #3 (Restorative - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'What is the typical shape of the access cavity for the maxillary first and second premolars?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'What is the typical shape of the access cavity for the maxillary first and second premolars?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'What is the typical shape of the access cavity for the maxillary first and second premolars?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Oval', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Triangular', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Square', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Circular', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #4 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'A patient presents with a craze line involving the enamel of a posterior tooth. There is no pain, no caries, and no evidence of pulpal or periodontal involvement. What is the most appropriate management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient presents with a craze line involving the enamel of a posterior tooth. There is no pain, no caries, and no evidence of pulpal or periodontal involvement. What is the most appropriate management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient presents with a craze line involving the enamel of a posterior tooth. There is no pain, no caries, and no evidence of pulpal or periodontal involvement. What is the most appropriate management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Full-coverage crown', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Root canal treatment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Extraction', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'No treatment; monitor the tooth', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #5 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'A young patient presents with a horizontal mid-root fracture of a maxillary central incisor following trauma. The coronal segment is displaced. What is the most appropriate initial management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A young patient presents with a horizontal mid-root fracture of a maxillary central incisor following trauma. The coronal segment is displaced. What is the most appropriate initial management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A young patient presents with a horizontal mid-root fracture of a maxillary central incisor following trauma. The coronal segment is displaced. What is the most appropriate initial management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Extraction of the coronal segment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Reposition the coronal segment and apply a flexible/semi-rigid splint for approximately 4 weeks', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Immediate root canal treatment of both fragments', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'No treatment and no follow-up', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #6 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'Following dental trauma, a maxillary central incisor appears elongated compared with the adjacent tooth. Which type of luxation injury is most likely?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Following dental trauma, a maxillary central incisor appears elongated compared with the adjacent tooth. Which type of luxation injury is most likely?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Following dental trauma, a maxillary central incisor appears elongated compared with the adjacent tooth. Which type of luxation injury is most likely?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Intrusion', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Lateral luxation', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Extrusion', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Concussion', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #7 (Restorative - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'An avulsed permanent tooth has been kept in an appropriate storage medium for 30 minutes before replantation. What type of splint is generally recommended after replantation?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'An avulsed permanent tooth has been kept in an appropriate storage medium for 30 minutes before replantation. What type of splint is generally recommended after replantation?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'An avulsed permanent tooth has been kept in an appropriate storage medium for 30 minutes before replantation. What type of splint is generally recommended after replantation?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Rigid splint for 4 weeks', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Flexible splint for approximately 2 weeks', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Rigid splint for 2 months', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'No splint is required', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #8 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'According to Angle''s classification, which relationship describes a Class I molar relationship?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'According to Angle''s classification, which relationship describes a Class I molar relationship?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'According to Angle''s classification, which relationship describes a Class I molar relationship?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'The mesiobuccal cusp of the maxillary first molar occludes distal to the mandibular first molar', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'The mesiobuccal cusp of the maxillary first molar occludes mesial to the mandibular first molar', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'The mesiobuccal cusp of the maxillary first molar occludes with the mesiobuccal groove of the mandibular first molar', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'The maxillary and mandibular molars do not contact each other', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #9 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'A 14-year-old patient requires multiple extractions as part of an orthodontic treatment plan, but the patient''s father refuses the proposed extractions. What is the most appropriate initial management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A 14-year-old patient requires multiple extractions as part of an orthodontic treatment plan, but the patient''s father refuses the proposed extractions. What is the most appropriate initial management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A 14-year-old patient requires multiple extractions as part of an orthodontic treatment plan, but the patient''s father refuses the proposed extractions. What is the most appropriate initial management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Proceed with the extractions without the father''s consent', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Discontinue orthodontic treatment immediately', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Discuss the reasons for the extractions, address the parent''s concerns, and explain possible alternatives', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Refer the patient directly for surgical extraction', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #10 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'Which surgical technique can be used to set back the mandible in a patient with mandibular prognathism?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which surgical technique can be used to set back the mandible in a patient with mandibular prognathism?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which surgical technique can be used to set back the mandible in a patient with mandibular prognathism?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Bilateral sagittal split osteotomy (BSSO)', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Vertical ramus osteotomy', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Le Fort I osteotomy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Surgically assisted rapid palatal expansion', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #11 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A patient with a fixed orthodontic appliance presents four weeks after placement complaining of ulceration and soreness caused by an excessively long distal archwire. What is the most appropriate management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with a fixed orthodontic appliance presents four weeks after placement complaining of ulceration and soreness caused by an excessively long distal archwire. What is the most appropriate management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with a fixed orthodontic appliance presents four weeks after placement complaining of ulceration and soreness caused by an excessively long distal archwire. What is the most appropriate management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Clip the excess archwire', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Prescribe antibiotics', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Remove the entire appliance', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Wait until the next scheduled appointment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #12 (Orthodontics - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'Which of the following best describes a Class I malocclusion?', 'easy', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which of the following best describes a Class I malocclusion?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which of the following best describes a Class I malocclusion?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Perfectly aligned teeth with ideal occlusion', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Normal anteroposterior molar relationship with crowding, spacing, or other dental discrepancies', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Mandibular molars positioned distally to the maxillary molars', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Mandibular molars positioned mesially to the maxillary molars', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #13 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A 14-year-old patient presents with a Class II malocclusion. Which treatment is most appropriate according to the provided options?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A 14-year-old patient presents with a Class II malocclusion. Which treatment is most appropriate according to the provided options?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A 14-year-old patient presents with a Class II malocclusion. Which treatment is most appropriate according to the provided options?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Extraction', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Molar distalization', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Maxillary expansion only', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Orthognathic surgery', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #14 (Orthodontics - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'Which of the following best describes a pseudo-Class III malocclusion?', 'easy', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which of the following best describes a pseudo-Class III malocclusion?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which of the following best describes a pseudo-Class III malocclusion?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'A true skeletal mandibular prognathism', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'A functional forward shift of the mandible caused by occlusal interference', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'A maxillary vertical excess', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'A severe posterior open bite', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #15 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A cephalometric analysis shows SNA = 82°, SNB = 70°, and ANB = 11°. What is the most likely skeletal diagnosis?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A cephalometric analysis shows SNA = 82°, SNB = 70°, and ANB = 11°. What is the most likely skeletal diagnosis?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A cephalometric analysis shows SNA = 82°, SNB = 70°, and ANB = 11°. What is the most likely skeletal diagnosis?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Prognathic maxilla with prognathic mandible', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Retrognathic maxilla with retrognathic mandible', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Prognathic maxilla with retrognathic mandible', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Retrognathic mandible', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #16 (Pediatric Dentistry - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Pediatric Dentistry' LIMIT 1), 'A 9-year-old child presents with a progressively prognathic chin, and the mother reports a strong family history of mandibular prognathism. What is the most appropriate management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A 9-year-old child presents with a progressively prognathic chin, and the mother reports a strong family history of mandibular prognathism. What is the most appropriate management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A 9-year-old child presents with a progressively prognathic chin, and the mother reports a strong family history of mandibular prognathism. What is the most appropriate management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Begin growth modification therapy now', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Wait until age 14 before initiating treatment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Wait until growth is completely finished', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Proceed directly with orthognathic surgery', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #17 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'Study casts show that the mandibular arch is positioned buccal to the maxillary arch on both sides. What is the diagnosis?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Study casts show that the mandibular arch is positioned buccal to the maxillary arch on both sides. What is the diagnosis?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Study casts show that the mandibular arch is positioned buccal to the maxillary arch on both sides. What is the diagnosis?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Bilateral posterior crossbite', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Unilateral posterior crossbite', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Class II molar relationship', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Anterior open bite', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #18 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A 6-year-old child has a persistent thumb-sucking habit despite repeated attempts at behavior modification. What is the most appropriate next step?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A 6-year-old child has a persistent thumb-sucking habit despite repeated attempts at behavior modification. What is the most appropriate next step?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A 6-year-old child has a persistent thumb-sucking habit despite repeated attempts at behavior modification. What is the most appropriate next step?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Palatal habit crib', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Fixed lingual retainer', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Headgear', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Functional appliance', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #19 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'What is the approximate physiologic midline diastema that may still close spontaneously around the age of 8 years?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'What is the approximate physiologic midline diastema that may still close spontaneously around the age of 8 years?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'What is the approximate physiologic midline diastema that may still close spontaneously around the age of 8 years?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', '2 mm', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', '3 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', '4 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', '5 mm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #20 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A patient has sufficient space in the arch and requires retraction of the anterior teeth. Which removable appliance component can be used for this purpose?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient has sufficient space in the arch and requires retraction of the anterior teeth. Which removable appliance component can be used for this purpose?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient has sufficient space in the arch and requires retraction of the anterior teeth. Which removable appliance component can be used for this purpose?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Hawley appliance with an active labial bow', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Posterior bite plane', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Quad-helix appliance', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Palatal crib', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #21 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'An 8-year-old growing patient presents with mandibular retrognathism. Which treatment is most appropriate to utilize the patient''s remaining growth?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'An 8-year-old growing patient presents with mandibular retrognathism. Which treatment is most appropriate to utilize the patient''s remaining growth?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'An 8-year-old growing patient presents with mandibular retrognathism. Which treatment is most appropriate to utilize the patient''s remaining growth?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Functional appliance', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Orthognathic surgery', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Extraction therapy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Fixed retainer', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #22 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A patient who has been wearing a fixed orthodontic appliance for 3 months presents to the emergency clinic with diffuse erythema involving one buccal mucosal area. What is the most likely cause?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient who has been wearing a fixed orthodontic appliance for 3 months presents to the emergency clinic with diffuse erythema involving one buccal mucosal area. What is the most likely cause?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient who has been wearing a fixed orthodontic appliance for 3 months presents to the emergency clinic with diffuse erythema involving one buccal mucosal area. What is the most likely cause?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Mechanical trauma', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Nickel-titanium hypersensitivity', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Irritation from the orthodontic wire', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Aphthous ulceration', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #23 (Pediatric Dentistry - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Pediatric Dentistry' LIMIT 1), 'If community water fluoridation is not available, which topical fluoride method is considered the most cost-effective option among the following?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'If community water fluoridation is not available, which topical fluoride method is considered the most cost-effective option among the following?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'If community water fluoridation is not available, which topical fluoride method is considered the most cost-effective option among the following?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Fluoride varnish', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Fluoride gel', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Fluoride mouthrinse', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Fluoride supplements', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #24 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'In a deep carious lesion severe enough to destroy the original odontoblasts, which type of dentin is formed as part of the pulpal defense response?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'In a deep carious lesion severe enough to destroy the original odontoblasts, which type of dentin is formed as part of the pulpal defense response?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'In a deep carious lesion severe enough to destroy the original odontoblasts, which type of dentin is formed as part of the pulpal defense response?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Reparative dentin', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Secondary dentin', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Primary dentin', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Reactionary dentin', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #25 (Endodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Endodontics' LIMIT 1), 'Which type of root resorption is a recognized complication of internal non-vital bleaching using the walking-bleach technique?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which type of root resorption is a recognized complication of internal non-vital bleaching using the walking-bleach technique?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which type of root resorption is a recognized complication of internal non-vital bleaching using the walking-bleach technique?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Internal resorption', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'External cervical resorption', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Replacement resorption', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Surface resorption Developmental Dental Abnormalities', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #26 (Restorative - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'Taurodontism may be associated with which hereditary enamel disorder?', 'easy', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Taurodontism may be associated with which hereditary enamel disorder?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Taurodontism may be associated with which hereditary enamel disorder?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Amelogenesis imperfecta', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Dentinogenesis imperfecta', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Dentin dysplasia', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Regional odontodysplasia', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #27 (Prosthodontics - hard)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'During evaluation of a young patient''s occlusion, the dentist identifies an interference during an eccentric mandibular movement, while the centric relationship is normal. If the interference involves the anterior teeth during protrusion, which surface should be adjusted according to the provided notes?', 'hard', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'During evaluation of a young patient''s occlusion, the dentist identifies an interference during an eccentric mandibular movement, while the centric relationship is normal. If the interference involves the anterior teeth during protrusion, which surface should be adjusted according to the provided notes?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'During evaluation of a young patient''s occlusion, the dentist identifies an interference during an eccentric mandibular movement, while the centric relationship is normal. If the interference involves the anterior teeth during protrusion, which surface should be adjusted according to the provided notes?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Maxillary incisal edge', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Mandibular incisal edge', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Buccal surface of the maxillary tooth', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Buccal surface of the mandibular tooth', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #28 (Restorative - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'Which term describes the ability of a tooth preparation to prevent a fixed restoration from being dislodged by forces acting parallel to its path of placement?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which term describes the ability of a tooth preparation to prevent a fixed restoration from being dislodged by forces acting parallel to its path of placement?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which term describes the ability of a tooth preparation to prevent a fixed restoration from being dislodged by forces acting parallel to its path of placement?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Resistance form', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Retention form', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Structural durability', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Marginal integrity', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #29 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'A patient undergoes surgical crown lengthening before receiving a definitive fixed prosthesis. Approximately how long should the clinician wait before making the final impression to allow adequate periodontal tissue maturation?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient undergoes surgical crown lengthening before receiving a definitive fixed prosthesis. Approximately how long should the clinician wait before making the final impression to allow adequate periodontal tissue maturation?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient undergoes surgical crown lengthening before receiving a definitive fixed prosthesis. Approximately how long should the clinician wait before making the final impression to allow adequate periodontal tissue maturation?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', '3 months', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', '6 months', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', '2 months', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', '9 months', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #30 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'A patient recently received a crown on a maxillary molar. When the patient closes into occlusion, the mandible is deflected in an anterosuperior direction. According to the provided notes, what type of occlusal interference is present?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient recently received a crown on a maxillary molar. When the patient closes into occlusion, the mandible is deflected in an anterosuperior direction. According to the provided notes, what type of occlusal interference is present?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient recently received a crown on a maxillary molar. When the patient closes into occlusion, the mandible is deflected in an anterosuperior direction. According to the provided notes, what type of occlusal interference is present?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Centric interference', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Eccentric interference', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Protrusive interference', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Working-side interference', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #31 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'During a preliminary impression for a removable prosthesis, the clinician needs to modify the extension of a stock impression tray before making the impression. Which type of wax is most appropriate?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'During a preliminary impression for a removable prosthesis, the clinician needs to modify the extension of a stock impression tray before making the impression. Which type of wax is most appropriate?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'During a preliminary impression for a removable prosthesis, the clinician needs to modify the extension of a stock impression tray before making the impression. Which type of wax is most appropriate?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Boxing wax', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Pattern wax', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Joining wax', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Utility wax', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #32 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'Which type of rest is most commonly used on the occlusal surface of a posterior abutment tooth in a removable partial denture?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which type of rest is most commonly used on the occlusal surface of a posterior abutment tooth in a removable partial denture?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which type of rest is most commonly used on the occlusal surface of a posterior abutment tooth in a removable partial denture?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Occlusal rest', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Incisal rest', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Lingual rest', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Cingulum rest', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #33 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'A young patient has severely decayed but restorable teeth and requests extraction of all teeth and complete dentures. What should be done?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A young patient has severely decayed but restorable teeth and requests extraction of all teeth and complete dentures. What should be done?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A young patient has severely decayed but restorable teeth and requests extraction of all teeth and complete dentures. What should be done?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Refer the patient to a psychiatrist', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Extract all teeth', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Fabricate immediate dentures', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Perform elective root canal treatment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #34 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'A complete denture patient complains of difficulty swallowing. What is the most likely cause?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A complete denture patient complains of difficulty swallowing. What is the most likely cause?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A complete denture patient complains of difficulty swallowing. What is the most likely cause?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Extended posterior palatal seal', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Overextended lingual flange', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Underextended labial flange', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Insufficient vertical dimension', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #35 (Orthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Orthodontics' LIMIT 1), 'A patient receives a new denture but cannot wear it the next day. What is the likely cause?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient receives a new denture but cannot wear it the next day. What is the likely cause?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient receives a new denture but cannot wear it the next day. What is the likely cause?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Shrinkage', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Expansion', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Increased salivary flow', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Ridge hypertrophy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #36 (Prosthodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Prosthodontics' LIMIT 1), 'A complete denture patient who is also a smoker complains of redness under the denture. Traces of the denture flanges can be seen on the patient''s mucosa. What is the management?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A complete denture patient who is also a smoker complains of redness under the denture. Traces of the denture flanges can be seen on the patient''s mucosa. What is the management?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A complete denture patient who is also a smoker complains of redness under the denture. Traces of the denture flanges can be seen on the patient''s mucosa. What is the management?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Remove the denture temporarily', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Tissue conditioner and antifungal therapy', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Rebase the denture', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Construct a new denture', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #37 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A patient has undergone multiple cosmetic procedures and fillers and is requesting further cosmetic treatment of the chin. She is underweight and is excessively concerned about her physical appearance. What is the most likely diagnosis?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient has undergone multiple cosmetic procedures and fillers and is requesting further cosmetic treatment of the chin. She is underweight and is excessively concerned about her physical appearance. What is the most likely diagnosis?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient has undergone multiple cosmetic procedures and fillers and is requesting further cosmetic treatment of the chin. She is underweight and is excessively concerned about her physical appearance. What is the most likely diagnosis?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Anorexia nervosa', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Body dysmorphic disorder', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Bulimia nervosa', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Generalized anxiety disorder', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #38 (Restorative - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'A patient with hypothyroidism has been unable to eat or take medication for 3 days. A sedative is administered for dental treatment. Which complication may develop?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with hypothyroidism has been unable to eat or take medication for 3 days. A sedative is administered for dental treatment. Which complication may develop?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with hypothyroidism has been unable to eat or take medication for 3 days. A sedative is administered for dental treatment. Which complication may develop?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Thyroid storm', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Myxedema coma', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Adrenal crisis', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Hyperglycemic crisis', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #39 (Restorative - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'In a patient with asthma, what is the best method to assess the severity of symptoms?', 'easy', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'In a patient with asthma, what is the best method to assess the severity of symptoms?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'In a patient with asthma, what is the best method to assess the severity of symptoms?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Chest X-ray', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'MRI', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Clinical symptoms', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Oxygen level', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #40 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'A patient with active tuberculosis requires emergency dental treatment. What precaution should be taken?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with active tuberculosis requires emergency dental treatment. What precaution should be taken?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with active tuberculosis requires emergency dental treatment. What precaution should be taken?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Use a high-filtration respiratory mask', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Schedule the patient first in the morning', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Treat the patient in a regular dental setting', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Use only a standard surgical mask', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #41 (Dental Surgery - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Surgery' LIMIT 1), 'A patient with stage IV cancer has a questionable tooth. What is the preferred treatment according to the provided material?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with stage IV cancer has a questionable tooth. What is the preferred treatment according to the provided material?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with stage IV cancer has a questionable tooth. What is the preferred treatment according to the provided material?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Root canal treatment', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Extraction', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'No treatment', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Implant placement', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #42 (Periodontics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Periodontics' LIMIT 1), 'A patient presents with gingival enlargement, easy bruising, bone pain, flu-like symptoms for 6 months, and clinically palpable lymph nodes. What should be done first?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient presents with gingival enlargement, easy bruising, bone pain, flu-like symptoms for 6 months, and clinically palpable lymph nodes. What should be done first?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient presents with gingival enlargement, easy bruising, bone pain, flu-like symptoms for 6 months, and clinically palpable lymph nodes. What should be done first?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Gingival biopsy', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Neck ultrasound', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Peripheral blood smear', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Fine-needle aspiration cytology of the lymph node', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #43 (Restorative - easy)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'Which of the following is a doctor''s duty toward the profession?', 'easy', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'Which of the following is a doctor''s duty toward the profession?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'Which of the following is a doctor''s duty toward the profession?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Treat patients equally', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Continuous learning', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Give priority to relatives', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Avoid referring patients', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #44 (Restorative - hard)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Restorative' LIMIT 1), 'A 30-year-old patient is in a deep coma after a road traffic accident and is on life support. Before the accident, he authorized his wife in writing to make treatment decisions if he became unconscious. His family, led by his father, disagrees with the wife''s decision. According to the provided Sharia-based scenario, who can decide the course of treatment?', 'hard', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A 30-year-old patient is in a deep coma after a road traffic accident and is on life support. Before the accident, he authorized his wife in writing to make treatment decisions if he became unconscious. His family, led by his father, disagrees with the wife''s decision. According to the provided Sharia-based scenario, who can decide the course of treatment?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A 30-year-old patient is in a deep coma after a road traffic accident and is on life support. Before the accident, he authorized his wife in writing to make treatment decisions if he became unconscious. His family, led by his father, disagrees with the wife''s decision. According to the provided Sharia-based scenario, who can decide the course of treatment?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Wife', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Court', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'His father', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'The doctor', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- Question #45 (Dental Ethics - medium)
INSERT INTO Questions (specialtyId, text, difficulty, timeEstimate, isActive, isPremium, source, verifiedByAI, createdAt, updatedAt)
SELECT (SELECT id FROM Specialties WHERE name = 'Dental Ethics' LIMIT 1), 'A patient with Alzheimer''s disease lacks decision-making capacity. From whom should consent be obtained?', 'medium', 60, 1, 0, 'اساله جديده.docx', 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Questions WHERE text = 'A patient with Alzheimer''s disease lacks decision-making capacity. From whom should consent be obtained?');

SET @new_qid = (SELECT id FROM Questions WHERE text = 'A patient with Alzheimer''s disease lacks decision-making capacity. From whom should consent be obtained?' LIMIT 1);
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'A', 'Sons or daughters', 1, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'A');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'B', 'Driver', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'B');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'C', 'Dental assistant', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'C');
INSERT INTO Options (questionId, `order`, text, isCorrect, createdAt, updatedAt)
SELECT @new_qid, 'D', 'Receptionist', 0, NOW(), NOW()
WHERE @new_qid IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Options WHERE questionId = @new_qid AND `order` = 'D');

-- ==============================================================================
-- UPDATE CORRECT ANSWERS FOR THE 17 QUESTIONS WITHOUT CHECKMARKS IN ORIGINAL DOCX
-- ==============================================================================

-- 1. Preparation bur inclination error -> D) Excessive taper
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'D' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE '%If the bur is excessively inclined toward the tooth, which preparation error%'
);

-- 2. Partially edentulous lost all posterior teeth -> A) Establish posterior artificial teeth in harmony with remaining anterior occlusion
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A partially edentulous patient has lost all posterior teeth while the anterior teeth remain%'
);

-- 3. Tilted posterior abutment rest -> B) Extended occlusal rest
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'B' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A posterior abutment tooth is significantly tilted, making conventional placement of an occlusal rest difficult%'
);

-- 4. Rest placed on canine problem -> A) Inadequate rest-seat preparation
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A clinical photograph shows a rest placed on a canine. The dentist is asked to identify a problem%'
);

-- 5. Tooth #25 with acceptable MOD amalgam for RPD -> A) Prepare the rest seat in the existing amalgam restoration
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE '%Tooth #25 has a well-condensed and clinically acceptable MOD amalgam%'
);

-- 6. Denture pronunciation "S" sounds like "TH" -> A) Upper incisors are set too far palatally
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE '%When pronouncing “S,” it sounds like “TH”%'
);

-- 7. Denture pronunciation "V" instead of "F" -> A) Anterior teeth positioned more incisally
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE '%A complete denture patient pronounces “V” instead of “F”%'
);

-- 8. Treatment of osteoradionecrosis -> D) Management depends on the severity and clinical presentation
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'D' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'What is the treatment of osteoradionecrosis?%'
);

-- 9. Perioperative measure in chronic steroid patient -> A) Provide perioperative supplemental corticosteroids
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'What perioperative measure should be taken to prevent complications during and after surgery?%'
);

-- 10. Acute intraoperative hypotension & adrenal crisis -> A) Administer IV hydrocortisone and supportive IV fluids
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'If the patient becomes hypotensive and develops nausea, fever, and confusion intraoperatively%'
);

-- 11. Extraction in patient on bisphosphonates -> D) Start 1 day before and continue for 3 days after the procedure
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'D' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A patient taking bisphosphonates requires a dental extraction. When should prophylactic antibiotics be given?%'
);

-- 12. Down syndrome consent capable -> D was proxy, change to Patient and set isCorrect = 1
UPDATE Options 
SET text = 'Patient', isCorrect = 1 
WHERE `order` = 'D' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A patient with Down syndrome is assessed by a psychologist and found capable of making treatment decisions%'
);

-- 13. Implant component connecting fixture to restoration -> A) Prosthetic abutment
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'Which implant component connects the implant fixture to the prosthetic restoration?%'
);

-- 14. Component during soft-tissue healing -> A) Healing abutment
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'Which component is used on the implant during soft-tissue healing?%'
);

-- 15. Avoid needlestick injury intraorally -> A) Use a mirror
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'What is the best way to avoid a needlestick injury while working intraorally?%'
);

-- 16. Lateral cephalometric skeletal abnormality -> A) Retrognathic mandible
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'A' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A lateral cephalometric radiograph is provided. Which skeletal abnormality is present?%'
);

-- 17. Fascial space infection with trismus (#36) -> B) Submasseteric space
UPDATE Options 
SET isCorrect = 1 
WHERE `order` = 'B' AND questionId IN (
    SELECT id FROM Questions WHERE text LIKE 'A patient presents with pain, fever, and limited mouth opening associated with tooth #36. Which fascial space infection is most likely?%'
);

SET FOREIGN_KEY_CHECKS = 1;
SELECT COUNT(*) AS total_questions_after_import FROM Questions;
