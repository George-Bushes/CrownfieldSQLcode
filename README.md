# Crownfield Eye Hospital database repository

## Requirements
- MySQL 8.0 (the SQL uses roles, stored procedures, triggers, `SIGNAL`, and AES_ENCRYPT/AES_DECRYPT).
- Run the scripts using an account permitted to create databases, tables, roles, users, procedures and triggers.

## Execution order
1. `01_schema.sql` — creates the shared schema and synthetic sample data.
2. `02_individual_queries.sql` — run the four SELECT query demonstrations.
3. `03_procedure_and_trigger.sql` — creates and calls the stored procedure, then creates the trigger.
4. `04_security_and_transactions.sql` — creates roles, the patient portal view and encryption demonstration, then runs a transaction rollback test.

## Important notes
- `01_schema.sql` drops and recreates `CrownfieldEyeHospital`. Do not run it against a database containing real data.
- The Part B data contains synthetic records only. Patient names and postcodes are fictional teaching data.
- The original Part B controlled DELETE removes `DiagnosisID = 1`; consequently the diagnosis for AppointmentID 1 is absent after the script runs.
- The four query result descriptions in the report are expected results based on the supplied sample data. Run each query and capture your own MySQL Workbench screenshots; screenshots have not been fabricated.
- The trigger checks inserts. If follow-up dates can be edited, create a matching `BEFORE UPDATE` trigger as an additional safeguard.
- Create individual MySQL accounts with strong unique passwords before uncommenting the example account/role assignment statements. Add the exact patient database username and PatientID to `DatabaseUserPatientMap`. The patient view is intended to show only the mapped patient.
- The encryption key in the script is a classroom demonstration only. Do not use it for real information or commit real keys to GitHub. Production key management must be external and protected.
- The SQL security statements should be reviewed against the privileges available to the MySQL account and the local server configuration.

## Suggested evidence
Capture labelled screenshots for C1–C6, role grants (`SHOW GRANTS`), the encrypted value and authorised decryption test, the trigger rejection test, and the transaction before/after rollback.
