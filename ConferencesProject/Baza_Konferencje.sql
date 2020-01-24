Use u_bplewnia

EXEC dbo.AddConference @Price = 200,                      -- money
                       @ConferenceName = 'Wyk³ad z baz danych',               -- varchar(30)
                       @ConferenceDescription = 'Wyk³ad numer 10',        -- varchar(150)
                       @StartDate = '2020-02-25 10:12:50', -- datetime
                       @EndDate = '2020-02-27 12:12:50',   -- datetime
                       @ParticipantsLimit =		5,             -- int
                       @Address = 'D17'                       -- varchar(60)

							

EXEC dbo.AddStudentDiscount @ConferenceID = 84,      -- int
                            @StudentDiscount = 0.5 -- decimal(3, 3)


SELECT * FROM Conferences ORDER BY 1 desc

SELECT * FROM ConferenceDays WHERE ConferenceID = 84

EXEC dbo.AddWorkshop @ConferenceDayID = 311,               -- int
                     @WorkshopName = 'Warsztat z baz danych',                 -- varchar(30)
                     @WorkshopDescription = 'Warsztat numer 20',          -- varchar(150)
                     @Price = 50,                      -- money
                     @Address = 'D17',                      -- varchar(60)
                     @StartDate = '2020-02-25 15:15:16', -- datetime
                     @EndDate = '2020-02-25 17:15:16',   -- datetime
                     @ParticipantsLimit = 4              -- int

EXEC dbo.AddWorkshop @ConferenceDayID = 311,               -- int
                     @WorkshopName = 'Warsztat z baz danych',                 -- varchar(30)
                     @WorkshopDescription = 'Warsztat numer 21',          -- varchar(150)
                     @Price = 60,                      -- money
                     @Address = 'D17',                      -- varchar(60)
                     @StartDate = '2020-02-25 16:16:17', -- datetime
                     @EndDate = '2020-02-25 18:16:17',   -- datetime
                     @ParticipantsLimit = 4              -- int

SELECT * FROM dbo.ConferencesAndWorkshops WHERE ConferenceID=84

EXEC dbo.AddCompanyClient @Name = 'Studenciaki',        -- varchar(30)
                          @CityName = 'Krakow',    -- varchar(30)
                          @CountryName = 'Polska', -- varchar(30)
                          @Phone = '+48123123123',       -- char(12)
                          @Email = 'studenciaki@gmail.com',       -- varchar(30)
                          @CompanyName = 'Studenciaki', -- varchar(30)
                          @NIP = '1234567899',         -- char(10)
                          @ContactName = 'Studenciaki'  -- varchar(30)

SELECT * FROM dbo.Clients ORDER BY 1 desc

EXEC dbo.AddConferenceBooking @ClientID = 964 -- int

SELECT * FROM ConferenceDaysInfo ORDER BY 1 desc

SELECT * FROM dbo.ConferenceReservations ORDER BY 1 DESC

DECLARE @tb StudentIDLIST;
INSERT INTO @tb VALUES (123456),(123542)
EXEC AddConferenceDayCompanyBooking 1922, 311, 1, 2, @tb

SELECT * FROM dbo.ConferenceReservationInfo WHERE ConferenceReservationID=1922


SELECT * FROM ConferenceDaysInfo ORDER BY 1 desc

SELECT * FROM Workshops ORDER BY 1 Desc

SELECT * FROM dbo.ConferenceDayReservations ORDER BY 1 desc

EXEC AddWorkshopBooking 3710, 1232, 2
EXEC AddWorkshopBooking 3710, 1231, 2

-- places taken 3 free 2

SELECT * FROM dbo.ConferenceParticipants ORDER BY 1 desc

SELECT * FROM dbo.WorkshopReservations ORDER BY 1 desc

EXEC dbo.AddWorkshopParticipant @ParticipantID = 37068,        -- int
                                @WorkshopReservationID = 14834 -- int

EXEC dbo.AddWorkshopParticipant @ParticipantID = 37068,        -- int
                                @WorkshopReservationID = 14835 -- int

SELECT * FROM dbo.ConferenceReservationInfo WHERE ConferenceReservationID=1922

EXEC dbo.AddPriceThreshold @ConferenceID = 84,                  -- int
                           @Discount = 0.5,                   -- decimal(3, 3)
                           @StartDate = '2020-01-15 15:46:57', -- datetime
                           @EndDate = '2020-01-30 15:46:57'    -- datetime


SELECT * FROM dbo.ConferenceReservationInfo WHERE ConferenceReservationID=1922

CREATE FUNCTION ConferenceReservationPrice (@ConferenceReservationID int)
RETURNS Money
AS
BEGIN
	DECLARE @sum MONEY = 0;
	DECLARE @WorkshopNumber INT = (SELECT COUNT(*) FROM dbo.WorkshopReservations AS WR JOIN dbo.ConferenceDayReservations AS CDR ON CDR.ConferenceDayReservationID = WR.ConferenceDayReservationID
	WHERE CDR.ConferenceReservationID=@ConferenceReservationID);
	DECLARE @WorkshopsResID TABLE (ID INT IDENTITY(1,1) PRIMARY KEY, WorkshopReservationID INT)
	INSERT INTO @WorkshopsResID SELECT WR.WorkshopReservationID FROM dbo.WorkshopReservations AS WR JOIN dbo.ConferenceDayReservations AS 
	CDR ON CDR.ConferenceDayReservationID = WR.ConferenceDayReservationID WHERE CDR.ConferenceReservationID=@ConferenceReservationID;
	DECLARE @cnt INT = 0;
	WHILE @cnt < @WorkshopNumber
	BEGIN
		DECLARE @WorkshopReservationID INT = (SELECT WorkshopReservationID FROM @WorkshopsResID WHERE ID = @cnt + 1);
		DECLARE @NumberOfParticipants INT = (SELECT NumberOfParticipants FROM dbo.WorkshopReservations WHERE WorkshopReservationID=@WorkshopReservationID);
		DECLARE @WorkshopID INT = (SELECT WorkshopID FROM dbo.WorkshopReservations WHERE WorkshopReservationID=@WorkshopReservationID);
		DECLARE @Price MONEY = (SELECT Price FROM Workshops WHERE WorkshopID=@WorkshopID);
		SET @sum = @sum + (SELECT @NumberOfParticipants*@Price)
		SET @cnt = @cnt + 1
	END
	DECLARE @DaysNumber INT = (SELECT COUNT(*) FROM dbo.ConferenceDayReservations WHERE ConferenceReservationID=@ConferenceReservationID);
	DECLARE @DaysResID TABLE (ID INT IDENTITY(1,1) PRIMARY KEY, ConferenceDayReservationID INT)
	INSERT INTO @DaysResID SELECT ConferenceDayReservationID FROM dbo.ConferenceDayReservations WHERE ConferenceReservationID=@ConferenceReservationID;
	SET @cnt = 0;
	WHILE @cnt < @DaysNumber
	BEGIN
		DECLARE @ReservationDate DATETIME = (SELECT ReservationDate FROM dbo.ConferenceReservations WHERE ConferenceReservationID=@ConferenceReservationID);
		DECLARE @ConferenceDayReservationID INT = (SELECT ConferenceDayReservationID FROM @DaysResID WHERE ID = @cnt + 1);
		DECLARE @ConferenceID INT = (SELECT TOP 1 CD.ConferenceID FROM dbo.ConferenceDayReservations AS CDR JOIN dbo.ConferenceDays AS CD ON CD.ConferenceDayID = CDR.ConferenceDayID
			WHERE CDR.ConferenceDayReservationID=@ConferenceDayReservationID);
		DECLARE @CPrice MONEY = (SELECT Price FROM Conferences WHERE ConferenceID=@ConferenceID);
		DECLARE @CDiscount DECIMAL(3,3) = (SELECT StudentDiscount FROM Conferences WHERE ConferenceID=@ConferenceID);
		DECLARE @TDiscount DECIMAL(3,3) = (SELECT Discount FROM Conferences AS C LEFT JOIN Prices AS P ON P.ConferenceID = C.ConferenceID AND @ReservationDate BETWEEN P.StartDate AND
			P.EndDate WHERE C.ConferenceID=@ConferenceID);
		DECLARE @CNumberOfParticipants INT = (SELECT NumberOfParticipants FROM dbo.ConferenceDayReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID);
		DECLARE @CNumberOfStudents INT = (SELECT NumberOfStudents FROM dbo.ConferenceDayReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID);
		SET @sum = @sum + ((SELECT @CNumberOfParticipants*@CPrice*(1-ISNULL(@TDiscount,0))) + (SELECT @CNumberOfStudents*(1-ISNULL(@CDiscount,0))*@CPrice*(1-ISNULL(@TDiscount,0))))
		SET @cnt = @cnt + 1
	END
	RETURN @sum
END
GO

SELECT [dbo].ConferenceReservationPrice(500)

EXEC dbo.DeleteConferenceCompanyReservation @ConferenceReservationID = 1922 -- int

SELECT * FROM ConferenceDaysInfo ORDER BY 1 desc

SELECT * FROM dbo.ConferenceReservationInfo WHERE ConferenceReservationID = 100

SELECT * FROM dbo.ConferenceDayReservations WHERE ConferenceDayReservationID=1874

SELECT * FROM dbo.ConferenceDaysInfo WHERE ConferenceDayID=5

-- 111 wolnych miejsc konferencja, 19 warsztat

SELECT * FROM WorkshopInfo WHERE WorkshopID=1131

SELECT * FROM  dbo.Clients
SELECT * FROM Companies
SELECT * FROM CompanyEmployees
SELECT * FROM ConferenceDayReservations
SELECT * FROM ConferenceDays
SELECT * FROM ConferenceParticipants
SELECT * FROM ConferenceReservations
SELECT * FROM Conferences
SELECT * FROM Person
SELECT * FROM Prices
SELECT * FROM PrivateClients
SELECT * FROM WorkshopDetails
SELECT * FROM WorkshopParticipants
SELECT * FROM WorkshopReservations
SELECT * FROM Workshops
SELECT * FROM Cities
SELECT * FROM dbo.Countries


Create table Countries (
	CountryID int IDENTITY(1,1) PRIMARY KEY,
	CountryName varchar(30),
	UNIQUE (CountryName)
)

Create table Cities (
	CityID int IDENTITY(1,1) PRIMARY KEY,
	CityName varchar(30),
	CountryID INT,
	UNIQUE(CityName),
	FOREIGN KEY(CountryID) References Countries(CountryID)
)

Create table Clients (
	ClientID int IDENTITY(1,1) PRIMARY KEY,
	Name varchar(30) NOT NULL,
	CityID int NOT NULL, 
	Phone char(12) NOT NULL,
	Email varchar(30) NOT NULL,
	UNIQUE(Email),
	UNIQUE(Phone),
	CONSTRAINT CC_Phone CHECK (Phone like '%+%'),
	CONSTRAINT CC_Phone2 CHECK (Phone not like '%[^0-9+]%'),
	CONSTRAINT CC_Email CHECK (Email like '%@%'),
	FOREIGN KEY(CityID) References Cities(CityID)
);

Create table Companies (
	CompanyID int PRIMARY KEY,
	CompanyName varchar(30) NOT NULL,
	NIP char(10) NOT NULL,
	ContactName varchar(30) NOT NULL,
	UNIQUE(CompanyName),
	UNIQUE(NIP),
	FOREIGN KEY(CompanyID) REFERENCES Clients(ClientID)
);

Create table Person (
	PersonID int IDENTITY(1,1) PRIMARY KEY,
	FirstName varchar(30),
	LastName varchar(30)
);

Create table PrivateClients (
	PersonID int PRIMARY KEY,
	ClientID int NOT NULL,
	FOREIGN KEY(ClientID) REFERENCES Clients(ClientID),
	FOREIGN KEY(PersonID) REFERENCES Person(PersonID)
);

Create table CompanyEmployees(
	PersonID int PRIMARY KEY,
	CompanyID int NOT NULL,
	FOREIGN KEY(CompanyID) REFERENCES Companies(CompanyID),
	FOREIGN KEY(PersonID) REFERENCES Person(PersonID)
);

Create table ConferenceReservations(
	ConferenceReservationID int IDENTITY(1,1) PRIMARY KEY,
	ClientID int NOT NULL,
	ReservationDate datetime DEFAULT GETDATE(),
	PaymentDate datetime,
	FOREIGN KEY(ClientID) REFERENCES Clients(ClientID),
	CONSTRAINT CCR_PaymentDate CHECK (ISNULL(PaymentDate,ReservationDate)>=ReservationDate)
);

Create table Conferences(
	ConferenceID int IDENTITY(1,1) PRIMARY KEY,
	Price money NOT NULL,
	ConferenceName varchar(30) NOT NULL,
	ConferenceDescription varchar(150) NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	StudentDiscount decimal(3,3) DEFAULT 0,
	ParticipantsLimit int NOT NULL,
	Address varchar(60) NOT NULL,
	CONSTRAINT CCO_Price CHECK (Price > 0),
	CONSTRAINT CCO_EndDate CHECK (EndDate>StartDate),
	CONSTRAINT CCO_StudentDiscount CHECK (StudentDiscount between 0 and 1),
	CONSTRAINT CCO_ParticipantsLimit CHECK (ParticipantsLimit > 0)
);

Create table Prices(
	PriceID int IDENTITY(1,1) PRIMARY KEY,
	ConferenceID int NOT NULL,
	Discount decimal(3,3) DEFAULT 0,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	FOREIGN KEY (ConferenceID) REFERENCES Conferences(ConferenceID),
	CONSTRAINT CP_Discount CHECK (Discount between 0 and 1),
	CONSTRAINT CP_EndDate CHECK (EndDate>StartDate)
);

Create table ConferenceDays(
	ConferenceDayID int IDENTITY(1,1) PRIMARY KEY,
	ConferenceID int NOT NULL,
	FOREIGN KEY (ConferenceID) REFERENCES Conferences(ConferenceID)
);

Create table WorkshopDetails(
	WorkshopDetailsID int IDENTITY(1,1) PRIMARY KEY,
	WorkshopName varchar(30) NOT NULL,
	WorkshopDescription varchar(150) NOT NULL,
	Price money NOT NULL,
	Address varchar(60) NOT NULL,
	CONSTRAINT CWD_Price CHECK (Price > 0)
);

Create table Workshops(
	WorkshopID int IDENTITY(1,1) PRIMARY KEY,
	ConferenceDayID int NOT NULL,
	WorkshopDetailsID int NOT NULL,
	Price money NOT NULL,
	StartDate datetime NOT NULL,
	EndDate datetime NOT NULL,
	ParticipantsLimit int NOT NULL,
	FOREIGN KEY (ConferenceDayID) REFERENCES ConferenceDays(ConferenceDayID),
	FOREIGN KEY (WorkshopDetailsID) REFERENCES WorkshopDetails(WorkshopDetailsID),
	CONSTRAINT CW_Price CHECK (Price > 0),
	CONSTRAINT CW_EndDate CHECK (EndDate>StartDate),
	CONSTRAINT CW_ParticipantsLimit CHECK (ParticipantsLimit > 0)
);


Create table ConferenceDayReservations(
	ConferenceDayReservationID int IDENTITY(1,1) PRIMARY KEY,
	ConferenceReservationID int NOT NULL,
	ConferenceDayID int NOT NULL,
	NumberOfParticipants int NOT NULL,
	NumberOfStudents int NOT NULL,
	FOREIGN KEY (ConferenceReservationID) REFERENCES ConferenceReservations(ConferenceReservationID),
	FOREIGN KEY (ConferenceDayID) REFERENCES ConferenceDays(ConferenceDayID),
	CONSTRAINT CCDR_NumberOfParticipants CHECK (NumberOfParticipants >= 0),
	CONSTRAINT CCDR_NumberOfStudents CHECK (NumberOfStudents >= 0)
);

Create table ConferenceParticipants(
	ParticipantID int IDENTITY(1,1) PRIMARY KEY,
	PersonID int NOT NULL,
	StudentID int,
	ConferenceDayReservationID int NOT NULL,
	FOREIGN KEY (PersonID) REFERENCES Person(PersonID),
	FOREIGN KEY (ConferenceDayReservationID) REFERENCES ConferenceDayReservations(ConferenceDayReservationID)
);

Create table WorkshopReservations(
	WorkshopReservationID int IDENTITY(1,1) PRIMARY KEY,
	WorkshopID int NOT NULL,
	ConferenceDayReservationID int NOT NULL,
	NumberOfParticipants int NOT NULL,
	FOREIGN KEY (WorkshopID) REFERENCES Workshops(WorkshopID),
	FOREIGN KEY (ConferenceDayReservationID) REFERENCES ConferenceDayReservations(ConferenceDayReservationID),
	CONSTRAINT CWR_NumberOfParticipants CHECK (NumberOfParticipants > 0)
);

CREATE table WorkshopParticipants(
	ParticipantID int IDENTITY(1,1) PRIMARY KEY,
	DayParticipantID INT NOT NULL,
	WorkshopReservationID int NOT NULL,
	FOREIGN KEY (WorkshopReservationID) REFERENCES WorkshopReservations(WorkshopReservationID),
	FOREIGN KEY (DayParticipantID) REFERENCES ConferenceParticipants(ParticipantID)
);
Go

Drop view ConferenceDaysInfo
Drop view ConferenceDayParticipants
Drop view ListedConferenceParticipants
Drop view AvalaibleConferenceDays
Drop view WorkshopInfo
Drop view ListedWorkshopParticipants
Drop view AvalaibleWorkshops
Drop view MostPopularConferences
Drop view MostPopularWorkshops
Drop view MostFrequentParticipants
Drop view UnfilledBookings
Drop view BookingsPaidAfterDeadline
Drop view BookingsNotPaidYet
Drop view CorrectlyPaidBookings
Drop view ClientStats
Drop view ConferencesAndWorkshops
Go

Create view ConferenceDaysInfo as
Select CD.ConferenceDayID,C.ConferenceID,C.ConferenceName,C.ParticipantsLimit,
(SUM(ISNULL(CDR.NumberOfParticipants,0))+SUM(ISNULL(CDR.NumberOfStudents,0))) as PlacesTaken,
(C.ParticipantsLimit - (SUM(ISNULL(CDR.NumberOfParticipants,0))+
SUM(ISNULL(CDR.NumberOfStudents,0)))) as PlacesFree
From Conferences as C JOIN ConferenceDays as CD on C.ConferenceID=CD.ConferenceID
LEFT JOIN ConferenceDayReservations as CDR on CD.ConferenceDayID=CDR.ConferenceDayID
Group by CD.ConferenceDayID,C.ConferenceID,C.ConferenceName,C.ParticipantsLimit
GO

SELECT * FROM ConferenceDaysInfo ORDER BY 1

Create view ConferenceDayParticipants as
Select  P.PersonID,P.FirstName, P.LastName,CD.ConferenceDayID, CD.ConferenceID, CP.ParticipantID
From ConferenceDays as CD JOIN ConferenceDayReservations as CDR 
on CD.ConferenceDayID=CDR.ConferenceDayID
JOIN ConferenceParticipants as CP on CP.ConferenceDayReservationID=CDR.ConferenceDayReservationID
JOIN Person as P on P.PersonID=CP.PersonID
Go

SELECT * FROM dbo.ConferenceDayParticipants WHERE FirstName IS NOT NULL ORDER BY 2,3 


CREATE view ListedConferenceParticipants as
Select CP.ParticipantID,P.PersonID,P.FirstName,P.LastName,C.ConferenceID, C.ConferenceName,
(DATEDIFF(DAY,C.StartDate,C.EndDate)+1) as NumberOfDays,
(Select count(*) from ConferenceDays as CD2 JOIN ConferenceDayReservations as CDR2
on CD2.ConferenceDayID=CDR2.ConferenceDayID JOIN ConferenceParticipants as CP2 
on CP2.ConferenceDayReservationID=CDR2.ConferenceDayReservationID
Where CD2.ConferenceID=CD.ConferenceID and CP2.ParticipantID=CP.ParticipantID) as DaysParticipated
From Conferences as C JOIN ConferenceDays as CD on C.ConferenceID=CD.ConferenceID
JOIN ConferenceDayReservations as CDR 
on CD.ConferenceDayID=CDR.ConferenceDayID
JOIN ConferenceParticipants as CP on CP.ConferenceDayReservationID=CDR.ConferenceDayReservationID
JOIN Person as P on P.PersonID=CP.PersonID
GO

SELECT * FROM dbo.ListedConferenceParticipants WHERE FirstName IS NOT NULL ORDER BY 3,4

Create view AvalaibleConferenceDays as
Select CD.ConferenceDayID, CD.ConferenceID, C.ParticipantsLimit,
(SUM(ISNULL(CDR.NumberOfParticipants,0))+SUM(ISNULL(CDR.NumberOfStudents,0))) as PlacesTaken,
(C.ParticipantsLimit - (SUM(ISNULL(CDR.NumberOfParticipants,0))+
SUM(ISNULL(CDR.NumberOfStudents,0)))) as PlacesFree
From ConferenceDays as CD JOIN Conferences as C on C.ConferenceID=CD.ConferenceID
JOIN ConferenceDayReservations as CDR on CDR.ConferenceDayID=CD.ConferenceDayID
Where C.ParticipantsLimit-(Select sum(CDR2.NumberOfParticipants+CDR2.NumberOfStudents) 
from ConferenceDayReservations as CDR2
Where CDR.ConferenceDayID=CDR2.ConferenceDayID) > 0
Group by CD.ConferenceDayID, CD.ConferenceID, C.ParticipantsLimit
Go

SELECT * FROM dbo.AvalaibleConferenceDays

Create view WorkshopInfo as
Select W.WorkshopID,W.ConferenceDayID,WD.WorkshopName, W.Price, W.ParticipantsLimit,
SUM(ISNULL(WR.NumberOfParticipants,0)) as PlacesTaken,
W.ParticipantsLimit - SUM(ISNULL(WR.NumberOfParticipants,0)) as PlacesFree
From Workshops as W JOIN WorkshopDetails as WD on W.WorkshopDetailsID=WD.WorkshopDetailsID
JOIN WorkshopReservations as WR on WR.WorkshopID=W.WorkshopID
Group by W.WorkshopID,W.ConferenceDayID,WD.WorkshopName, W.Price, W.ParticipantsLimit
Go

SELECT * FROM dbo.WorkshopInfo ORDER BY 1 

CREATE view ListedWorkshopParticipants as
Select CP.ParticipantID,P.PersonID,P.FirstName,P.LastName,W.WorkshopID, WD.WorkshopName,
(DATEDIFF(hour,W.StartDate,W.EndDate)) as NumberOfHours
From Workshops as W JOIN WorkshopDetails as WD on W.WorkshopDetailsID=WD.WorkshopDetailsID
JOIN WorkshopReservations as WR on W.WorkshopID=WR.WorkshopID
JOIN WorkshopParticipants as WP on WP.WorkshopReservationID=WR.WorkshopReservationID
JOIN ConferenceParticipants as CP on WP.ParticipantID=CP.ParticipantID
JOIN Person as P on CP.PersonID=P.PersonID
Go 

SELECT * FROM dbo.ListedWorkshopParticipants WHERE FirstName IS NOT NULL ORDER BY 3,4

Create view AvalaibleWorkshops as
Select W.WorkshopID,W.ConferenceDayID,WD.WorkshopName, W.Price, W.ParticipantsLimit,
SUM(ISNULL(WR.NumberOfParticipants,0)) as PlacesTaken,
W.ParticipantsLimit - SUM(ISNULL(WR.NumberOfParticipants,0)) as PlacesFree
From Workshops as W JOIN WorkshopDetails as WD on W.WorkshopDetailsID=WD.WorkshopDetailsID
JOIN WorkshopReservations as WR on WR.WorkshopID=W.WorkshopID
Where W.ParticipantsLimit - (Select sum(WR2.NumberOfParticipants) From
WorkshopReservations as WR2 where WR.WorkshopID=WR2.WorkshopID) > 0
Group by W.WorkshopID,W.ConferenceDayID,WD.WorkshopName, W.Price, W.ParticipantsLimit
Go

SELECT * FROM dbo.AvalaibleWorkshops ORDER BY 1 Go

Create view MostPopularConferenceDays as
Select CD.ConferenceDayID, CD.ConferenceID, C.ConferenceName, C.ParticipantsLimit,
(Select sum(ISNULL(CDR.NumberOfParticipants,0) + ISNULL(CDR.NumberOfStudents,0)))
as PlacesTaken,
((Select sum(ISNULL(CDR.NumberOfParticipants,0))+SUM(ISNULL(CDR.NumberOfStudents,0)))/
CAST(C.ParticipantsLimit as Decimal (9,2))) as Fill_Factor
From ConferenceDays as CD JOIN ConferenceDayReservations as CDR on CDR.ConferenceDayID=CD.ConferenceDayID
JOIN Conferences AS C ON C.ConferenceID=CD.ConferenceID
Group by CD.ConferenceDayID, CD.ConferenceID, C.ConferenceName, C.ParticipantsLimit
GO

SELECT TOP 10 * FROM dbo.MostPopularConferenceDays ORDER BY 6 DESC Go

CREATE view MostPopularWorkshops as
Select W.WorkshopID,WD.WorkshopName,W.ParticipantsLimit,
(Select sum(ISNULL(WR.NumberOfParticipants,0))) as PlacesTaken,
(Select sum(ISNULL(WR.NumberOfParticipants,0)))/CAST(W.ParticipantsLimit as Decimal(9,2))as Fill_Factor
From Workshops as W JOIN WorkshopDetails as WD on W.WorkshopDetailsID=WD.WorkshopDetailsID
JOIN WorkshopReservations as WR on WR.WorkshopID=W.WorkshopID
Group by W.WorkshopID,WD.WorkshopName,W.ParticipantsLimit
Go

SELECT TOP 10 * FROM dbo.MostPopularWorkshops ORDER BY 5 DESC Go

CREATE view MostFrequentParticipants as
SELECT P.FirstName, P.LastName, ((Select count(*) from ConferenceParticipants as CP2 JOIN dbo.Person AS P2 ON P2.PersonID = CP2.PersonID
WHERE P2.FirstName=P.FirstName AND P2.LastName=P.LastName) + 
(Select count(*) from WorkshopParticipants as WP JOIN dbo.ConferenceParticipants AS CP2 ON CP2.ParticipantID = WP.DayParticipantID
JOIN dbo.Person AS P2 ON P2.PersonID = CP2.PersonID WHERE P2.FirstName=P.FirstName AND P2.LastName=P.LastName)) as TotalParticipations
From ConferenceParticipants as CP JOIN Person as P on P.PersonID=CP.PersonID
Group by P.FirstName, P.LastName
Go

SELECT TOP 10 * FROM dbo.MostFrequentParticipants ORDER BY 3 desc

Create view UnfilledBookings as
Select P.PersonID, P.FirstName, P.LastName, CDR.ConferenceDayID,
CR.ConferenceReservationID, CR.ClientID
From Person as P JOIN ConferenceParticipants as CP on P.PersonID=CP.PersonID
JOIN ConferenceDayReservations as CDR 
on CDR.ConferenceDayReservationID=CP.ConferenceDayReservationID
JOIN ConferenceReservations as CR on CR.ConferenceReservationID=CDR.ConferenceReservationID
Where P.FirstName is NULL and P.LastName is NULL and
DATEDIFF(day,CR.ReservationDate,getdate())<=14
GO

SELECT * FROM dbo.UnfilledBookings ORDER BY 6

Create view BookingsPaidAfterDeadline as		
Select CR.ConferenceReservationID, CR.ReservationDate, CR.PaymentDate,
DATEDIFF(day,CR.ReservationDate,CR.PaymentDate)-7 as DayDelay
From ConferenceReservations as CR
Where CR.PaymentDate is not NULL and 
DATEDIFF(day,CR.ReservationDate,CR.PaymentDate)>7
Go

SELECT * FROM dbo.BookingsPaidAfterDeadline ORDER BY 1

Create view BookingsNotPaidYet as
Select CR.ConferenceReservationID, CR.ReservationDate, CR.PaymentDate
From ConferenceReservations as CR
Where CR.PaymentDate is NULL and
DATEDIFF(day,CR.ReservationDate,getdate())<=7
GO

SELECT * FROM dbo.BookingsNotPaidYet ORDER BY 1

Create view CorrectlyPaidBookings as
Select CR.ConferenceReservationID, CR.ReservationDate, CR.PaymentDate
From ConferenceReservations as CR
Where CR.PaymentDate is not NULL and 
DATEDIFF(day,CR.ReservationDate,CR.PaymentDate)<=7
Go

SELECT * FROM dbo.CorrectlyPaidBookings ORDER BY 1

CREATE view ClientStats as
Select C.ClientID, C.Name, C.Phone, C.Email, Ci.CityName, Co.CountryName,
(Select count(*) from ConferenceDayReservations as CDR JOIN ConferenceReservations as CR
on CDR.ConferenceReservationID=CR.ConferenceReservationID where CR.ClientID=C.ClientID) as TotalConferenceDays,
(Select count(*) from WorkshopReservations as WR JOIN ConferenceDayReservations as CDR 
on WR.ConferenceDayReservationID=CDR.ConferenceDayReservationID JOIN ConferenceReservations as CR
on CDR.ConferenceReservationID=CR.ConferenceReservationID where CR.ClientID=C.ClientID) as TotalWorkshops,
((Select ISNULL(SUM(W.Price),0) from WorkshopReservations as WR JOIN ConferenceDayReservations as CDR 
on WR.ConferenceDayReservationID=CDR.ConferenceDayReservationID JOIN ConferenceReservations as CR
on CDR.ConferenceReservationID=CR.ConferenceReservationID 
JOIN Workshops as W on W.WorkshopID=WR.WorkshopID WHERE CR.ClientID=C.ClientID) + 
(SELECT SUM(Co.Price*(1-ISNULL(discount,0))) FROM Conferences AS Co 
JOIN ConferenceDays as CD on CD.ConferenceID=Co.ConferenceID
JOIN ConferenceDayReservations AS CDR ON CDR.ConferenceDayID = CD.ConferenceDayID
JOIN ConferenceReservations AS CR ON CR.ConferenceReservationID = CDR.ConferenceReservationID
LEFT JOIN Prices as P on P.ConferenceID=Co.ConferenceID and CR.PaymentDate between P.StartDate and P.EndDate
Where CR.ClientID=C.ClientID)) as TotalPaid
From Clients as C JOIN Cities as Ci on C.CityID=Ci.CityID JOIN Countries as Co on Co.CountryID=Ci.CountryID
GO

SELECT * FROM dbo.ClientStats go

CREATE view ConferencesAndWorkshops as 
Select C.ConferenceID,C.ConferenceName,CD.ConferenceDayID,W.WorkshopID,WD.WorkshopName, C.StartDate AS ConferenceStart, C.EndDate AS 
ConferenceEnd, W.StartDate AS WorkshopStart, W.EndDate AS WorkshopEnd
from Conferences as C JOIN ConferenceDays as CD on C.ConferenceID=CD.ConferenceID
LEFT JOIN Workshops as W on W.ConferenceDayID=CD.ConferenceDayID 
LEFT JOIN WorkshopDetails as WD on WD.WorkshopDetailsID=W.WorkshopDetailsID
GO


SELECT * FROM dbo.ConferencesAndWorkshops ORDER BY 1,3,4 Go

CREATE VIEW ConferenceReservationInfo AS
SELECT CR.ConferenceReservationID, CDR.ConferenceDayReservationID, WR.WorkshopReservationID,WR.WorkshopID,
((SELECT CDR.NumberOfParticipants*SUM(C.Price*(1-ISNULL(P.Discount,0))) FROM ConferenceDays AS CD JOIN Conferences AS C 
ON C.ConferenceID = CD.ConferenceID LEFT JOIN dbo.Prices AS P 
ON P.ConferenceID = C.ConferenceID AND CR.ReservationDate BETWEEN P.StartDate AND P.EndDate WHERE CD.ConferenceDayID=CDR.ConferenceDayID) + 
(SELECT CDR.NumberOfStudents*SUM((1-ISNULL(C.StudentDiscount,0))*C.Price*(1-ISNULL(P.Discount,0))) FROM ConferenceDays AS CD JOIN Conferences AS C 
ON C.ConferenceID = CD.ConferenceID LEFT JOIN dbo.Prices AS P 
ON P.ConferenceID = C.ConferenceID AND CR.ReservationDate BETWEEN P.StartDate AND P.EndDate WHERE CD.ConferenceDayID=CDR.ConferenceDayID)) AS ConferenceDayPrice, 
(SELECT WR.NumberOfParticipants*W.Price) AS WorkshopPrice
FROM ConferenceReservations AS CR JOIN ConferenceDayReservations AS CDR ON CR.ConferenceReservationID=CDR.ConferenceReservationID
LEFT JOIN WorkshopReservations AS WR ON WR.ConferenceDayReservationID=CDR.ConferenceDayReservationID
LEFT JOIN dbo.Workshops AS W ON W.WorkshopID = WR.WorkshopID
GO

SELECT * FROM dbo.ConferenceReservationInfo Order BY 1,2,3,4

-- Procedury
Drop procedure AddConference
Drop procedure AddPriceThreshold
Drop procedure DeletePriceThreshold
Drop procedure AddStudentDiscount
Drop procedure AddWorkshop
Drop procedure ChangeConferenceInformation
Drop procedure ChangeWorkshopInformation
Drop procedure AddPrivateClient
Drop procedure UpdatePrivateClient
Drop procedure DeleteIncorrectReservations
Drop procedure AddPayment
Drop procedure AddConferenceBooking
Drop procedure AddConferenceDayCompanyBooking
Drop procedure AddConferenceDayIndividualBooking
Drop procedure AddWorkshopBooking
Drop procedure UpdatePerson
Drop procedure AddCompanyClient
Drop procedure UpdateCompanyClient
Go

Create Procedure AddConference 
@Price money,
@ConferenceName varchar(30),
@ConferenceDescription varchar(150),
@StartDate datetime,
@EndDate datetime,
@ParticipantsLimit int,
@Address varchar(60)
As 
Begin Try 
	Insert into Conferences 
	Values (@Price,@ConferenceName,@ConferenceDescription,@StartDate,@EndDate,NULL,
	@ParticipantsLimit,@Address)
	Declare @cnt int = 0;
	Declare @ConferenceID int = (Select MAX(C.ConferenceID) from Conferences as C);
	While @cnt <= DATEDIFF(day,@StartDate,@EndDate)
	Begin 
		Insert into ConferenceDays
		Values (@ConferenceID)
		Set @cnt = @cnt + 1
	End;
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding conference: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddPriceThreshold
@ConferenceID int,
@Discount decimal(3,3),
@StartDate datetime,
@EndDate datetime
As
Begin TRY
	IF @EndDate < @StartDate
	Begin
		RAISERROR('The end date is before start!',16,1);
	End;
	DECLARE @start DATETIME = (SELECT StartDate FROM Conferences WHERE ConferenceID = @ConferenceID);
	IF @EndDate > @start 
	Begin
		RAISERROR('The date range is post conference!',16,1);
	End;
	DECLARE @disc DECIMAL(3,3) = (SELECT MIN(Discount) FROM Prices WHERE ConferenceID=@ConferenceID
	AND EndDate<@EndDate);
	IF @disc < @Discount
	Begin
		RAISERROR('The discount is bigger than previous!',16,1);
	End;
	Insert into Prices
	Values (@ConferenceID,@Discount,@StartDate,@EndDate)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding price threshold: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddStudentDiscount
@ConferenceID int,
@StudentDiscount decimal(3,3)
As 
Begin Try
	Update Conferences
	Set StudentDiscount=@StudentDiscount
	Where ConferenceID = @ConferenceID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding student discount: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddWorkshop
@ConferenceDayID int,
@WorkshopName varchar(30),
@WorkshopDescription varchar(150),
@Price money,
@Address varchar(60),
@StartDate datetime,
@EndDate datetime,
@ParticipantsLimit int
As 
Begin Try
	If (Select top 1 ParticipantsLimit from Conferences as C JOIN ConferenceDays as CD on C.ConferenceID=CD.ConferenceID 
		Where CD.ConferenceID=@ConferenceDayID) < @ParticipantsLimit
	Begin
		RAISERROR('ParticipantsLimit bigger than in Conference!',16,1);
	End;
	Declare @ConferenceID int = (Select ConferenceID from ConferenceDays where ConferenceDayID=@ConferenceDayID);
	Declare @first_day int = (Select top 1 ConferenceDayID from ConferenceDays where ConferenceID = @ConferenceID);
	If (Select DATEPART(Day,C.StartDate)-@first_day+@ConferenceDayID From Conferences as C
	Where ConferenceID=@ConferenceID) != DATEPART(Day,@StartDate) or DATEPART(Hour,@StartDate) >= DATEPART(Hour,@EndDate)	
	Begin
		RAISERROR('The date is incorrect!',16,1);
	End;
	Insert into WorkshopDetails
	Values (@WorkshopName,@WorkshopDescription,@Price,@Address)
	Insert into Workshops
	Values (@ConferenceDayID,(Select max(WorkshopDetailsID) From WorkshopDetails),
	@Price,@StartDate,@EndDate,@ParticipantsLimit)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding workshop: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure DeletePriceThreshold
@PriceID int
As
Begin Try
	Delete From Prices Where PriceID=@PriceID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting price threshold: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure ChangeConferenceInformation
@ConferenceID int,
@Price money = NULL,
@ConferenceName varchar(30) = NULL,
@ConferenceDescription varchar(150) = NULL,
@StudentDiscount decimal(3,3) = NULL,
@Address varchar(60) = NULL
As 
Begin Try
	Update Conferences
	Set Price=ISNULL(@Price,Price),
	ConferenceName=ISNULL(@ConferenceName,ConferenceName),
	ConferenceDescription=ISNULL(@ConferenceDescription,ConferenceDescription),
	StudentDiscount=ISNULL(@StudentDiscount,StudentDiscount),
	Address=ISNULL(@Address,Address)
	Where ConferenceID=@ConferenceID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error while changing conference information: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure ChangeWorkshopInformation
@WorkshopID int,
@Price money = NULL,
@WorkshopName varchar(30) = NULL,
@WorkshopDescription varchar(150) = NULL,
@Address varchar(60) = NULL
As 
Begin Try
	Update Workshops
	Set Price=ISNULL(@Price,Price)
	Where WorkshopID=@WorkshopID
	Update WorkshopDetails
	Set WorkshopName=ISNULL(@WorkshopName,WorkshopName),
	WorkshopDescription=ISNULL(@WorkshopDescription,WorkshopDescription),
	Address=ISNULL(@Address,Address)
	Where WorkshopDetailsID=(Select WorkshopDetailsID from Workshops Where WorkshopID=@WorkshopID)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error while changing workshop information: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddPrivateClient
@Name varchar(30),
@CityName varchar(30),
@CountryName varchar(30),
@Phone char(12),
@Email varchar(30)
As 
Begin Try
	If (Select CountryID from Countries Where CountryName=@CountryName) is NULL
	Begin
		Insert into Countries Values (@CountryName)
	End;
	Declare @CountryID int = (Select CountryID from Countries Where CountryName=@CountryName);
	If (Select CityID from Cities Where CityName=@CityName) is NULL
	Begin
		Insert into Cities Values (@CityName,@CountryID)
	End;
	Declare @CityID int = (Select CityID from Cities Where CityName=@CityName);
	Insert into Clients
	Values (@Name,@CityID,@Phone,@Email)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding private client: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure UpdatePrivateClient
@ClientID int,
@Name varchar(30) = NULL,
@CityID int = NULL,	
@Phone char(12) = NULL,
@Email varchar(30) = NULL
As 
Begin Try
	Update Clients
	Set Name=ISNULL(@Name,Name),
	CityID=ISNULL(@CityID,CityID),
	Phone=ISNULL(@Phone,Phone),
	Email=ISNULL(@Email,Email)
	Where ClientID=@ClientID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error while updating private client: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddCompanyClient
@Name varchar(30),
@CityName varchar(30),
@CountryName varchar(30),
@Phone char(12),
@Email varchar(30),
@CompanyName varchar(30),
@NIP char(10),
@ContactName varchar(30)
As 
Begin Try
	If (Select CountryID from Countries Where CountryName=@CountryName) is NULL
	Begin
		Insert into Countries Values (@CountryName)
	End;
	Declare @CountryID int = (Select CountryID from Countries Where CountryName=@CountryName);
	If (Select CityID from Cities Where CityName=@CityName) is NULL
	Begin
		Insert into Cities Values (@CityName,@CountryID)
	End;
	Declare @CityID int = (Select CityID from Cities Where CityName=@CityName);
	Insert into Clients
	Values (@Name,@CityID,@Phone,@Email)
	Declare @ClientID int = (Select max(ClientID) from Clients);
	Insert into Companies
	Values (@ClientID,@CompanyName,@NIP,@ContactName)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding company client: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure UpdateCompanyClient 
@ClientID int,
@Name varchar(30) = NULL,
@CityID int = NULL,
@Phone char(12) = NULL,
@Email varchar(30) = NULL,
@CompanyName varchar(30) = NULL,
@NIP char(10) = NULL,
@ContactName varchar(30) = NULL
As
Begin Try
	Update Clients
	Set Name=ISNULL(@Name,Name),
	CityID=ISNULL(@CityID,CityID),
	Phone=ISNULL(@Phone,Phone),
	Email=ISNULL(@Email,Email)
	Where ClientID=@ClientID
	Update Companies
	Set CompanyName=ISNULL(@CompanyName,CompanyName),
	NIP=ISNULL(@NIP,NIP),
	ContactName=ISNULL(@ContactName,ContactName)
	Where CompanyID=@ClientID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error while updating company client: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure DeleteIncorrectReservations
As 
Begin Try
	Declare @cnt int = 1;
	Declare @size int = (Select count(*) from ConferenceReservations);
	While @cnt <= @size
	Begin
		Declare @res datetime = (Select ReservationDate from ConferenceReservations Where
		ConferenceReservationID=@cnt);
		Declare @pay datetime = (Select PaymentDate from ConferenceReservations Where
		ConferenceReservationID=@cnt);
		If DATEDIFF(DAY,@res,ISNULL(@pay,GETDATE()))>14
		Begin
			Delete from ConferenceReservations where ConferenceReservationID=@cnt
			Declare @days table (ConferenceDayReservationID INT NOT NULL)
			Insert into @days Select ConferenceDayReservationID from
			ConferenceDayReservations where ConferenceReservationID=@cnt
			Delete from ConferenceParticipants where ConferenceDayReservationID in
			(Select ConferenceDayReservationID from @days)
			Delete from WorkshopReservations where ConferenceDayReservationID in
			(Select ConferenceDayReservationID from @days)
			Declare @work_par table (WorkshopReservationID INT NOT NULL)
			Insert into @work_par Select WorkshopReservationID from WorkshopReservations
			where ConferenceDayReservationID in (Select ConferenceDayReservationID from @days)
			Delete from WorkshopParticipants where WorkshopReservationID in
			(Select WorkshopReservationID from @work_par)
			Delete from ConferenceDayReservations where ConferenceReservationID=@cnt
		End;
		Set @cnt = @cnt + 1
	End;
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error while deleting incorrect reservations: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Procedure AddPayment	
@ConferenceReservationID int,
@Price int
As 
Begin Try
	Declare @Res_price int = ((Select sum((1-ISNULL(Discount,0)*C.Price)) from ConferenceReservations as CR JOIN 
	ConferenceDayReservations as CDR on CR.ConferenceReservationID=CDR.ConferenceReservationID JOIN ConferenceDays as CD on 
	CDR.ConferenceDayID=CD.ConferenceDayID JOIN Conferences as C on C.ConferenceID=CD.ConferenceID 
	JOIN Prices as P on (C.ConferenceID=P.ConferenceID and CR.ReservationDate between P.StartDate and P.EndDate)
	where CDR.ConferenceReservationID=@ConferenceReservationID) + 
	(Select sum(W.Price) from ConferenceDayReservations as CDR JOIN WorkshopReservations as WR on 
	WR.ConferenceDayReservationID=CDR.ConferenceDayReservationID JOIN Workshops as W on
	W.WorkshopID=WR.WorkshopID where CDR.ConferenceReservationID=@ConferenceReservationID));
	If @Price >= @Res_price
	Begin 
		Update ConferenceReservations
		Set PaymentDate = GETDATE()
		Where ConferenceReservationID=@ConferenceReservationID
	End;
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding payment: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create procedure AddConferenceBooking
@ClientID int
As
Begin Try
	Insert into ConferenceReservations
	Values (@ClientID, getdate(), NULL)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding conference booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch 
Go

Create Type StudentIDList as table (ID int IDENTITY(1,1) Primary Key, StudentID int) Go


Create Procedure AddConferenceDayCompanyBooking
@ConferenceReservationID int,
@ConferenceDayID int,
@NumberOfParticipants int,
@NumberOfStudents int,
@StudentIDList StudentIDList READONLY
As
Begin Try
	Declare @free_places int = (Select top 1 ParticipantsLimit from ConferenceDayReservations as CDR JOIN ConferenceDays as CD on
	CD.ConferenceDayID=CDR.ConferenceDayID JOIN Conferences as C on C.ConferenceID=CD.ConferenceID)-
	(Select sum(NumberOfParticipants+NumberOfStudents) from ConferenceDayReservations Where ConferenceDayID=@ConferenceDayID);
	If (@NumberOfParticipants+@NumberOfStudents) > @free_places
	Begin
		RAISERROR('There is no enough places to book',16,1);
	END
	If (Select count(*) from @StudentIDList) != @NumberOfStudents
	Begin
		RAISERROR('The studentid count is incorrect!',16,1);
	End
	Insert into ConferenceDayReservations
	Values (@ConferenceReservationID,@ConferenceDayID,@NumberOfParticipants,
	@NumberOfStudents)
	Declare @cnt int = 0;
	Declare @ClientID int = (Select ClientID from ConferenceReservations where ConferenceReservationID=@ConferenceReservationID);
	Declare @ConferenceDayReservationID int = (Select max(ConferenceDayReservationID) from ConferenceDayReservations);
	While @cnt < @NumberOfParticipants+@NumberOfStudents
	Begin
		Insert into Person Values (NULL,NULL)
		Declare @PersonID int = (Select max(PersonID) from Person);
		Insert into CompanyEmployees Values (@PersonID,@ClientID)
		Declare @StudentID int = (Select StudentID from @StudentIDList Where ID=@cnt+1);
		Insert into ConferenceParticipants Values(@PersonID,@StudentID,@ConferenceDayReservationID)
		Set @cnt = @cnt + 1
	End
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding conference day booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch
Go

Create Procedure AddConferenceDayIndividualBooking
@ConferenceReservationID int,
@ConferenceDayID int,
@NumberOfParticipants int,
@NumberOfStudents int,
@StudentID int = NULL
As
Begin Try
	Declare @free_places int = (Select top 1 ParticipantsLimit from ConferenceDayReservations as CDR JOIN ConferenceDays as CD on
	CD.ConferenceDayID=CDR.ConferenceDayID JOIN Conferences as C on C.ConferenceID=CD.ConferenceID)-
	(Select sum(NumberOfParticipants+NumberOfStudents) from ConferenceDayReservations Where ConferenceDayID=@ConferenceDayID);
	If (@NumberOfParticipants+@NumberOfStudents) != 1
	Begin
		RAISERROR('This is not an individual booking',16,1);
	End
	If (@NumberOfParticipants+@NumberOfStudents) > @free_places
	Begin
		RAISERROR('There is no enough places to book',16,1);
	END
	Insert into ConferenceDayReservations
	Values (@ConferenceReservationID,@ConferenceDayID,@NumberOfParticipants,
	@NumberOfStudents)
	Declare @ClientID int = (Select ClientID from ConferenceReservations where ConferenceReservationID=@ConferenceReservationID);
	Declare @ConferenceDayReservationID int = (Select max(ConferenceDayReservationID) from ConferenceDayReservations);
	Insert into Person Values (NULL,NULL)
	Declare @PersonID int = (Select max(PersonID) from Person);
	Insert into PrivateClients Values (@PersonID,@ClientID)
	Insert into ConferenceParticipants Values(@PersonID,@StudentID,@ConferenceDayReservationID)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding conference day booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch
Go

CREATE PROCEDURE DeleteWorkshopReservation 
@WorkshopReservationID int
AS
Begin Try
	DECLARE @Participants TABLE (ParticipantID int);
	INSERT INTO @Participants (ParticipantID) SELECT ParticipantID FROM 
	WorkshopParticipants WHERE WorkshopReservationID=@WorkshopReservationID
	DELETE FROM WorkshopParticipants WHERE ParticipantID IN (SELECT * FROM @Participants)
	DELETE FROM WorkshopReservations WHERE WorkshopReservationID=@WorkshopReservationID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting workshop booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End CATCH
GO

CREATE PROCEDURE DeleteConferenceDayCompanyReservation 
@ConferenceDayReservationID int
AS
Begin Try
	DECLARE @Participants TABLE (ParticipantID int);
	INSERT INTO @Participants (ParticipantID) SELECT ParticipantID FROM 
	ConferenceParticipants WHERE ConferenceDayReservationID=@ConferenceDayReservationID
	DECLARE @Person TABLE (PersonID int);
	INSERT INTO @Person (PersonID) SELECT PersonID FROM 
	Person WHERE PersonID IN (SELECT * FROM @Participants)
	DELETE FROM CompanyEmployees WHERE PersonID IN (SELECT * FROM @Person)
	DELETE FROM WorkshopParticipants WHERE DayParticipantID IN (SELECT * FROM @Participants)
	DELETE FROM ConferenceParticipants WHERE ParticipantID IN (SELECT * FROM @Participants)
	DELETE FROM Person WHERE PersonID IN (SELECT * FROM @Person)
	DELETE FROM WorkshopReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID
	DELETE FROM ConferenceDayReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting conference day booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End CATCH
GO

CREATE PROCEDURE DeleteConferenceDayIndividualReservation 
@ConferenceDayReservationID int
AS
Begin Try
	DECLARE @Participants TABLE (ParticipantID int);
	INSERT INTO @Participants (ParticipantID) SELECT ParticipantID FROM 
	ConferenceParticipants WHERE ConferenceDayReservationID=@ConferenceDayReservationID
	DECLARE @Person TABLE (PersonID int);
	INSERT INTO @Person (PersonID) SELECT PersonID FROM 
	Person WHERE PersonID IN (SELECT * FROM @Participants)
	DELETE FROM PrivateClients WHERE PersonID IN (SELECT * FROM @Person)
	DELETE FROM WorkshopParticipants WHERE ParticipantID IN (SELECT * FROM @Participants)	
	DELETE FROM ConferenceParticipants WHERE ParticipantID IN (SELECT * FROM @Participants)
	DELETE FROM Person WHERE PersonID IN (SELECT * FROM @Person)
	DELETE FROM WorkshopReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID
	DELETE FROM ConferenceDayReservations WHERE ConferenceDayReservationID=@ConferenceDayReservationID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting conference day booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End CATCH
Go

CREATE PROCEDURE DeleteConferenceCompanyReservation
@ConferenceReservationID int
AS
Begin Try
	DECLARE @Days TABLE (ID int IDENTITY(1,1) PRIMARY KEY , ConferenceDayReservationID int);
	INSERT INTO @Days (ConferenceDayReservationID) SELECT ConferenceDayReservationID FROM 
	ConferenceDayReservations WHERE ConferenceReservationID = @ConferenceReservationID
	DECLARE @cnt int = 0;
	DECLARE @limit int = (SELECT COUNT(*) FROM @Days);
	WHILE @cnt < @limit
	BEGIN
		DECLARE @DayID int = (SELECT ConferenceDayReservationID FROM @Days WHERE ID=@cnt+1);
		EXEC DeleteConferenceDayCompanyReservation @DayID
		SET @cnt = @cnt + 1
	END
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting conference booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End CATCH
Go

CREATE PROCEDURE DeleteConferenceIndividualReservation
@ConferenceReservationID int
AS
Begin Try
	DECLARE @Days TABLE (ID int IDENTITY(1,1) PRIMARY KEY , ConferenceDayReservationID int);
	INSERT INTO @Days (ConferenceDayReservationID) SELECT ConferenceDayReservationID FROM 
	ConferenceDayReservations WHERE ConferenceReservationID = @ConferenceReservationID
	DECLARE @cnt int = 0;
	DECLARE @limit int = (SELECT COUNT(*) FROM @Days);
	WHILE @cnt < @limit
	BEGIN
		DECLARE @DayID int = (SELECT ConferenceDayReservationID FROM @Days WHERE ID=@cnt+1);
		EXEC DeleteConferenceDayIndividualReservation @DayID
		SET @cnt = @cnt + 1
	END
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when deleting conference booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End CATCH
Go

Create Procedure AddWorkshopBooking
@ConferenceDayReservationID int,
@WorkshopID int,
@NumberOfParticipants int
As
Begin Try
	Declare @free_places int = (Select ParticipantsLimit from Workshops where WorkshopID=@WorkshopID)-(
	Select sum(NumberOfParticipants) from WorkshopReservations where WorkshopID=@WorkshopID);
	If @NumberOfParticipants > @free_places
	Begin
		RAISERROR('There is no enough places to book',1,16);
	End
	Insert into WorkshopReservations
	Values (@WorkshopID,@ConferenceDayReservationID, @NumberOfParticipants)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when adding workshop booking: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch
Go

Create Procedure UpdatePerson
@PersonID int,
@FirstName varchar(30),
@LastName varchar(30)
As
Begin Try
	Update Person
	Set FirstName=@FirstName,
	LastName=@LastName
	Where PersonID=@PersonID
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error when updating person: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch
Go

Create Procedure AddConferenceDayParticipant
@ParticipantID int,
@ConferenceDayReservationID int,
@StudentID int = NULL
As
Begin Try
	DECLARE @participants TABLE (ParticipantID int);
	INSERT INTO @participants SELECT ParticipantID FROM ConferenceParticipants WHERE ConferenceDayReservationID=@ConferenceDayReservationID
	IF @ParticipantID IN (SELECT * FROM @participants)
	BEGIN
		RAISERROR('This participant is already registered',16,1)
	END
	DECLARE @dates TABLE (id int IDENTITY(1,1) PRIMARY KEY, sdate datetime, edate datetime);
	INSERT INTO @dates SELECT StartDate, EndDate FROM Conferences AS C JOIN ConferenceDays AS CD ON CD.ConferenceID=C.ConferenceID JOIN 
	ConferenceDayReservations AS CDR ON CDR.ConferenceDayID=CD.ConferenceDayID
			JOIN ConferenceParticipants AS CP ON CP.ConferenceDayReservationID=CDR.ConferenceDayReservationID WHERE CP.ParticipantID=@ParticipantID
	DECLARE @cnt int = 0;
	DECLARE @dcount int = (SELECT COUNT(*) FROM @dates);
	DECLARE @thisdate datetime = (SELECT TOP 1 StartDate FROM Conferences AS C JOIN ConferenceDays AS CD ON CD.ConferenceID=C.ConferenceID JOIN 
	ConferenceDayReservations AS CDR ON CDR.ConferenceDayID=CD.ConferenceDayID WHERE @ConferenceDayReservationID=CDR.ConferenceDayReservationID);
	WHILE @cnt < @dcount
	BEGIN
		DECLARE @sdate datetime = (SELECT sdate FROM @dates WHERE id = @cnt + 1);
		DECLARE @edate datetime = (SELECT edate FROM @dates WHERE id = @cnt + 1);
		IF DATEPART(DAY,@sdate)=DATEPART(DAY,@thisdate) AND DATEPART(MONTH,@sdate)=DATEPART(MONTH,@thisdate) AND DATEPART(HOUR,@thisdate) BETWEEN DATEPART(HOUR,@sdate) AND DATEPART(HOUR,@edate)
		BEGIN
			RAISERROR('This participant is already registered on conference day in this same time',16,1)
		END
		SET @cnt = @cnt + 1
	END
	IF @StudentID IS NOT NULL
	BEGIN
		UPDATE dbo.ConferenceDayReservations
		SET NumberOfStudents = NumberOfStudents + 1
		WHERE @ConferenceDayReservationID = ConferenceDayReservationID
	END
    IF @StudentID IS NULL
	BEGIN
		UPDATE dbo.ConferenceDayReservations
		SET NumberOfParticipants = NumberOfParticipants + 1
		WHERE @ConferenceDayReservationID = ConferenceDayReservationID
	END
END TRY
BEGIN CATCH
	DECLARE @errorMessage NVARCHAR(1024);
	SET @errorMessage = 'Error adding conference participant: \n' + ERROR_MESSAGE();
	THROW 52000, @errorMessage, 1;
END CATCH
Go

Create Procedure AddWorkshopParticipant
@ParticipantID int,
@WorkshopReservationID int
As
Begin Try
	DECLARE @participants TABLE (ParticipantID int);
	INSERT INTO @participants SELECT DayParticipantID FROM WorkshopParticipants WHERE WorkshopReservationID=@WorkshopReservationID
	IF @ParticipantID IN (SELECT * FROM @participants)
	BEGIN
		RAISERROR('This participant is already registered',16,1)
	END
	DECLARE @dates TABLE (id int IDENTITY(1,1) PRIMARY KEY, sdate datetime, edate datetime);
	INSERT INTO @dates SELECT StartDate, EndDate FROM Workshops AS W JOIN WorkshopReservations AS WR ON WR.WorkshopID=W.WorkshopID
			JOIN WorkshopParticipants AS WP ON WP.WorkshopReservationID=WR.WorkshopReservationID WHERE WP.DayParticipantID=@ParticipantID
	DECLARE @cnt int = 0;
	DECLARE @dcount int = (SELECT COUNT(*) FROM @dates);
	DECLARE @thisdate datetime = (SELECT TOP 1 StartDate FROM Workshops AS W JOIN WorkshopReservations AS WR ON WR.WorkshopID=W.WorkshopID WHERE WorkshopReservationID=@WorkshopReservationID);
	WHILE @cnt < @dcount
	BEGIN
		DECLARE @sdate datetime = (SELECT sdate FROM @dates WHERE id = @cnt + 1);
		DECLARE @edate datetime = (SELECT edate FROM @dates WHERE id = @cnt + 1);
		IF DATEPART(DAY,@sdate)=DATEPART(DAY,@thisdate) AND DATEPART(MONTH,@sdate)=DATEPART(MONTH,@thisdate)
		BEGIN
			RAISERROR('This participant is already registered on workshop in this same time',16,1)
		END
		SET @cnt = @cnt + 1
	END
	INSERT INTO WorkshopParticipants VALUES (@ParticipantID,@WorkshopReservationID)
End Try
Begin Catch
	Declare @errorMessage nvarchar(1024);
	Set @errorMessage = 'Error adding workshop participant: \n' + ERROR_MESSAGE();
	throw 52000, @errorMessage, 1;
End Catch
Go

-- skrypt na dni konferencji
DECLARE @ConferenceID INT = 80;
WHILE @ConferenceID <= (SELECT COUNT(*) FROM Conferences)
BEGIN
	DECLARE @sdate DATETIME = (SELECT StartDate FROM Conferences WHERE @ConferenceID=ConferenceID);
	DECLARE @edate DATETIME = (SELECT EndDate FROM Conferences WHERE @ConferenceID=ConferenceID);
	DECLARE @days INT = (SELECT DATEDIFF(DAY,@sdate,@edate)) + 1;
	DECLARE @cnt INT = 0;
	WHILE @cnt < @days
	BEGIN
		INSERT INTO dbo.ConferenceDays VALUES (@ConferenceID)
		SET @cnt = @cnt + 1
	END
	SET @ConferenceID = @ConferenceID + 1
END

-- skrypt poprawiajacy daty warsztatów
DECLARE @WorkshopID INT = 1;
WHILE @WorkshopID <= (SELECT COUNT(*) FROM dbo.Workshops)
BEGIN
	DECLARE @ConferenceDayID INT = (SELECT ConferenceDayID FROM dbo.Workshops WHERE @WorkshopID=WorkshopID);
	DECLARE @ConferenceID INT = (SELECT ConferenceID FROM dbo.ConferenceDays WHERE ConferenceDayID=@ConferenceDayID);
	DECLARE @firstday DATETIME = (SELECT StartDate FROM Conferences WHERE ConferenceID=@ConferenceID);
	DECLARE @FirstConferenceDayID INT = (SELECT TOP 1 ConferenceDayID FROM dbo.ConferenceDays WHERE ConferenceID=@ConferenceID ORDER BY 1);
	DECLARE @DayDiff INT = @ConferenceDayID - @FirstConferenceDayID;
	DECLARE @RightDate DATETIME = DATEADD(DAY,@DayDiff,@firstday);
	SET @RightDate = DATEADD(HOUR,(SELECT DATEPART(HOUR,(SELECT StartDate FROM dbo.Workshops WHERE WorkshopID=@WorkshopID)))-
		(SELECT DATEPART(HOUR,@RightDate)),@RightDate);
	DECLARE @EndRightDate DATETIME = DATEADD(HOUR,2,@RightDate);
	UPDATE dbo.Workshops
	SET StartDate = @RightDate, EndDate = @EndRightDate
	WHERE WorkshopID = @WorkshopID;
	SET @WorkshopID = @WorkshopID + 1
END

SELECT SUM(NumberOfParticipants+NumberOfStudents) FROM dbo.ConferenceDayReservations

-- skrypt dodajacy uczestnikow dni konferencji, person utworzone wczesniej
DECLARE @ConferenceDayReservationID INT = 1;
DECLARE @PersonID INT = 1;
WHILE @ConferenceDayReservationID <= (SELECT COUNT(*) FROM dbo.ConferenceDayReservations)
BEGIN
	DECLARE @NumberOfParticipants INT = (SELECT NumberOfParticipants FROM dbo.ConferenceDayReservations 
		WHERE @ConferenceDayReservationID=ConferenceDayReservationID);
	DECLARE @NumberOfStudents INT = (SELECT NumberOfStudents FROM dbo.ConferenceDayReservations 
	WHERE @ConferenceDayReservationID=ConferenceDayReservationID);
	DECLARE @cnt INT = 0;
	WHILE @cnt < @NumberOfParticipants
	BEGIN
		INSERT INTO ConferenceParticipants VALUES (@PersonID,NULL,@ConferenceDayReservationID)
		SET @PersonID = @PersonID + 1
		SET @cnt = @cnt + 1
	END
	SET @cnt = 0;
	WHILE @cnt < @NumberOfStudents
	BEGIN
		INSERT INTO ConferenceParticipants VALUES (@PersonID,(SELECT FLOOR(RAND()*(999999-100000))+100000),@ConferenceDayReservationID)
		SET @PersonID = @PersonID + 1
		SET @cnt = @cnt + 1
	END
	SET @ConferenceDayReservationID = @ConferenceDayReservationID + 1;
END

-- skrypt dodajacy klientów firmowych
DECLARE @CompClients TABLE (ID INT IDENTITY(1,1) PRIMARY KEY, CompanyID INT );
INSERT INTO @CompClients SELECT CompanyID FROM Companies
DECLARE @ID INT = 1;
DECLARE @PersonID INT = 1;
WHILE @ID <= (SELECT COUNT(*) FROM Companies)
BEGIN
	DECLARE @CompanyID INT = (SELECT CompanyID FROM @CompClients WHERE ID=@ID);
	DECLARE @Number INT = (SELECT SUM(CDR.NumberOfParticipants+CDr.NumberOfStudents) FROM dbo.Companies AS Co
	JOIN dbo.Clients AS C ON C.ClientID = Co.CompanyID 
	JOIN dbo.ConferenceReservations AS CR ON CR.ClientID = C.ClientID
	JOIN dbo.ConferenceDayReservations AS CDR ON CDR.ConferenceReservationID = CR.ConferenceReservationID
	WHERE C.ClientID=@CompanyID);
	DECLARE @cnt INT = 0;
	WHILE @cnt < @Number
	BEGIN
		INSERT INTO CompanyEmployees VALUES (@PersonID,@CompanyID)
		SET @PersonID = @PersonID + 1
		SET @cnt = @cnt + 1
	END
	SET @ID = @ID + 1;
END

-- skrypt dodajacy klientów indywidualnych
DECLARE @IndClients TABLE (ID INT IDENTITY(1,1) PRIMARY KEY, ClientID INT );
INSERT INTO @IndClients SELECT ClientID FROM Clients INTERSECT SELECT CompanyID FROM Companies
DECLARE @ID INT = 1;
DECLARE @PersonID INT = 19191;
WHILE @ID <= (SELECT COUNT(*) FROM @IndClients)
BEGIN
	DECLARE @ClientID INT = (SELECT ClientID FROM @IndClients WHERE ID=@ID);
	DECLARE @Number INT = (SELECT SUM(CDR.NumberOfParticipants+CDr.NumberOfStudents) from dbo.Clients AS C
	JOIN dbo.ConferenceReservations AS CR ON CR.ClientID = C.ClientID
	JOIN dbo.ConferenceDayReservations AS CDR ON CDR.ConferenceReservationID = CR.ConferenceReservationID 
	WHERE C.ClientID=@ClientID);
	DECLARE @cnt INT = 0;
	WHILE @cnt < @Number
	BEGIN
		INSERT INTO PrivateClients VALUES (@PersonID,@ClientID)
		SET @PersonID = @PersonID + 1
		SET @cnt = @cnt + 1
	END
	SET @ID = @ID + 1;
END

-- skrypt dodajacy uczestnikow warsztatow
DECLARE @WorkshopReservationID INT = 1;
DECLARE @DayParticipantID INT = 1;
WHILE @WorkshopReservationID <= (SELECT COUNT(*) FROM dbo.WorkshopReservations)
BEGIN
	DECLARE @ConferenceDayReservationID INT = (SELECT ConferenceDayReservationID FROM dbo.WorkshopReservations
	WHERE WorkshopReservationID=@WorkshopReservationID);
    DECLARE @DayParticipants TABLE (ID INT IDENTITY(1,1) PRIMARY KEY, ParticipantID INT);
	INSERT INTO @DayParticipants SELECT ParticipantID FROM dbo.ConferenceDayReservations AS CDR 
	JOIN dbo.ConferenceParticipants AS CP ON CP.ConferenceDayReservationID = CDR.ConferenceDayReservationID 
	WHERE CDR.ConferenceDayReservationID=@ConferenceDayReservationID;
	DECLARE @Number INT = (SELECT NumberOfParticipants FROM dbo.WorkshopReservations 
	WHERE WorkshopReservationID=@WorkshopReservationID);
	DECLARE @cnt INT = 0;
	WHILE @cnt < @Number
	BEGIN
		DECLARE @ParticipantID INT = (SELECT ParticipantID FROM @DayParticipants WHERE ID=@DayParticipantID);
	    INSERT INTO WorkshopParticipants VALUES (@ParticipantID,@WorkshopReservationID)
		SET @DayParticipantID = @DayParticipantID + 1
		SET @cnt = @cnt + 1
	END
	SET @WorkshopReservationID = @WorkshopReservationID + 1
END

-- skrypt naprawa progów cenowych
DECLARE @PriceID INT = 1;
DECLARE @Count INT = (SELECT COUNT(*) FROM Prices)
WHILE @PriceID <= @Count
BEGIN
    DECLARE @CDate DATETIME = (SELECT C.StartDate FROM Conferences AS C JOIN dbo.Prices AS P
	ON P.ConferenceID = C.ConferenceID WHERE @PriceID=PriceID); 
	DECLARE @EDate DATETIME = (SELECT EndDate FROM Prices WHERE @PriceID=PriceID);
	IF @CDate < @EDate
	BEGIN
		DELETE FROM Prices WHERE PriceID=@PriceID
	END
	SET @PriceID = @PriceID + 1
END

-- indeksy

CREATE INDEX idx_Countries
ON Countries (CountryName)
GO

CREATE INDEX idx_Cities
ON Cities (CityName)
GO

CREATE INDEX idx_Clients
ON Clients (ClientID)
GO

CREATE INDEX idx_Person
ON Person (FirstName, LastName)
GO

CREATE INDEX idx_ConferenceReservations
ON ConferenceReservations (ConferenceReservationID)
GO

CREATE INDEX idx_ConferenceDayReservations
ON ConferenceDayReservations (ConferenceDayReservationID)
GO

CREATE INDEX idx_ConferenceParticipants
ON ConferenceParticipants (ParticipantID)
GO

CREATE INDEX idx_WorkshopReservations
ON WorkshopReservations (WorkshopReservationID)
GO

CREATE INDEX idx_ConferenceDays
ON ConferenceDays (ConferenceDayID,ConferenceID)
GO

CREATE INDEX idx_Workshops
ON Workshops (WorkshopID)
GO

CREATE INDEX idx_Conferences
ON Conferences (ConferenceID)
GO

CREATE INDEX idx_WorkshopDetails
ON WorkshopDetails (WorkshopDetailsID)
GO

CREATE INDEX idx_Prices
ON Prices (PriceID,ConferenceID)
GO

use u_bplewnia

--dziala
CREATE FUNCTION AvailableConferenceDayNumberOfPlaces 
	(
	@ConferenceDayID INT
	)
	Returns INT
	AS
BEGIN
Return
	(
	select c.ParticipantsLimit - (sum(cdr.NumberOfParticipants)+ sum(cdr.NumberOfStudents))
	from Conferences as c
	inner join ConferenceDays as cd on cd.ConferenceID = c.ConferenceID
	inner join ConferenceDayReservations as cdr on cdr.ConferenceDayID = cd.ConferenceDayID
	where cdr.ConferenceDayID = @ConferenceDayID
	group by c.ParticipantsLimit
	)
END
GO


--dziala
CREATE FUNCTION AvailableWorkshopNumberOfPlaces
	(
	@WorkshopID INT
	)
	Returns INT
	AS
BEGIN
Return
	(
	select (w.ParticipantsLimit - sum(wr.NumberOfParticipants))
	from Workshops as w
	inner join WorkshopReservations as wr on wr.WorkshopID = w.WorkshopID
	where w.WorkshopID = @WorkshopID
	group by w.WorkshopID, w.ParticipantsLimit
	)
END
GO

--dziala
CREATE FUNCTION DaysOfConference 
	(
	@ConferenceID INT
	)
	Returns TABLE
	AS
Return
	(
	select cd.ConferenceDayID, c.ParticipantsLimit 
	from Conferences as c
	inner join ConferenceDays as cd on cd.ConferenceID = c.ConferenceID
	where c.ConferenceID = @ConferenceID
	)
GO

--dziala
CREATE FUNCTION WorkshopStartDate
	(
	@WorkshopID INT
	)
	Returns datetime
	AS
BEGIN
Return
	(
	select w.StartDate
	from Workshops as w
	where w.WorkshopID = @WorkshopID
	)
END
GO

--dziala
CREATE FUNCTION WorkshopEndDate
	(
	@WorkshopID INT
	)
	Returns datetime
	AS
BEGIN
Return
	(
	select w.EndDate
	from Workshops as w
	where w.WorkshopID = @WorkshopID
	)
END
GO

--dziala
CREATE FUNCTION ConferencePriceThresholds
	(
	@ConferenceID INT
	)
	Returns table
	AS
Return
	(
	select p.PriceID, p.StartDate, p.EndDate, p.Discount
	from Prices as p
	inner join Conferences as c on c.ConferenceID = p.ConferenceID
	where c.ConferenceID = 2
	)
GO

--dziala
CREATE FUNCTION DoWorkshopsOverlap
	(
	@Workshop1ID INT,
	@Workshop2ID INT
	)
	Returns bit
	AS
BEGIN
	DECLARE @Start_1 datetime = [dbo].[WorkshopStartDate] ( @Workshop1ID ) ;
	DECLARE @End_1 datetime = [dbo].[WorkshopEndDate] ( @Workshop1ID) ;
	DECLARE @Start_2 datetime = [dbo].[WorkshopStartDate] ( @Workshop2ID ) ;
	DECLARE @End_2 datetime = [dbo].[WorkshopEndDate] ( @Workshop2ID ) ;

	IF @Start_1 < @Start_2 AND @Start_2 < @End_1
		RETURN 1
	IF @Start_2 < @Start_1 AND @Start_1 < @End_2
		RETURN 1
	IF @Start_1 >= @Start_2 AND @End_2 >= @End_1
		RETURN 1
	IF @Start_2 >= @Start_1 AND @End_1 >= @End_2
		RETURN 1
	RETURN 0
END
GO


--dziala
CREATE FUNCTION BookingDaysCost
	(
	@ConferenceReservationID INT
	)
	Returns money
	AS
BEGIN
Return
	(
	select SUM(c.Price*(1 - ISNULL(c.StudentDiscount,0))*cdr.NumberOfStudents + c.Price*cdr.NumberOfParticipants ) --NumberOfParticipants to wszyscy uczestnicy
	from ConferenceDayReservations as cdr
	inner join ConferenceDays as cd on cd.ConferenceDayID = cdr.ConferenceDayID
	inner join Conferences as c on c.ConferenceID = cd.ConferenceID
	where cdr.ConferenceReservationID = @ConferenceReservationID
	group by cdr.ConferenceReservationID
	)
END
GO

--mysle, ¿e dziala, brak danych
CREATE FUNCTION BookingWorkshopsCost
	(
	@WorkshopReservationID INT
	)
	Returns money
	AS
BEGIN
Return
	(
	select wr.NumberOfParticipants*w.Price
	from WorkshopReservations as wr
	inner join Workshops as w on wr.WorkshopID = w.WorkshopID
	where wr.WorkshopReservationID = @WorkshopReservationID
	)
END
GO


--mysle, ze dziala
CREATE FUNCTION BookingCost
	(
	@WorkshopReservationID INT,
	@ConferenceReservationID INT
	)
	Returns money
	AS
BEGIN
DECLARE @BookingDaysCost money = dbo.BookingDaysCost ( @ConferenceReservationID );
DECLARE @BookingWorkshopsCost money = dbo.BookingWorkshopsCost ( @ConferenceReservationID );
RETURN (@BookingDaysCost + @BookingWorkshopsCost)
END
GO

--dziala
CREATE FUNCTION ConferenceParticipantsList
	(
	@ConferenceID INT
	)
	Returns table
	AS
Return
	(
	select cp.ParticipantID, p.FirstName, p.LastName
	from Conferences as c
	inner join ConferenceDays as cd on cd.ConferenceID = c.ConferenceID
	inner join ConferenceDayReservations as cdr on cdr.ConferenceDayID = cd.ConferenceDayID
	inner join ConferenceParticipants as cp on cp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	inner join Person as p on p.PersonID = cp.PersonID
	where c.ConferenceID = @ConferenceID
	)
GO

--dziala
CREATE FUNCTION ConferenceDayParticipantsList
	(
	@ConferenceDayID INT
	)
	Returns table
	AS
Return
	(
	select cp.ParticipantID, p.FirstName, p.LastName
	from ConferenceDays as cd
	inner join ConferenceDayReservations as cdr on cdr.ConferenceDayID = cd.ConferenceDayID
	inner join ConferenceParticipants as cp on cp.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	inner join Person as p on p.PersonID = cp.PersonID
	where cd.ConferenceDayID = @ConferenceDayID
	)
GO

--dziala
CREATE FUNCTION WorkshopParticipantsList
	(
	@WorkshopID INT
	)
	Returns table
	AS
Return
	(
	select cp.ParticipantID, p.FirstName, p.LastName
	from Workshops as w
	inner join WorkshopReservations as wr on wr.WorkshopID = w.WorkshopID
	inner join WorkshopParticipants as wp on wp.WorkshopReservationID = wr.WorkshopReservationID
	inner join ConferenceParticipants as cp on cp.ParticipantID = wp.ParticipantID
	inner join Person as p on p.PersonID = cp.PersonID
	where w.WorkshopID = @WorkshopID
	)
GO

--dziala
CREATE FUNCTION ParticipantsConferencesList
	(
	@ParticipantID INT
	)
	Returns table
	AS
Return
	(
	select c.ConferenceID, c.ConferenceName
	from ConferenceParticipants as cp
	inner join ConferenceDayReservations as cdr on cdr.ConferenceDayReservationID = cp.ConferenceDayReservationID
	inner join ConferenceDays as cd on cd.ConferenceDayID = cdr.ConferenceDayID
	inner join Conferences as c on c.ConferenceID = cd.ConferenceID
	where cp.ParticipantID = @ParticipantID
	group by c.ConferenceID, c.ConferenceName
	)
GO

--dziala
CREATE FUNCTION ParticipantsWorkshopsList
	(
	@ParticipantID INT
	)
	Returns table
	AS
Return
	(
	select w.WorkshopID, wd.Work	shopName
	from ConferenceParticipants as cp
	inner join WorkshopParticipants as wp on wp.ParticipantID = cp.ParticipantID
	inner join WorkshopReservations as wr on wr.WorkshopReservationID = wp.WorkshopReservationID
	inner join Workshops as w on w.WorkshopID = wr.WorkshopID
	inner join WorkshopDetails as wd on wd.WorkshopDetailsID = w.WorkshopDetailsID
	where cp.ParticipantID = @ParticipantID
	group by w.WorkshopID, wd.WorkshopName
	)
GO


--dodatkowa
CREATE FUNCTION TotalCostOfReservation 
	(
	@ConferenceReservationID INT
	)
	Returns money
	AS
BEGIN

	declare @WorkshopCost money = (select sum(w.Price*wr.NumberOfParticipants)
	from ConferenceDayReservations as cdr 
	inner join WorkshopReservations as wr on wr.ConferenceDayReservationID = cdr.ConferenceDayReservationID
	inner join Workshops as w on w.WorkshopID = wr.WorkshopID
	where cdr.ConferenceReservationID = @ConferenceReservationID)

	declare @ConferenceCost money = (select SUM(c.Price*(1 - ISNULL(c.StudentDiscount,0))*cdr.NumberOfStudents + c.Price*cdr.NumberOfParticipants )
		from ConferenceDayReservations as cdr
		inner join ConferenceDays as cd on cd.ConferenceDayID = cdr.ConferenceDayID
		inner join Conferences as c on c.ConferenceID = cd.ConferenceID
		where cdr.ConferenceReservationID = @ConferenceReservationID)
Return
	(
		(@WorkshopCost + @ConferenceCost)
	)
END
GO







--dziala
CREATE TRIGGER [dbo].[TooFewFreePlacesForConferenceDay]
 on [dbo].[ConferenceDayReservations]
 AFTER INSERT
 AS
 BEGIN
 SET NOCOUNT ON;
 IF EXISTS
 (
 SELECT * FROM inserted AS i
 WHERE dbo.AvailableConferenceDayNumberOfPlaces(i.ConferenceDayID ) < 0
 )
 BEGIN
; THROW 50001 , 'Too few free places to book day' ,1
 END
 END
 GO --dziala CREATE TRIGGER [dbo].[TooFewFreePlacesForWorkshop]
 on [dbo].[WorkshopReservations]
 AFTER INSERT
 AS
 BEGIN
 SET NOCOUNT ON;
 IF EXISTS
 (
 SELECT * FROM inserted AS i
 WHERE dbo.AvailableWorkshopNumberOfPlaces(i. WorkshopID ) < 0
 )
 BEGIN
; THROW 50001 , 'Too few free places to book Workshop' ,1
 END
 END
 GO



 --dziala
 CREATE TRIGGER [dbo].[LessPlacesBookedForDayThanForWorkshop]
 ON [dbo].[WorkshopReservations]
 AFTER INSERT
 AS
 BEGIN

 SET NOCOUNT ON;
 IF EXISTS
 (
 SELECT * FROM inserted AS i
 JOIN ConferenceDayReservations AS cdr ON cdr.ConferenceDayReservationID = i.ConferenceDayReservationID
 WHERE cdr.NumberOfParticipants + cdr.NumberOfStudents
 < i.NumberOfParticipants
 )
 BEGIN
 ; THROW 50001 , 'Cannot book Workshop since your Conference Day Reservation has less places booked' ,1
 END
END
GO--dzialaCREATE TRIGGER [dbo].[BookingWorkshopInDifferentDay]
 ON [dbo].[WorkshopReservations]
 AFTER INSERT
 AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS
 (
 select *
 from inserted as i
 join Workshops as w on w.WorkshopID = i.WorkshopID
 join ConferenceDays as cd1 on cd1.ConferenceDayID = w.ConferenceDayID
 join ConferenceDayReservations as cdr on cdr.ConferenceDayReservationID = i.ConferenceDayReservationID
 join ConferenceDays as cd2 on cd2.ConferenceDayID = cdr.ConferenceDayID
 where cd1.ConferenceDayID <> cd2.ConferenceDayID
 )
 BEGIN
 ; THROW 50001 , 'Booking workshop from different day than day booking is for' ,1
 END 
END
GO--dzialaCREATE TRIGGER [dbo].[ConferenceDayHasLessPlacesThanWorkshop]
 ON [dbo].[Workshops]
 AFTER INSERT
 AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS
 (
	select * 
	from inserted as i 	join ConferenceDays as cd on cd.ConferenceDayID = i.ConferenceDayID	join Conferences as c on c.ConferenceID = cd.ConferenceID
	where i.ParticipantsLimit > c.ParticipantsLimit
 )
 BEGIN
 ; THROW 50001 , 'You can not create Workshop with more places than for a Conference Day' ,1
 END 
END
GO


CREATE TRIGGER ParticipantReservatingOverlappingWorkshop
ON [dbo].[WorkshopReservations]
AFTER INSERT
AS
BEGIN
SET NOCOUNT ON;
IF EXISTS
(
SELECT * FROM inserted AS i
inner join WorkshopParticipants as wp on wp.WorkshopReservationID = i.WorkshopReservationID
cross apply dbo.ParticipantsWorkshopsList(wp.ParticipantID) as w
where dbo.DoWorkshopsOverlap (i.WorkshopID,w.WorkshopID) = 1 and w.WorkshopID <> i.WorkshopID
)
BEGIN
; THROW 50001 , 'Workshops you are trying to book overlap' ,1
END
END
GO




