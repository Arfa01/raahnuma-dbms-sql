-- Create Database
CREATE DATABASE Raahnuma;
GO

USE Raahnuma;
GO

------Tables--------------------------------------------------------------
-- University Table
CREATE TABLE University (
    UniversityID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(50),
    City VARCHAR(100),
    Website VARCHAR(255)
);

-- Program Table
CREATE TABLE Program (
    ProgramID INT IDENTITY(1,1) PRIMARY KEY,
    UniversityID INT,
    Name VARCHAR(100),
    DegreeType VARCHAR(50),
    Duration INT,
    FOREIGN KEY (UniversityID) REFERENCES University(UniversityID)
);

-- Eligibility Table
CREATE TABLE Eligibility (
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    MinPercentage FLOAT,
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- RequiredSubject Table
CREATE TABLE RequiredSubject (
    CriteriaID INT,
    SubjectName VARCHAR(100),
    FOREIGN KEY (CriteriaID) REFERENCES Eligibility(CriteriaID)
);

-- FeeStructure Table
CREATE TABLE FeeStructure (
    FeeID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    TuitionFee FLOAT,
    AdmissionFee FLOAT,
    HostelFee FLOAT,
    Notes TEXT,
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- AdmissionDates Table
CREATE TABLE AdmissionDates (
    ProgramID INT PRIMARY KEY,
    SubmissionStart DATE,
    SubmissionEnd DATE,
    EntryTest DATE,
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- Subject Table
CREATE TABLE Subject (
    SubjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    Name VARCHAR(100),
    Semester INT,
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- Timeline Table
CREATE TABLE Timeline (
    TimelineID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    StepTitle VARCHAR(100),
    Description TEXT,
    DueDate DATE,
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- Role Table
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50),
    Description TEXT
);

-- User Table
CREATE TABLE [User] (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Password VARCHAR(100),
    RoleID INT,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);


-- Filter Table
CREATE TABLE Filter (
    FilterID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    FilterType VARCHAR(50),
    FilterValue VARCHAR(100),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);

-- SavedPrograms Table
CREATE TABLE SavedPrograms (
    UserID INT,
    ProgramID INT,
    SavedOn DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (UserID, ProgramID),
    FOREIGN KEY (UserID) REFERENCES [User](UserID),
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-- Notification Table
CREATE TABLE Notification (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Content TEXT,
    SentOn DATETIME DEFAULT GETDATE(),
    ReadStatus BIT DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);



-- ChatGroup Table
CREATE TABLE ChatGroup (
    ChatID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    UniversityID INT,
    GroupName VARCHAR(100),
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID),
    FOREIGN KEY (UniversityID) REFERENCES University(UniversityID)
);

-- ChatMessage Table
CREATE TABLE ChatMessage (
    MessageID INT IDENTITY(1,1) PRIMARY KEY,
    ChatID INT,
    UserID INT,
    MessageText TEXT,
    Timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ChatID) REFERENCES ChatGroup(ChatID),
    FOREIGN KEY (UserID) REFERENCES [User](UserID)
);


-- ProgramTags Table
CREATE TABLE ProgramTags (
    ProgramID INT,
    Tag VARCHAR(50),
    FOREIGN KEY (ProgramID) REFERENCES Program(ProgramID)
);

-----enhancements------------------------------------------
-- Ensure duration is within reasonable limits
ALTER TABLE Program
ADD CONSTRAINT CHK_Program_Duration CHECK (Duration BETWEEN 1 AND 6);

-- Ensure percentages are within 0–100
ALTER TABLE Eligibility
ADD CONSTRAINT CHK_Eligibility_Percentage CHECK (MinPercentage BETWEEN 0 AND 100);

-- Ensure fee values are non-negative
ALTER TABLE FeeStructure
ADD CONSTRAINT CHK_Fees_NonNegative CHECK (
    TuitionFee >= 0 AND AdmissionFee >= 0 AND HostelFee >= 0
);

--for future use in UI logic
CREATE TABLE RolePermission (
    RoleID INT,
    FeatureName VARCHAR(100),
    CanRead BIT,
    CanWrite BIT,
    CanDelete BIT,
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    PRIMARY KEY (RoleID, FeatureName)
);

--------------------------------------------------------------
----insert into tables-----------------------------------------------------
-- Insert roles
INSERT INTO Role (RoleName, Description) VALUES ('Student', 'General student user');

-- Insert users
INSERT INTO [User] (Name, Email, Password, RoleID) VALUES ('Arfa', 'arfa@example.com', 'pass123', 1);

-- Insert university
INSERT INTO University (Name, Type, City, Website) VALUES ('COMSATS', 'Public', 'Lahore', 'https://comsats.edu.pk');

-- Insert program
INSERT INTO Program (UniversityID, Name, DegreeType, Duration) VALUES (1, 'Computer Science', 'BS', 4);

-- Insert eligibility
INSERT INTO Eligibility (ProgramID, MinPercentage) VALUES (1, 80);

-- Insert tags
INSERT INTO ProgramTags (ProgramID, Tag) VALUES (1, 'engineering');

-- Insert chat group
INSERT INTO ChatGroup (ProgramID, UniversityID, GroupName) VALUES (1, 1, 'CS Students');

-- Insert timeline
INSERT INTO Timeline (ProgramID, StepTitle, Description, DueDate)
VALUES (1, 'Apply Online', 'Fill the online application form', '2025-07-01');

-- Insert fee structure
INSERT INTO FeeStructure (ProgramID, TuitionFee, AdmissionFee, HostelFee, Notes)
VALUES (1, 120000, 10000, 30000, 'Initial fee structure');

-- Insert a notification
INSERT INTO Notification (UserID, Content) VALUES (1, 'New program added');

--more data
INSERT INTO University (Name, Type, City, Website) 
VALUES ('Test University', 'Private', 'Test City', 'https://test.edu.pk');

INSERT INTO Program (UniversityID, Name, DegreeType, Duration) 
VALUES (IDENT_CURRENT('University'), 'Test Program', 'BS', 4);

INSERT INTO Eligibility (ProgramID, MinPercentage) 
VALUES (IDENT_CURRENT('Program'), 75.0);

INSERT INTO ProgramTags (ProgramID, Tag) 
VALUES (IDENT_CURRENT('Program'), 'engineering');

INSERT INTO [User] (Name, Email, Password, RoleID) 
VALUES ('Test User', 'test@example.com', 'password', 1);

INSERT INTO Notification (UserID, Content) 
VALUES (IDENT_CURRENT('User'), 'Test notification');


----view tables---------------------------------
SELECT * FROM SavedPrograms;
SELECT * FROM ChatMessage;
SELECT * FROM Notification;
SELECT * FROM FeeStructure;
SELECT * FROM Program;
Select * from Role
select * from [User]




---Indexes------------------------------------------------------------------------------------------------------------

-- clustered indexes are automatically created with PRIMERY KEY declaratiions 


-- Non-clustered index on frequently searched fields
CREATE NONCLUSTERED INDEX IX_Program_Name ON Program(Name);
CREATE NONCLUSTERED INDEX IX_University_City ON University(City);
CREATE NONCLUSTERED INDEX IX_User_Email ON [User](Email);
CREATE NONCLUSTERED INDEX IX_ChatMessage_UserID ON ChatMessage(UserID);
CREATE NONCLUSTERED INDEX IX_SavedPrograms_ProgramID ON SavedPrograms(ProgramID);
CREATE NONCLUSTERED INDEX IX_Timeline_DueDate ON Timeline(DueDate);


--Test indexes---
SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('Program');

SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('University');

SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('[User]');

SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('ChatMessage');

SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('SavedPrograms');

SELECT * 
FROM sys.indexes 
WHERE object_id = OBJECT_ID('Timeline');

------------------------------------------------------------



----------------TRiggers-----------------------------------------------------------------------------------

--Trigger 1: Update user’s last active timestamp on chat message
ALTER TABLE [User]
ADD LastActive DATETIME;

GO

CREATE TRIGGER trg_UpdateLastActive
ON ChatMessage
AFTER INSERT
AS
BEGIN
    UPDATE [User]
    SET LastActive = GETDATE()
    WHERE UserID IN (SELECT UserID FROM inserted);
END;

--Fee_History table
CREATE TABLE Fee_History (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    FeeID INT,
    ProgramID INT,
    TuitionFee FLOAT,
    AdmissionFee FLOAT,
    HostelFee FLOAT,
    Notes TEXT,
    ChangedOn DATETIME DEFAULT GETDATE(),
    ChangedBy VARCHAR(100)
);

GO

-- Trigger 2: Log changes to fee structure
CREATE TRIGGER trg_LogFeeStructureUpdate
ON FeeStructure
AFTER UPDATE
AS
BEGIN
    INSERT INTO Fee_History (FeeID, ProgramID, TuitionFee, AdmissionFee, HostelFee, ChangedBy)
    SELECT FeeID, ProgramID, TuitionFee, AdmissionFee, HostelFee, SYSTEM_USER
    FROM deleted;
END;

--Program history table
CREATE TABLE Program_History (
    ArchiveID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramID INT,
    UniversityID INT,
    Name VARCHAR(100),
    DegreeType VARCHAR(50),
    Duration INT,
    DeletedOn DATETIME DEFAULT GETDATE(),
    DeletedBy VARCHAR(100)
);

GO



-- Trigger 3 : Archive programs after deletion
CREATE TRIGGER trg_ArchiveProgramOnDelete
ON Program
INSTEAD OF DELETE
AS
BEGIN
    -- Archive deleted program
    INSERT INTO Program_History (ProgramID, UniversityID, Name, DegreeType, Duration, DeletedBy)
    SELECT ProgramID, UniversityID, Name, DegreeType, Duration, SYSTEM_USER
    FROM deleted;

    -- Delete dependent records first
    DELETE FROM RequiredSubject WHERE CriteriaID IN (
        SELECT CriteriaID FROM Eligibility WHERE ProgramID IN (SELECT ProgramID FROM deleted)
    );

    DELETE FROM Eligibility WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM FeeStructure WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM AdmissionDates WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM Subject WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM Timeline WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM SavedPrograms WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM ChatGroup WHERE ProgramID IN (SELECT ProgramID FROM deleted);
    DELETE FROM ProgramTags WHERE ProgramID IN (SELECT ProgramID FROM deleted);

    -- Finally delete from Program
    DELETE FROM Program WHERE ProgramID IN (SELECT ProgramID FROM deleted);
END;
GO




--Trigger 4: Notify user on saving program
CREATE TABLE SavedProgramNotification (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    Message VARCHAR(255),
    CreatedOn DATETIME DEFAULT GETDATE()
);

GO

CREATE TRIGGER trg_NotifyOnSave
ON SavedPrograms
AFTER INSERT
AS
BEGIN
    INSERT INTO SavedProgramNotification (UserID, Message)
    SELECT UserID, 'Program successfully saved to favorites.'
    FROM inserted;
END;


--Testing triggers:----------------------------------------------------------------

-- Test the trigger trg_UpdateLastActive (on ChatMessage insert)
INSERT INTO ChatMessage (ChatID, UserID, MessageText) 
VALUES (1, 1, 'Testing last active update');

-- Verify the result
SELECT UserID, Name, LastActive FROM [User] WHERE UserID = 1;



-- Test the trigger trg_LogFeeStructureUpdate (on FeeStructure update)
UPDATE FeeStructure 
SET TuitionFee = 110000, Notes = 'Updated test fee' 
WHERE ProgramID = 1;

-- Verify the result
SELECT * FROM Fee_History WHERE ProgramID = 1;


-- Test the trigger trg_ArchiveProgramOnDelete (on Program delete)
DELETE FROM Program WHERE ProgramID = 2;

-- Verify the result
SELECT * FROM Program_History WHERE ProgramID = 2;
SELECT * FROM Program WHERE ProgramID = 2; -- Should be gone
SELECT * FROM FeeStructure WHERE ProgramID = 2; -- Should be gone
SELECT * FROM Eligibility WHERE ProgramID = 2; -- Should be gone


-- Test the trigger trg_NotifyOnSave (on SavedPrograms insert)
-- First, add another program to save
INSERT INTO Program (UniversityID, Name, DegreeType, Duration) 
VALUES (1, 'Another Program', 'MS', 2);

INSERT INTO SavedPrograms (UserID, ProgramID) VALUES (1, 3);

-- Verify the result
SELECT * FROM SavedProgramNotification WHERE UserID = 1;


-- test fee (annie ne kia tha ye wala idk)
UPDATE FeeStructure
SET TuitionFee = 150000, Notes = 'Updated fee structure for 2025'
WHERE ProgramID = 1;

SELECT HistoryID, FeeID, ProgramID, TuitionFee, AdmissionFee, HostelFee, Notes, ChangedBy, ChangedOn
FROM Fee_History
ORDER BY ChangedOn DESC;

DELETE FROM Program
WHERE ProgramID = 1;

-----------------------------------------------------------------------------------------

---------------------------------- Stored Procedures-------------------------------------------
 
 
 --Procedure 1: Get all programs by city
 CREATE PROCEDURE GetAllProgramsByCity
    @City VARCHAR(100)
AS
BEGIN
    SELECT p.ProgramID, p.Name AS ProgramName, u.Name AS UniversityName
    FROM Program p
    JOIN University u ON p.UniversityID = u.UniversityID
    WHERE u.City = @City;
END;


--Procedure 2: Get eligible programs for a user
CREATE PROCEDURE GetEligibleProgramsForUser
    @MinPercentage FLOAT
AS
BEGIN
    SELECT p.ProgramID, p.Name, e.MinPercentage
    FROM Program p
    JOIN Eligibility e ON p.ProgramID = e.ProgramID
    WHERE e.MinPercentage <= @MinPercentage;
END;


--Procedure 3: Save a program

CREATE PROCEDURE SaveProgram
    @UserID INT,
    @ProgramID INT
AS
BEGIN
    INSERT INTO SavedPrograms (UserID, ProgramID)
    VALUES (@UserID, @ProgramID);
END;


CREATE PROCEDURE UnsaveProgram
    @UserID INT,
    @ProgramID INT
AS
BEGIN
    DELETE FROM SavedPrograms
    WHERE UserID = @UserID AND ProgramID = @ProgramID;
END;


CREATE PROCEDURE InsertChatMessage
    @ChatID INT,
    @UserID INT,
    @MessageText TEXT
AS
BEGIN
    INSERT INTO ChatMessage (ChatID, UserID, MessageText)
    VALUES (@ChatID, @UserID, @MessageText);
END;


CREATE PROCEDURE GetTimelineForProgram
    @ProgramID INT
AS
BEGIN
    SELECT StepTitle, Description, DueDate
    FROM Timeline
    WHERE ProgramID = @ProgramID
    ORDER BY DueDate;
END;


CREATE PROCEDURE UpdateFeeStructure
    @ProgramID INT,
    @TuitionFee FLOAT,
    @AdmissionFee FLOAT,
    @HostelFee FLOAT,
    @Notes TEXT
AS
BEGIN
    UPDATE FeeStructure
    SET TuitionFee = @TuitionFee,
        AdmissionFee = @AdmissionFee,
        HostelFee = @HostelFee,
        Notes = @Notes
    WHERE ProgramID = @ProgramID;
END;


CREATE PROCEDURE GetNotifications
    @UserID INT
AS
BEGIN
    SELECT NotificationID, Content, SentOn, ReadStatus
    FROM Notification
    WHERE UserID = @UserID;
END;



CREATE PROCEDURE SearchProgramsByTags
    @Tag VARCHAR(50)
AS
BEGIN
    SELECT p.ProgramID, p.Name
    FROM Program p
    JOIN ProgramTags pt ON p.ProgramID = pt.ProgramID
    WHERE pt.Tag LIKE '%' + @Tag + '%';
END;


CREATE PROCEDURE MarkNotificationRead
    @NotificationID INT
AS
BEGIN
    UPDATE Notification
    SET ReadStatus = 1
    WHERE NotificationID = @NotificationID;
END;




-----test stored procedures:----------------------------

--SP 1
-- Test with valid city
EXEC GetAllProgramsByCity @City = 'Lahore';
EXEC GetAllProgramsByCity @City = 'Test City';
-- Test with NULL parameter
EXEC GetAllProgramsByCity @City = NULL;
-- Test with non-existent city
EXEC GetAllProgramsByCity @City = 'NonExistentCity';
-- Test with empty string
EXEC GetAllProgramsByCity @City = '';


--sp 2
-- Test with valid percentage
EXEC GetEligibleProgramsForUser @MinPercentage = 80.0;
EXEC GetEligibleProgramsForUser @MinPercentage = 85;
-- Test with NULL parameter
EXEC GetEligibleProgramsForUser @MinPercentage = NULL;
-- Test with exact match percentage
EXEC GetEligibleProgramsForUser @MinPercentage = 75.0;
-- Test with very low percentage
EXEC GetEligibleProgramsForUser @MinPercentage = 0.0;


--sp 3
-- Test valid save
EXEC SaveProgram @UserID = 1, @ProgramID = 1;
EXEC SaveProgram @UserID = IDENT_CURRENT('User'), @ProgramID = IDENT_CURRENT('Program');
-- Test NULL parameters
EXEC SaveProgram @UserID = NULL, @ProgramID = NULL;
-- Test invalid user ID
EXEC SaveProgram @UserID = 9999, @ProgramID = IDENT_CURRENT('Program');
-- Test invalid program ID
EXEC SaveProgram @UserID = IDENT_CURRENT('User'), @ProgramID = 9999;
-- Test duplicate save (should fail or handle gracefully)
EXEC SaveProgram @UserID = IDENT_CURRENT('User'), @ProgramID = IDENT_CURRENT('Program');

--sp 4
EXEC UnsaveProgram @UserID = 1, @ProgramID = 1;
-- Test valid unsave
EXEC UnsaveProgram @UserID = IDENT_CURRENT('User'), @ProgramID = IDENT_CURRENT('Program');

-- Test NULL parameters
EXEC UnsaveProgram @UserID = NULL, @ProgramID = NULL;

-- Test unsaving non-existent record
EXEC UnsaveProgram @UserID = IDENT_CURRENT('User'), @ProgramID = IDENT_CURRENT('Program');


--sp 5
EXEC InsertChatMessage @ChatID = 1, @UserID = 1, @MessageText = 'Hello everyone!';
-- First create a chat group
INSERT INTO ChatGroup (ProgramID, UniversityID, GroupName)
VALUES (IDENT_CURRENT('Program'), IDENT_CURRENT('University'), 'Test Group');

-- Test valid message
EXEC InsertChatMessage 
    @ChatID = IDENT_CURRENT('ChatGroup'), 
    @UserID = IDENT_CURRENT('User'), 
    @MessageText = 'Hello everyone!';

-- Test NULL parameters
EXEC InsertChatMessage @ChatID = NULL, @UserID = NULL, @MessageText = NULL;

-- Test empty message
EXEC InsertChatMessage 
    @ChatID = IDENT_CURRENT('ChatGroup'), 
    @UserID = IDENT_CURRENT('User'), 
    @MessageText = '';

-- Test invalid chat ID
EXEC InsertChatMessage @ChatID = 9999, @UserID = IDENT_CURRENT('User'), @MessageText = 'Test';

--sp 6
EXEC GetTimelineForProgram @ProgramID = 2;
-- First add timeline data
INSERT INTO Timeline (ProgramID, StepTitle, Description, DueDate)
VALUES (IDENT_CURRENT('Program'), 'Test Step', 'Test Description', GETDATE());

-- Test valid program
EXEC GetTimelineForProgram @ProgramID = IDENT_CURRENT('Program');

-- Test NULL parameter
EXEC GetTimelineForProgram @ProgramID = NULL;

-- Test invalid program ID
EXEC GetTimelineForProgram @ProgramID = 9999;


--sp 7
EXEC UpdateFeeStructure @ProgramID = 2, @TuitionFee = 150000, @AdmissionFee = 20000, @HostelFee = 40000, @Notes = 'Updated for 2025';
-- First add fee structure
INSERT INTO FeeStructure (ProgramID, TuitionFee, AdmissionFee, HostelFee, Notes)
VALUES (IDENT_CURRENT('Program'), 100000, 5000, 20000, 'Initial fee');

-- Test valid update
EXEC UpdateFeeStructure 
    @ProgramID = IDENT_CURRENT('Program'),
    @TuitionFee = 120000,
    @AdmissionFee = 6000,
    @HostelFee = 25000,
    @Notes = 'Updated fee';

-- Test NULL parameters
EXEC UpdateFeeStructure 
    @ProgramID = NULL,
    @TuitionFee = NULL,
    @AdmissionFee = NULL,
    @HostelFee = NULL,
    @Notes = NULL;

-- Test partial update
EXEC UpdateFeeStructure 
    @ProgramID = IDENT_CURRENT('Program'),
    @TuitionFee = 130000,
    @AdmissionFee = NULL,
    @HostelFee = NULL,
    @Notes = NULL;

-- Test invalid program ID
EXEC UpdateFeeStructure 
    @ProgramID = 9999,
    @TuitionFee = 120000,
    @AdmissionFee = 6000,
    @HostelFee = 25000,
    @Notes = 'Test';


--sp 8
EXEC GetNotifications @UserID = 1;
-- Test valid user
EXEC GetNotifications @UserID = IDENT_CURRENT('User');

-- Test NULL parameter
EXEC GetNotifications @UserID = NULL;

-- Test invalid user ID
EXEC GetNotifications @UserID = 9999;

-- Test user with no notifications
INSERT INTO [User] (Name, Email, Password, RoleID) 
VALUES ('No Notif User', 'nonotif@example.com', 'password', 1);
EXEC GetNotifications @UserID = IDENT_CURRENT('User');


-- sp 9
EXEC SearchProgramsByTags @Tag = 'engineering';
-- Test valid tag
EXEC SearchProgramsByTags @Tag = 'engineering';

-- Test NULL parameter
EXEC SearchProgramsByTags @Tag = NULL;

-- Test empty tag
EXEC SearchProgramsByTags @Tag = '';

-- Test non-existent tag
EXEC SearchProgramsByTags @Tag = 'nonexistent';

-- Test partial match
EXEC SearchProgramsByTags @Tag = 'eng';


-- sp 10
EXEC MarkNotificationRead @NotificationID = 3;
-- Test valid notification
EXEC MarkNotificationRead @NotificationID = IDENT_CURRENT('Notification');

-- Test NULL parameter
EXEC MarkNotificationRead @NotificationID = NULL;

-- Test invalid notification ID
EXEC MarkNotificationRead @NotificationID = 9999;

-- Test already read notification
EXEC MarkNotificationRead @NotificationID = IDENT_CURRENT('Notification');
EXEC MarkNotificationRead @NotificationID = IDENT_CURRENT('Notification');






---- VIEWS-----------------------------------------------------------------------

-- View 1: Program + University details
CREATE OR ALTER VIEW View_ProgramDetails AS
SELECT 
    p.ProgramID,
    p.Name AS ProgramName,
    p.DegreeType,
    p.Duration,
    u.Name AS UniversityName,
    u.Type AS UniversityType,
    u.City,
    u.Website,
    f.TuitionFee,
    f.AdmissionFee,
    f.HostelFee,
    f.Notes AS FeeNotes
FROM Program p
JOIN University u ON p.UniversityID = u.UniversityID
LEFT JOIN FeeStructure f ON p.ProgramID = f.ProgramID;
GO

-- View 2: Materialized View (Simulated)
-- First create the table structure
CREATE TABLE MatView_ProgramSummary (
    ProgramID INT PRIMARY KEY,
    Name NVARCHAR(100),
    TotalSaves INT,
    LastUpdated DATETIME DEFAULT GETDATE()
);
GO

-- Then populate it with initial data
INSERT INTO MatView_ProgramSummary (ProgramID, Name, TotalSaves)
SELECT 
    p.ProgramID,
    p.Name,
    COUNT(DISTINCT s.UserID) AS TotalSaves
FROM Program p
LEFT JOIN SavedPrograms s ON p.ProgramID = s.ProgramID
GROUP BY p.ProgramID, p.Name;
GO

-- Procedure to refresh the materialized view
CREATE OR ALTER PROCEDURE Refresh_ProgramSummaryView
AS
BEGIN
    -- Update existing records
    UPDATE m
    SET 
        m.Name = p.Name,
        m.TotalSaves = cnt.TotalSaves,
        m.LastUpdated = GETDATE()
    FROM MatView_ProgramSummary m
    JOIN (
        SELECT 
            p.ProgramID,
            p.Name,
            COUNT(DISTINCT s.UserID) AS TotalSaves
        FROM Program p
        LEFT JOIN SavedPrograms s ON p.ProgramID = s.ProgramID
        GROUP BY p.ProgramID, p.Name
    ) cnt ON m.ProgramID = cnt.ProgramID
    JOIN Program p ON m.ProgramID = p.ProgramID;
    
    -- Insert new programs
    INSERT INTO MatView_ProgramSummary (ProgramID, Name, TotalSaves)
    SELECT 
        p.ProgramID,
        p.Name,
        COUNT(DISTINCT s.UserID) AS TotalSaves
    FROM Program p
    LEFT JOIN SavedPrograms s ON p.ProgramID = s.ProgramID
    WHERE p.ProgramID NOT IN (SELECT ProgramID FROM MatView_ProgramSummary)
    GROUP BY p.ProgramID, p.Name;
    
    -- Delete programs that no longer exist
    DELETE FROM MatView_ProgramSummary
    WHERE ProgramID NOT IN (SELECT ProgramID FROM Program);
END;
GO


-- View 3: Program eligibility requirements
CREATE OR ALTER VIEW View_ProgramEligibility AS
SELECT 
    p.ProgramID,
    p.Name AS ProgramName,
    e.MinPercentage,
    STRING_AGG(rs.SubjectName, ', ') AS RequiredSubjects
FROM Program p
JOIN Eligibility e ON p.ProgramID = e.ProgramID
LEFT JOIN RequiredSubject rs ON e.CriteriaID = rs.CriteriaID
GROUP BY p.ProgramID, p.Name, e.MinPercentage;
GO


-- View 4: User saved programs
CREATE OR ALTER VIEW View_UserSavedPrograms AS
SELECT 
    u.UserID,
    u.Name AS UserName,
    p.ProgramID,
    p.Name AS ProgramName,
    u2.Name AS UniversityName,
    sp.SavedOn
FROM [User] u
JOIN SavedPrograms sp ON u.UserID = sp.UserID
JOIN Program p ON sp.ProgramID = p.ProgramID
JOIN University u2 ON p.UniversityID = u2.UniversityID;
GO

--View 5: program by city
CREATE VIEW View_ProgramCountByCity AS
SELECT 
    u.City,
    COUNT(*) AS ProgramCount
FROM University u
JOIN Program p ON u.UniversityID = p.UniversityID
GROUP BY u.City;


--Testing the views

-- Test View 1: Program Details
SELECT * FROM View_ProgramDetails;
SELECT * FROM View_ProgramDetails WHERE City = 'Lahore';
SELECT * FROM View_ProgramDetails WHERE TuitionFee < 150000;

-- Test Materialized View
SELECT * FROM MatView_ProgramSummary;
EXEC Refresh_ProgramSummaryView; -- Test refresh procedure
SELECT * FROM MatView_ProgramSummary ORDER BY TotalSaves DESC;

-- Test View 3: Program Eligibility
SELECT * FROM View_ProgramEligibility;
SELECT * FROM View_ProgramEligibility WHERE MinPercentage <= 80;

-- Test View 4: User Saved Programs
SELECT * FROM View_UserSavedPrograms;
SELECT * FROM View_UserSavedPrograms WHERE UserID = 1;





---INDEXED VIEW-----------------

CREATE VIEW View_ProgramCountByUniversity WITH SCHEMABINDING AS
SELECT 
    u.UniversityID,
    u.Name AS UniversityName,
    COUNT_BIG(*) AS ProgramCount
FROM dbo.University u
JOIN dbo.Program p ON u.UniversityID = p.UniversityID
GROUP BY u.UniversityID, u.Name;
GO

CREATE UNIQUE CLUSTERED INDEX IX_View_ProgramCountByUniversity 
ON View_ProgramCountByUniversity (UniversityID);



-- Add documentation to views
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Shows program details with university information and fees',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'VIEW', @level1name = N'View_ProgramDetails';




--Grant permissions to specific roles

-- 1. First, create the roles if they don't exist
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'StudentRole')
BEGIN
    CREATE ROLE StudentRole;
    PRINT 'StudentRole created successfully';
END
ELSE
    PRINT 'StudentRole already exists';

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole')
BEGIN
    CREATE ROLE AdminRole;
    PRINT 'AdminRole created successfully';
END
ELSE
    PRINT 'AdminRole already exists';
GO

-- 2. Now grant permissions to these roles
-- StudentRole permissions (read-only access to most views)
GRANT SELECT ON View_ProgramDetails TO StudentRole;
GRANT SELECT ON View_ProgramEligibility TO StudentRole;
GRANT SELECT ON MatView_ProgramSummary TO StudentRole;
GRANT SELECT ON View_UserSavedPrograms TO StudentRole;
PRINT 'Granted SELECT permissions to StudentRole';

-- AdminRole permissions (full access)
GRANT SELECT, INSERT, UPDATE, DELETE ON View_ProgramDetails TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON View_ProgramEligibility TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON MatView_ProgramSummary TO AdminRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON View_UserSavedPrograms TO AdminRole;
GRANT EXECUTE ON Refresh_ProgramSummaryView TO AdminRole;
PRINT 'Granted full permissions to AdminRole';

-- 3. Create database users and add them to roles
-- Example for a student user
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'student1')
BEGIN
    CREATE USER student1 WITHOUT LOGIN;
    ALTER ROLE StudentRole ADD MEMBER student1;
    PRINT 'Created student1 user and added to StudentRole';
END

-- Example for an admin user
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin1')
BEGIN
    CREATE USER admin1 WITHOUT LOGIN;
    ALTER ROLE AdminRole ADD MEMBER admin1;
    PRINT 'Created admin1 user and added to AdminRole';
END
GO


------------------------ Test student permissions
EXECUTE AS USER = 'student1';
GO
-- These should work
SELECT * FROM View_ProgramDetails;
SELECT * FROM View_ProgramEligibility;
-- These should fail
INSERT INTO MatView_ProgramSummary VALUES (999, 'Test Program', 0, GETDATE());
EXEC Refresh_ProgramSummaryView;
GO
REVERT;
GO

-- Test admin permissions
EXECUTE AS USER = 'admin1';
GO
-- These should all work
SELECT * FROM View_UserSavedPrograms;
INSERT INTO MatView_ProgramSummary VALUES (999, 'Test Program', 0, GETDATE());
EXEC Refresh_ProgramSummaryView;
GO
REVERT;
GO