-- ==============================================================================
-- 1. MERGE DENTAL SURGERY & ORAL SURGERY -> "Oral Surgery"
-- 2. CREATE DEDICATED SPECIALTY FOR "Sterilization and Infection Control"
-- ==============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Step 1: Reassign foreign keys from id: 17 to id: 13
UPDATE Questions SET specialtyId = 13 WHERE specialtyId = 17;
UPDATE Topics SET specialtyId = 13 WHERE specialtyId = 17;
UPDATE UserSpecialties SET specialtyId = 13 WHERE specialtyId = 17;
UPDATE MockQuestions SET specialtyId = 13 WHERE specialtyId = 17;
UPDATE MockExams SET specialtyId = 13 WHERE specialtyId = 17;

-- Remove redundant row id: 17 or any duplicate named 'Oral Surgery' with id != 13
DELETE FROM Specialties WHERE id = 17;
DELETE FROM Specialties WHERE name = 'Oral Surgery' AND id != 13;

-- Rename id: 13 to 'Oral Surgery'
UPDATE Specialties 
SET name = 'Oral Surgery', 
    icon = '/uploads/image-1778481265938-25855660.png',
    sortOrder = 7,
    updatedAt = NOW() 
WHERE id = 13;

-- Fallback insert if id 13 was missing
INSERT INTO Specialties (id, name, icon, sortOrder, isPremium, isActive, createdAt, updatedAt)
SELECT 13, 'Oral Surgery', '/uploads/image-1778481265938-25855660.png', 7, 0, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Specialties WHERE name = 'Oral Surgery');

-- Step 2: Create dedicated specialty for "Sterilization and Infection Control"
INSERT INTO Specialties (name, icon, sortOrder, isPremium, isActive, createdAt, updatedAt)
SELECT 'Sterilization and Infection Control', '/uploads/image-1778481636430-916219122.png', 10, 0, 1, NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM Specialties WHERE name = 'Sterilization and Infection Control');

-- Update sortOrder for clean visual ordering
UPDATE Specialties SET sortOrder = 1 WHERE name = 'Orthodontics';
UPDATE Specialties SET sortOrder = 2 WHERE name = 'Endodontics';
UPDATE Specialties SET sortOrder = 3 WHERE name = 'Prosthodontics';
UPDATE Specialties SET sortOrder = 4 WHERE name = 'Periodontics';
UPDATE Specialties SET sortOrder = 5 WHERE name = 'Pediatric Dentistry';
UPDATE Specialties SET sortOrder = 6 WHERE name = 'Restorative';
UPDATE Specialties SET sortOrder = 7 WHERE name = 'Oral Surgery';
UPDATE Specialties SET sortOrder = 8 WHERE name = 'Oral Medicine & Pathology';
UPDATE Specialties SET sortOrder = 9 WHERE name = 'Dental Ethics';
UPDATE Specialties SET sortOrder = 10 WHERE name = 'Sterilization and Infection Control';
UPDATE Specialties SET sortOrder = 11 WHERE name = 'Oral Radiology';

SET FOREIGN_KEY_CHECKS = 1;

-- Verify final list
SELECT id, name, sortOrder, isActive FROM Specialties ORDER BY sortOrder, id;
