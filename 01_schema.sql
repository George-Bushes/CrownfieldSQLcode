-- 01_schema.sql
-- Run this first in MySQL 8.0. The script follows the shared Part A/B schema.
DROP DATABASE IF EXISTS CrownfieldEyeHospital;
CREATE DATABASE CrownfieldEyeHospital;
USE CrownfieldEyeHospital;

CREATE TABLE Specialties (
  SpecialtyID INT PRIMARY KEY AUTO_INCREMENT,
  SpecialtyName VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Clinics (
  ClinicID INT PRIMARY KEY AUTO_INCREMENT,
  ClinicName VARCHAR(50) NOT NULL,
  Location VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Clinicians (
  ClinicianID INT PRIMARY KEY AUTO_INCREMENT,
  ClinicianName VARCHAR(100) NOT NULL,
  SpecialtyID INT,
  FOREIGN KEY (SpecialtyID) REFERENCES Specialties(SpecialtyID)
) ENGINE=InnoDB;

CREATE TABLE Patients (
  PatientID INT PRIMARY KEY AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  Postcode VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Appointments (
  AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
  PatientID INT NOT NULL,
  ClinicianID INT NOT NULL,
  ClinicID INT NOT NULL,
  AppointmentDate DATE NOT NULL,
  AppointmentTime TIME NOT NULL,
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
  FOREIGN KEY (ClinicianID) REFERENCES Clinicians(ClinicianID),
  FOREIGN KEY (ClinicID) REFERENCES Clinics(ClinicID)
) ENGINE=InnoDB;

CREATE TABLE Diagnoses (
  DiagnosisID INT PRIMARY KEY AUTO_INCREMENT,
  AppointmentID INT NOT NULL,
  DiagnosisDetails VARCHAR(255),
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Medicines (
  MedicineID INT PRIMARY KEY AUTO_INCREMENT,
  MedicineName VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Prescriptions (
  PrescriptionID INT PRIMARY KEY AUTO_INCREMENT,
  AppointmentID INT NOT NULL,
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE PrescriptionItems (
  ItemID INT PRIMARY KEY AUTO_INCREMENT,
  PrescriptionID INT NOT NULL,
  MedicineID INT NOT NULL,
  Dose VARCHAR(50),
  Route VARCHAR(50),
  Frequency VARCHAR(50),
  Duration VARCHAR(50),
  FOREIGN KEY (PrescriptionID) REFERENCES Prescriptions(PrescriptionID) ON DELETE CASCADE,
  FOREIGN KEY (MedicineID) REFERENCES Medicines(MedicineID)
) ENGINE=InnoDB;

CREATE TABLE FollowUpPlans (
  PlanID INT PRIMARY KEY AUTO_INCREMENT,
  AppointmentID INT NOT NULL UNIQUE,
  DueDate DATE NOT NULL,
  Priority ENUM('High', 'Urgent', 'Routine') NOT NULL,
  Status VARCHAR(50) DEFAULT 'Pending',
  FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Synthetic sample data (10 records per main table)
INSERT INTO Specialties (SpecialtyName) VALUES
('Glaucoma'), ('Retina'), ('Cornea'), ('Oculoplastics'), ('Paediatrics'),
('Neuro-Ophthalmology'), ('Uveitis'), ('Strabismus'), ('Refractive Surgery'), ('General Ophthalmology');

INSERT INTO Clinics (ClinicName, Location) VALUES
('City Road', 'London'), ('Bedford', 'Bedfordshire'), ('Croydon', 'London'), ('Islington', 'London'),
('Camden', 'London'), ('Hackney', 'London'), ('Westminster', 'London'), ('Greenwich', 'London'),
('Lewisham', 'London'), ('Southwark', 'London');

INSERT INTO Clinicians (ClinicianName, SpecialtyID) VALUES
('Dr Maya Shah', 1), ('Dr Leo Grant', 2), ('Dr Priya Nair', 3), ('Dr James Wilson', 4),
('Dr Sarah Jenkins', 5), ('Dr Ahmed Ali', 6), ('Dr Emily Clarke', 7), ('Dr Tom Harris', 8),
('Dr Nina Patel', 9), ('Dr Oliver Smith', 10);

INSERT INTO Patients (FirstName, LastName, Postcode) VALUES
('Amina', 'Yusuf', 'NE1 4AB'), ('Daniel', 'Reed', 'N16 7QP'), ('Sofia', 'Bennett', 'E8 2LD'),
('Michael', 'Okoro', 'SE6 3RT'), ('Sarah', 'Connor', 'N1 9GU'), ('David', 'Attenborough', 'SW1A 1AA'),
('Emma', 'Watson', 'NW1 6XE'), ('John', 'Smith', 'E1 6AN'), ('Lucy', 'Pevensie', 'N7 9DP'),
('Peter', 'Parker', 'SE1 2TH');

INSERT INTO Medicines (MedicineName) VALUES
('Latanoprost'), ('Timolol'), ('Aflibercept'), ('Sodium chloride drops'), ('Prednisolone'),
('Atropine'), ('Cyclopentolate'), ('Dorzolamide'), ('Brimonidine'), ('Ranibizumab');

INSERT INTO Appointments (PatientID, ClinicianID, ClinicID, AppointmentDate, AppointmentTime) VALUES
(1, 1, 1, '2026-10-05', '09:00:00'),
(2, 2, 1, '2026-10-05', '09:30:00'),
(3, 1, 2, '2026-10-06', '11:00:00'),
(4, 3, 3, '2026-10-07', '14:00:00'),
(5, 4, 4, '2026-10-08', '10:15:00'),
(6, 5, 5, '2026-10-09', '08:45:00'),
(7, 6, 6, '2026-10-10', '13:30:00'),
(8, 7, 7, '2026-10-11', '15:00:00'),
(9, 8, 8, '2026-10-12', '09:15:00'),
(10, 9, 9, '2026-10-13', '16:45:00');

INSERT INTO Diagnoses (AppointmentID, DiagnosisDetails) VALUES
(1, 'Ocular hypertension'), (2, 'Diabetic macular oedema'), (3, 'Glaucoma suspect'),
(4, 'Keratoconus'), (5, 'Cataract - right eye'), (6, 'Blepharitis'),
(7, 'Dry eye syndrome'), (8, 'Strabismus'), (9, 'Uveitis'), (10, 'Retinal detachment');

INSERT INTO Prescriptions (AppointmentID) VALUES
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

INSERT INTO PrescriptionItems (PrescriptionID, MedicineID, Dose, Route, Frequency, Duration) VALUES
(1, 1, '1 drop', 'Topical', 'Once daily', '30 days'),
(2, 3, '2mg', 'Intravitreal', 'Once', 'Single dose'),
(3, 2, '1 drop', 'Topical', 'Twice daily', '14 days'),
(4, 4, '1 drop', 'Topical', 'Four times daily', '7 days'),
(5, 5, '1 drop', 'Topical', 'Once daily', '21 days'),
(6, 6, '1 drop', 'Topical', 'Once daily', '5 days'),
(7, 7, '1 drop', 'Topical', 'Twice daily', '3 days'),
(8, 8, '1 drop', 'Topical', 'Twice daily', '28 days'),
(9, 9, '1 drop', 'Topical', 'Three times daily', '10 days'),
(10, 10, '0.5mg', 'Intravitreal', 'Once', 'Single dose');

INSERT INTO FollowUpPlans (AppointmentID, DueDate, Priority, Status) VALUES
(1, '2026-11-16', 'Routine', 'Pending'),
(2, '2026-11-02', 'Urgent', 'Pending'),
(3, '2027-04-05', 'Routine', 'Pending'),
(4, '2026-12-07', 'Routine', 'Pending'),
(5, '2026-11-08', 'High', 'Completed'),
(6, '2026-10-23', 'Routine', 'Pending'),
(7, '2026-10-24', 'High', 'Pending'),
(8, '2026-11-11', 'Routine', 'Pending'),
(9, '2026-11-12', 'Urgent', 'Pending'),
(10, '2026-10-20', 'Urgent', 'Pending');

-- Controlled Part B examples
UPDATE Patients SET Postcode = 'NE1 5XX' WHERE PatientID = 1;
DELETE FROM Diagnoses WHERE DiagnosisID = 1;
