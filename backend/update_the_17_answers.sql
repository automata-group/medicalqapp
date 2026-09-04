-- ==============================================================================
-- UPDATE CORRECT ANSWERS FOR THE 17 QUESTIONS WITHOUT CHECKMARKS IN ORIGINAL DOCX
-- Source: اساله جديده.docx
-- ==============================================================================

SET NAMES utf8mb4;

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
