-- 02_individual_queries.sql
USE CrownfieldEyeHospital;

-- C1 Aggregate with GROUP BY and HAVING
SELECT c.ClinicianID, c.ClinicianName, COUNT(a.AppointmentID) AS AppointmentCount
FROM Clinicians c
INNER JOIN Appointments a ON a.ClinicianID = c.ClinicianID
GROUP BY c.ClinicianID, c.ClinicianName
HAVING COUNT(a.AppointmentID) >= 1
ORDER BY AppointmentCount DESC, c.ClinicianName;

-- C2 INNER JOIN across four related tables
SELECT a.AppointmentID, p.FirstName, p.LastName, a.AppointmentDate,
       a.AppointmentTime, c.ClinicianName, cl.ClinicName
FROM Appointments a
INNER JOIN Patients p ON p.PatientID = a.PatientID
INNER JOIN Clinicians c ON c.ClinicianID = a.ClinicianID
INNER JOIN Clinics cl ON cl.ClinicID = a.ClinicID
ORDER BY a.AppointmentDate, a.AppointmentTime;

-- C3 LEFT JOIN: clinicians without appointments
SELECT c.ClinicianID, c.ClinicianName, a.AppointmentID, a.AppointmentDate
FROM Clinicians c
LEFT JOIN Appointments a ON a.ClinicianID = c.ClinicianID
WHERE a.AppointmentID IS NULL
ORDER BY c.ClinicianName;

-- C4 Subquery: appointments on the latest recorded date
SELECT AppointmentID, PatientID, ClinicianID, ClinicID, AppointmentDate, AppointmentTime
FROM Appointments
WHERE AppointmentDate = (SELECT MAX(AppointmentDate) FROM Appointments)
ORDER BY AppointmentTime;

-- C5 Stored procedure is in 03_procedure_and_trigger.sql
-- Execute after creating it:
-- CALL GetPatientAppointmentHistory(1);

-- C6 Trigger is in 03_procedure_and_trigger.sql
