-- 04_security_and_transactions.sql
USE CrownfieldEyeHospital;

-- Run using an administrative account. Create the four roles.
CREATE ROLE IF NOT EXISTS 'r_admin', 'r_doctor', 'r_receptionist', 'r_patient';

-- Administrator: full control of this teaching database.
GRANT ALL PRIVILEGES ON CrownfieldEyeHospital.* TO 'r_admin';

-- Doctor: patient/appointment lookup and clinical record maintenance.
GRANT SELECT ON CrownfieldEyeHospital.Patients TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Appointments TO 'r_doctor';
GRANT SELECT, INSERT, UPDATE ON CrownfieldEyeHospital.Diagnoses TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Prescriptions TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.PrescriptionItems TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Medicines TO 'r_doctor';
GRANT SELECT, INSERT, UPDATE ON CrownfieldEyeHospital.FollowUpPlans TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Clinicians TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Specialties TO 'r_doctor';
GRANT SELECT ON CrownfieldEyeHospital.Clinics TO 'r_doctor';

-- Receptionist: demographics and appointment administration, no clinical details.
GRANT SELECT, INSERT, UPDATE ON CrownfieldEyeHospital.Patients TO 'r_receptionist';
GRANT SELECT, INSERT, UPDATE ON CrownfieldEyeHospital.Appointments TO 'r_receptionist';
GRANT SELECT ON CrownfieldEyeHospital.Clinicians TO 'r_receptionist';
GRANT SELECT ON CrownfieldEyeHospital.Clinics TO 'r_receptionist';

-- Patient identity mapping: create one row per patient database account.
CREATE TABLE IF NOT EXISTS DatabaseUserPatientMap (
    DbUsername VARCHAR(100) PRIMARY KEY,
    PatientID INT NOT NULL UNIQUE,
    CONSTRAINT fk_user_patient
      FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
) ENGINE=InnoDB;

-- View restricts portal results to the patient mapped to the connected DB username.
CREATE OR REPLACE VIEW PatientPortalView AS
SELECT p.PatientID, p.FirstName, p.LastName, p.Postcode,
       a.AppointmentID, a.AppointmentDate, a.AppointmentTime
FROM DatabaseUserPatientMap m
INNER JOIN Patients p ON p.PatientID = m.PatientID
LEFT JOIN Appointments a ON a.PatientID = p.PatientID
WHERE m.DbUsername = SUBSTRING_INDEX(CURRENT_USER(), '@', 1);

GRANT SELECT ON CrownfieldEyeHospital.PatientPortalView TO 'r_patient';

-- Create individual accounts separately with unique strong passwords, then assign roles.
-- Example account names (create them before running the GRANT statements below):
-- CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'REPLACE_WITH_STRONG_SECRET';
-- CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'REPLACE_WITH_STRONG_SECRET';
-- CREATE USER 'reception_user'@'localhost' IDENTIFIED BY 'REPLACE_WITH_STRONG_SECRET';
-- CREATE USER 'patient_1'@'localhost' IDENTIFIED BY 'REPLACE_WITH_STRONG_SECRET';
-- GRANT 'r_admin' TO 'admin_user'@'localhost';
-- GRANT 'r_doctor' TO 'doctor_user'@'localhost';
-- GRANT 'r_receptionist' TO 'reception_user'@'localhost';
-- GRANT 'r_patient' TO 'patient_1'@'localhost';
-- SET DEFAULT ROLE 'r_admin' TO 'admin_user'@'localhost';
-- SET DEFAULT ROLE 'r_doctor' TO 'doctor_user'@'localhost';
-- SET DEFAULT ROLE 'r_receptionist' TO 'reception_user'@'localhost';
-- SET DEFAULT ROLE 'r_patient' TO 'patient_1'@'localhost';
-- INSERT INTO DatabaseUserPatientMap (DbUsername, PatientID) VALUES ('patient_1', 1);
-- Confirm privileges using: SHOW GRANTS FOR 'doctor_user'@'localhost';

-- Encryption demonstration. Do not put production keys in SQL source control.
CREATE TABLE IF NOT EXISTS SensitivePatientNotes (
    NoteID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT NOT NULL,
    EncryptedNote VARBINARY(1024) NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
) ENGINE=InnoDB;

-- Set a temporary demonstration key for this session only.
SET @demo_encryption_key = 'ReplaceThisDemoKey_OnlyForClass';
INSERT INTO SensitivePatientNotes (PatientID, EncryptedNote)
VALUES (1, AES_ENCRYPT('Synthetic example note - not real patient data', @demo_encryption_key));

-- Decrypt only in an authorised test session:
SELECT NoteID, PatientID,
       CAST(AES_DECRYPT(EncryptedNote, @demo_encryption_key) AS CHAR) AS DecryptedNote
FROM SensitivePatientNotes
WHERE PatientID = 1;

-- Transaction test: first value is temporary; ROLLBACK restores prior committed value.
START TRANSACTION;
UPDATE Patients SET Postcode = 'NE1 5YY' WHERE PatientID = 1;
SELECT PatientID, Postcode FROM Patients WHERE PatientID = 1;
ROLLBACK;
SELECT PatientID, Postcode FROM Patients WHERE PatientID = 1;

-- Check transactional engine:
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'CrownfieldEyeHospital';
