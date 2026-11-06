-- 03_procedure_and_trigger.sql
USE CrownfieldEyeHospital;

DROP PROCEDURE IF EXISTS GetPatientAppointmentHistory;
DELIMITER //
CREATE PROCEDURE GetPatientAppointmentHistory(IN p_PatientID INT)
BEGIN
    SELECT p.PatientID, p.FirstName, p.LastName,
           a.AppointmentID, a.AppointmentDate, a.AppointmentTime,
           c.ClinicianName, d.DiagnosisDetails
    FROM Patients p
    INNER JOIN Appointments a ON a.PatientID = p.PatientID
    INNER JOIN Clinicians c ON c.ClinicianID = a.ClinicianID
    LEFT JOIN Diagnoses d ON d.AppointmentID = a.AppointmentID
    WHERE p.PatientID = p_PatientID
    ORDER BY a.AppointmentDate DESC, a.AppointmentTime DESC;
END//
DELIMITER ;

CALL GetPatientAppointmentHistory(1);

DROP TRIGGER IF EXISTS trg_validate_followup_due_date;
DELIMITER //
CREATE TRIGGER trg_validate_followup_due_date
BEFORE INSERT ON FollowUpPlans
FOR EACH ROW
BEGIN
    DECLARE v_AppointmentDate DATE;
    SELECT AppointmentDate INTO v_AppointmentDate
    FROM Appointments
    WHERE AppointmentID = NEW.AppointmentID;

    IF NEW.DueDate < v_AppointmentDate THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Follow-up due date cannot be before the appointment date';
    END IF;
END//
DELIMITER ;

-- Trigger test (use a free AppointmentID and then clean up if accepted):
-- This should be rejected because the date is before AppointmentID 1's appointment date.
-- INSERT INTO FollowUpPlans (AppointmentID, DueDate, Priority, Status)
-- VALUES (11, '2020-01-01', 'Routine', 'Pending');
