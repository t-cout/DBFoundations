--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: YourNameHere
-- Desc: This file demonstrates how to design and create; 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_TylerCoutermarsh')
	 Begin 
	  Alter Database [ITFnd130FinalDB_TylerCoutermarsh] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_TylerCoutermarsh;
	 End
	Create Database ITFnd130FinalDB_TylerCoutermarsh;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use ITFnd130FinalDB_TylerCoutermarsh;

-- Create Tables (Review Module 01)-- 
CREATE TABLE Courses
	(CourseID INT NOT NULL IDENTITY PRIMARY KEY,
	CourseName VARCHAR(100) NOT NULL CONSTRAINT uqCourseName UNIQUE,
	CourseStartDate DATE CHECK (CourseStartDate BETWEEN '2010-01-01' AND '2025-01-01'),
	CourseEndDate DATE CHECK (CourseEndDate BETWEEN '2010-01-01' AND '2025-01-01'),
	CourseStartTime TIME,
	CourseEndTime TIME,
	CourseDaysofWeek VARCHAR(100),
	CourseCurrentPrice MONEY);
	GO

CREATE TABLE Students 
    (StudentID INT NOT NULL IDENTITY PRIMARY KEY,
    CourseID INT NOT NULL FOREIGN KEY REFERENCES Courses(CourseID),
    StudentName VARCHAR(100) NOT NULL CONSTRAINT uqStudentName UNIQUE,
    StudentNumber VARCHAR(100) CONSTRAINT uqStudentNumber UNIQUE,
    StudentEmail VARCHAR(100),
    StudentPhoneNumber VARCHAR(100),
    StudentAddress VARCHAR(100),
    StudentSignUpDate DATE CHECK (StudentSignUpDate BETWEEN '2010-01-01' AND '2025-01-01'),
    StudentPaidAmount MONEY);
GO
	
-- Add Constraints (Review Module 02) -- 


-- Add Views (Review Module 03 and 06) -- 
CREATE VIEW vCourses
WITH SCHEMABINDING
AS
	SELECT
	CourseName,
	CourseStartDate,
	CourseEndDate,
	CourseStartTime,
	CourseEndTime,
	CourseDaysofWeek,
	CourseCurrentPrice
	FROM dbo.Courses;
GO

--SELECT * FROM vCourses;
--GO

CREATE VIEW vStudents
WITH SCHEMABINDING
AS
	SELECT
	StudentID,
	CourseID,
	StudentName,
	StudentNumber,
	StudentEmail,
	StudentPhoneNumber,
	StudentAddress,
	StudentSignUpDate,
	StudentPaidAmount
	FROM dbo.Students;
GO

--SELECT * FROM vStudents;
--GO

CREATE VIEW vStudentsPublic
WITH SCHEMABINDING
AS
	SELECT
	StudentID,
	CourseID,
	StudentName,
	StudentNumber,
	StudentEmail,
	StudentSignUpDate,
	StudentPaidAmount
	FROM dbo.Students;
GO

--SELECT * FROM vStudentsPublic;
--GO

CREATE VIEW vStudentsbyCourses
AS
	SELECT TOP 10000
	s.StudentName,
	s.StudentNumber,
	c.CourseName,
	c.CourseCurrentPrice,
	s.StudentPaidAmount
	FROM Students AS s
	INNER JOIN Courses AS c ON s.CourseID = c.CourseID
	ORDER BY s.StudentPaidAmount ASC;
GO

--SELECT * FROM vStudentsbyCourses;
--GO

--< Test Tables by adding Sample Data >--  
INSERT INTO Courses
	(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysofWeek, CourseCurrentPrice)
VALUES
	('SQL1 - Winter 2017', '20170110', '20170124', '06:00:00', '08:50:00', 'T', 399),
	('SQL2 - Winter 2017', '20170131', '20170214', '06:00:00', '08:50:00', 'T', 399);
GO
	
--SELECT * FROM dbo.Courses

INSERT INTO Students
    (CourseID, StudentName, StudentNumber, StudentEmail, StudentPhoneNumber, StudentAddress, StudentSignUpDate, StudentPaidAmount)
VALUES
    (2, 'Bob Smith', 'B-Smith-071', 'Bsmith@HipMail.com', '206-111-2222', '123 Main St. Seattle, WA, 98001', '2017-01-03', 399),
    (1, 'Sue Jones', 'S-Jones-003', 'SueJones@YaYou.com', '206-231-4321', '333 1st Ave. Seattle, WA, 98001', '2016-12-14', 349);
GO

--SELECT * FROM dbo.Students

-- Add Stored Procedures (Review Module 04 and 08) --

CREATE PROC pInsCourses
(@CourseName VARCHAR(100),@CourseStartDate DATE,@CourseEndDate DATE, @CourseStartTime TIME, @CourseEndTime TIME, @CourseDaysofWeek VARCHAR(100), @CourseCurrentPrice int)
AS
BEGIN
 BEGIN TRAN;
 INSERT INTO Courses(CourseName, CourseStartDate, CourseEndDate, CourseStartTime, CourseEndTime, CourseDaysofWeek, CourseCurrentPrice)
 VALUES (@CourseName, @CourseStartDate, @CourseEndDate, @CourseStartTime, @CourseEndTime, @CourseDaysofWeek, @CourseCurrentPrice);
 COMMIT TRAN;
END
GO
-- Test that the Sproc works:
EXEC pInsCourses
 @CourseName = 'SQL3 - Spring 2018'
 ,@CourseStartDate = '20180414'
 ,@CourseEndDate = '20180501'
 ,@CourseStartTime = '02:00:00'
 ,@CourseEndTime = '3:00:00'
 ,@CourseDaysofWeek = 'W'
 ,@CourseCurrentPrice = 100;
GO
--SELECT * FROM Courses;
--GO

CREATE PROC pInsStudents
(@CourseID VARCHAR(100), @StudentName VARCHAR(100), @StudentNumber VARCHAR(100), @StudentEmail VARCHAR(100), @StudentPhoneNumber VARCHAR(100), @StudentAddress VARCHAR(100), @StudentSignUpDate DATE, @StudentPaidAmount INT)
AS
BEGIN
 BEGIN TRAN;
 INSERT INTO Students(CourseID, StudentName, StudentNumber, StudentEmail, StudentPhoneNumber, StudentAddress, StudentSignUpDate, StudentPaidAmount)
 VALUES (@CourseID, @StudentName, @StudentNumber, @StudentEmail, @StudentPhoneNumber, @StudentAddress, @StudentSignUpDate, @StudentPaidAmount);
 COMMIT TRAN;
END
GO
-- Test that the Sproc works:
EXEC pInsStudents
 @CourseID = 3
 ,@StudentName = 'Tony Gillis'
 ,@StudentNumber = 'T-Gillis-029'
 ,@StudentEmail = 'TGillis@Hip.com'
 ,@StudentPhoneNumber = '206-920-1930'
 ,@StudentAddress = '193 Main Ave. Bellevue, WA, 98201'
 ,@StudentSignUpDate = '20171123'
 ,@StudentPaidAmount = 50;
GO
--SELECT * FROM Students;
--GO

CREATE PROC pPmtStatus
AS
BEGIN
	SELECT
	s.studentname,
		CASE
			WHEN s.StudentPaidAmount < c.CourseCurrentPrice THEN 'Outstanding Balance'
			ELSE 'Fully Paid'
		END AS 'Payment Status'
	FROM Students AS s
	INNER JOIN Courses AS c ON s.CourseID = c.CourseID
	ORDER BY s.StudentName
END;
GO

--EXEC pPmtStatus;
--GO

-- Set Permissions --
DENY SELECT ON dbo.students TO PUBLIC;
DENY SELECT ON dbo.courses TO PUBLIC;
DENY SELECT ON vStudents TO PUBLIC;

GRANT SELECT ON vCourses TO PUBLIC;
GRANT SELECT ON vStudents TO PUBLIC;
GRANT SELECT ON vStudentsbyCourses TO PUBLIC;
--< Test Sprocs >-- 
--{ IMPORTANT!!! }--
-- To get full credit, your script must run without having to highlight individual statements!!!  
/**************************************************************************************************/