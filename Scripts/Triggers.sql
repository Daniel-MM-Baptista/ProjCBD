/**************************************************
*	UC: Complemento de Base de Dados	2021/2022
*
*	Projeto
*	Grupo 3
*
*	(Nome)						(N� Aluno)
*	Daniel Baptista				202001990
*	Rafael Silva				202001553
*	
*	Turma: 2�L_EI-SW-04			Sala: F356
*
***************************************************/

USE Proj_DB_RS;

DROP TRIGGER schSchool.trg_backup_grades;
GO
CREATE TRIGGER schSchool.trg_backup_grades
ON schSchool.Grade
AFTER INSERT
AS
BEGIN
	INSERT INTO schLogs.ClosedGrade (classFailures, subjectAbsences, period1Grade, period2Grade, 
								     period3Grade, subjectID, studentNumber, logDate)
	SELECT classFailures, subjectAbsences, period1Grade,
		   period2Grade, period3Grade, subjectID, studentNumber, GETDATE() FROM inserted
END
GO

DROP TRIGGER schSchool.trg_backup_inscritos;
GO
CREATE TRIGGER schSchool.trg_backup_inscritos
ON schSchool.Inscrito
AFTER INSERT
AS
BEGIN
	INSERT INTO schLogs.ClosedInscritos(weekStudyTime, paidClasses, studentNumber, subjectID, logDate)
	SELECT weekStudyTime, paidClasses, studentNumber, subjectID, GETDATE() FROM inserted
END
GO

DROP TRIGGER schSchool.trg_change_activeYear;
GO
CREATE TRIGGER schSchool.trg_change_activeYear
ON schSchool.SchoolYear
AFTER INSERT
AS
BEGIN
	UPDATE schSchool.SchoolYear SET activeYear = 0 WHERE activeYear = 1;
	UPDATE schSchool.SchoolYear SET activeYear = 1 WHERE schoolYear = (SELECT schoolYear FROM inserted)
END
GO

DROP TRIGGER schStudent.trg_email_user_password_change;
GO
CREATE TRIGGER schStudent.trg_email_user_password_change
ON schStudent.UserAutentication
AFTER UPDATE
AS
BEGIN
	DECLARE @newPW VARCHAR(128) = (SELECT hashPassword FROM inserted)
	DECLARE @oldPW VARCHAR(128) = (SELECT hashPassword FROM deleted)

	IF(@newPW != @oldPW) --apenas vai enviar o email no caso de mudan�a de password
	BEGIN
		DECLARE @email VARCHAR(40) = (SELECT userEmail FROM inserted)

		INSERT INTO schStudent.EmailPW (userEmail, emailContents)
		VALUES (@email, 'A sua palavra passe foi alterada.')
	END
END
GO


/* tentativa de criar evento de dura�ao de 1 hora para o token
GO
CREATE TRIGGER schStudent.trg_token_update
ON schStudent.UserAutentication
AFTER UPDATE
AS
BEGIN
	IF((SELECT tokenPassword FROM inserted) IS NOT NULL)
	BEGIN
		DECLARE @email VARCHAR(40) = (SELECT userEmail FROM schStudent.UserAutentication)

		CREATE EVENT SESSION event_token
		ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR
		DO
		UPDATE schStudent.UserAutentication SET tokenPassword = NULL WHERE userEmail = @email
	END
END
GO
*/