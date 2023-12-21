-- Phase 2, Group 17: Evan Lutz (ewlutz), John Diamond(jydiamond)
-- Part 1 -----------------------------


DROP TABLE StayIn;

DROP TABLE Examine;

DROP TABLE Admission;

DROP TABLE Patient;

DROP TABLE Equipment;

DROP TABLE RoomAccess;

DROP TABLE RoomService;

DROP TABLE Room;

DROP TABLE CanRepairEquipment;

DROP TABLE EquipmentType;

DROP TABLE EquipmentTechnician;

DROP TABLE Doctor;

DROP TABLE Employee;


CREATE TABLE Employee(
    empID Integer PRIMARY KEY,
    FNAME VARCHAR(255),
    LNAME VARCHAR(255),
    Salary Float,
    jobTitle VARCHAR(255),
    OfficeNum Integer,
    empRank Integer,
    supervisorID Integer,
    AddressStreet VARCHAR(255),
    AddressCity VARCHAR(255),
    AddressZip VARCHAR(255),
    FOREIGN KEY (supervisorID) REFERENCES Employee(empID)
);

CREATE TABLE Doctor(
    EmployeeID Integer PRIMARY KEY,
    gender VARCHAR(255),
    specialty VARCHAR(255),
    GraduatedFrom VARCHAR(255),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID)
);

CREATE TABLE EquipmentTechnician(
    EmployeeID Integer PRIMARY KEY,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID)
);

CREATE TABLE EquipmentType(
    equipID VARCHAR(255) PRIMARY KEY,
    equipDesc VarCHAR(255),
    equipModel VARCHAR(255),
    instructions VARCHAR(255),
    NumberOfUnits Integer
);

CREATE TABLE CanRepairEquipment(
    EmployeeID Integer,
    EquipmentType VARCHAR(255),
    PRIMARY KEY (EmployeeID, EquipmentType),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(empID),
    FOREIGN KEY (EquipmentType) REFERENCES EquipmentType(equipID)
);

CREATE TABLE Room(
    rNum Integer PRIMARY KEY,
    occupied CHAR(1)
);

CREATE TABLE RoomService(
    roomNum Integer,
    roomService VARCHAR(255),
    FOREIGN KEY (roomNum) REFERENCES Room(rNum),
    PRIMARY KEY (roomNum, roomService)
);

CREATE TABLE RoomAccess(
    roomNum Integer,
    EmpID Integer,
    FOREIGN KEY (roomNum) REFERENCES Room(rNum),
    FOREIGN KEY (EmpID) REFERENCES Employee(empID),
    PRIMARY KEY (roomNum, EmpID)
);

CREATE TABLE Equipment(
    SerialNumb VARCHAR(255),
    TypeID VARCHAR(255),
    PurchaseYear Integer,
    LastInspection DATE,
    roomNum Integer,
    PRIMARY KEY (SerialNumb),
    FOREIGN KEY (TypeID) REFERENCES EquipmentType(equipID),
    FOREIGN KEY (roomNum) REFERENCES Room(rNum)
);

CREATE TABLE Patient(
    SSN INTEGER PRIMARY KEY,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Address VARCHAR(255),
    TelNum Integer
);

CREATE TABLE Admission(
    admissionNum Integer PRIMARY KEY,
    AdmissionDate DATE,
    LeaveDate DATE,
    TotalPayment Decimal(10, 2),
    InsurancePayment Decimal(10, 2),
    Patient_SSN Integer,
    FutureVisit DATE,       -- A patient may make a future appointment when they are admitted
    FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)
);

CREATE TABLE Examine(
    DoctorID Integer,
    AdmissionNum Integer,
    ExamineComment VARCHAR(255),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(EmployeeID),
    FOREIGN KEY (AdmissionNum) REFERENCES Admission(admissionNum),
    PRIMARY KEY (DoctorID, AdmissionNum)
);

CREATE TABLE StayIn(
    AdmissionNum Integer,
    RoomNum Integer,
    startDate Date,
    endDate Date,
    FOREIGN KEY (AdmissionNum) REFERENCES Admission(admissionNum),
    FOREIGN KEY (RoomNum) REFERENCES Room(rNum),
    PRIMARY KEY (AdmissionNum, RoomNum, startDate)
);


-- Phase 3,  Part 2 ----------------------------------------------

-- Question 1 -------------


CREATE OR REPLACE TRIGGER IsICUPatient
BEFORE INSERT OR UPDATE ON Examine
FOR EACH ROW
DECLARE
    v_ICU_Count NUMBER;
BEGIN
    -- Count the number of ICU stays for the given AdmissionNum
    SELECT COUNT(*)
    INTO v_ICU_Count
    FROM StayIn si, RoomService rs
    WHERE si.roomNum = rs.roomNum
      AND rs.roomService = 'ICU'
      AND si.AdmissionNum = :NEW.AdmissionNum;
    -- Check if ExamineComment is empty or NULL and the patient is in the ICU
    IF (:NEW.ExamineComment = '' OR :NEW.ExamineComment IS NULL) AND v_ICU_Count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'A doctor must leave a note if the patient is in the ICU');
    END IF;
END;
/


-- Question 2 -------------


CREATE OR REPLACE TRIGGER CalculateInsurancePayment
BEFORE INSERT OR UPDATE ON Admission
FOR EACH ROW
BEGIN
    IF :NEW.InsurancePayment <> (:NEW.TotalPayment * 0.65) THEN
        :NEW.InsurancePayment := :NEW.TotalPayment * 0.65;
    END IF;
END;
/


-- Question 3 and 4 -------------


/*CREATE OR REPLACE TRIGGER HasCorrectManager
BEFORE INSERT OR UPDATE ON Employee
FOR EACH ROW
DECLARE
    v_SupervisorRank INTEGER;
BEGIN
    -- EmpRank must be less than or equal to 2
    IF (:NEW.empRank > 2) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid empRank');
    END IF;
    
    -- If EmpRank = 2, they CANNOT have a supervisor
    IF (:NEW.empRank = 2 AND :NEW.supervisorID IS NOT NULL) THEN
        RAISE_APPLICATION_ERROR(-20002, 'GMs cannot have a manager');
    END IF;
    
    -- If EmpRank < 2, they MUST have a supervisor
    IF (:NEW.empRank < 2 AND :NEW.supervisorID IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Regular Employees & Division Managers must have managers');
    END IF;
    -- Attempt to retrieve the supervisor's rank
    IF :NEW.supervisorID IS NOT NULL THEN
        BEGIN
            SELECT empRank INTO v_SupervisorRank
            FROM Employee
            WHERE empID = :NEW.supervisorID;
            -- Supervisor emprank must equal the employee's ++1
            IF (:NEW.empRank < 2 AND (:NEW.empRank + 1) <> v_SupervisorRank) THEN
                RAISE_APPLICATION_ERROR(-20001, 'An employee must have a manager directly 1 rank above them unless it is a General Manager, or a GM cannot have a supervisor');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Handle the case when no data is found
                NULL;
        END;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Handle other exceptions here if needed
        NULL;
END;
/
*/


-- General Manager

/*
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (22, 'Test', 'HasCorrectManager', 0, 'GlobalManager', 101, 0, 7, '44 Redline Street', 'Cleveland', 28321);
 
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (23, 'Test2', 'IsValudEmpRank', 0, 'GlobalManager', 101, 3, NULL, '44 Redline Street', 'Cleveland', 28321);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (24, 'Test2', 'IsValudEmpRan2k', 0, 'GlobalManager', 101, 2, NULL, '44 Redline Street', 'Cleveland', 28321);
 
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (25, 'Test3', 'IsValudEmpRan2k', 0, 'GlobalManager', 101, 0, NULL, '44 Redline Street', 'Cleveland', 28321);
 
DELETE FROM Employee
WHERE empID = 25;
*/

-- Question 5 -------------


CREATE OR REPLACE TRIGGER EMCVisit
BEFORE INSERT ON StayIn
FOR EACH ROW
DECLARE
    v_IsEMCRoom INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_IsEMCRoom
    FROM RoomService rs
    WHERE rs.roomService = 'Emergency Service' AND :NEW.RoomNum = rs.roomNum;
    IF v_IsEMCRoom > 0 THEN
        UPDATE Admission
        SET FutureVisit = ADD_MONTHS(SYSDATE, 2)
        WHERE admissionNum = :NEW.AdmissionNum;
    END IF;
END;
/


-- Question 6 -------------


CREATE OR REPLACE TRIGGER NewEquipment
BEFORE INSERT ON Equipment
FOR EACH ROW
DECLARE
    v_IsTechnician INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_IsTechnician
    FROM CanRepairEquipment cre
    WHERE :NEW.TypeID = cre.EquipmentType;
    IF v_IsTechnician > 0 THEN
        :NEW.LastInspection := SYSDATE;
    END IF;
END;
/



-- Part 2 --------------------------------------------------------


-- General Manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (1, 'Lebron', 'James', 300000, 'GeneralManager', 101, 2, NULL, '44 Redline Street', 'Cleveland', 28321);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (2, 'Kyrie', 'Irving', 300000, 'GeneralManager', 102, 2, NULL, '32 Maloney Road', 'Brooklyn', 12642);


-- Division Manager
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (3, 'James', 'Harden', 200000, 'DivisionManager', 103, 1, 2, '13 Wildflower Ridge', 'Houston', 62312);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (4, 'Steph', 'Curry', 200000, 'DivisionManager', 104, 1, 1, '463 South Lane', 'San Francisco', 32034);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (5, 'Devin', 'Booker', 200000, 'DivisionManager', 105, 1, 1, '2929 Ritter Avenue', 'Phoenix', 23234);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (6, 'Trae', 'Young', 200000, 'DivisionManager', 106, 1, 2, '2513 Grove Avenue', 'Oklahoma', 53245);

-- Regular employee
INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (7, 'Anthony', 'Edwards', 120000, 'Doctor', 107, 0, 3, '2013 Hanifan Lane', 'Atlanta', 91432);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (8, 'Lamelo', 'Ball', 120000, 'Doctor', 108, 0, 4, '3645 Pride Avenue', 'Charlotte', 32102);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (9, 'Anthony', 'Davis', 120000, 'Doctor', 109, 0, 3, '4322 Diamond Street', 'Los Angeles', 41232);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (10, 'Collin', 'Sexton', 120000, 'Doctor', 110, 0, 4, '4810 Spadafore Drive', 'Utah', 81292);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (11, 'Kevin', 'Durant', 120000, 'Doctor', 111, 0, 3, '3242 Dennison Street', 'Oklahoma', 28321);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (12, 'Jalen', 'Johnson', 120000, 'Doctor', 201, 0, 4, '4273 Carter Street', 'Atlanta', 72132);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (13, 'Zach', 'LaVine', 120000, 'Doctor', 202, 0, 3, '4029 Bobcat Drive', 'Chicago', 81232);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (14, 'DeMar', 'DeRozan', 120000, 'Doctor', 203, 0, 4, '801 Kelly Drive', 'Chicago', 32423);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (15, 'Ben', 'Simmons', 100000, 'EquipmentTechnician', 204, 0, 5, '2547 Michael Street', 'Brooklyn', 14323);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (16, 'Mikal', 'Bridges', 100000, 'EquipmentTechnician', 205, 0, 6, '3501 Ella Street', 'Phoenix', 25323);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (17, 'Jayson', 'Tatum', 100000, 'EquipmentTechnician', 206, 0, 5, '540 Clark Street', 'Boston', 16090);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (18, 'Jaylen', 'Brown', 100000, 'EquipmentTechnician', 207, 0, 6, '258 Heritage Road', 'Boston', 16191);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (19, 'Donovan', 'Mitchell', 100000, 'EquipmentTechnician', 208, 0, 5, '4912 Henery Street', 'Cleveland', 28422);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (20, 'Jamal', 'Murray', 100000, 'EquipmentTechnician', 209, 0, 6, '4683 Felosa Drive', 'Denver', 41321);

INSERT INTO Employee (empID, FNAME, LNAME, Salary, jobTitle, OfficeNum, empRank, supervisorID, AddressStreet, AddressCity, AddressZip)
VALUES (21, 'Ja', 'Morant', 100000, 'EquipmentTechnician', 210, 0, 5, '3853 Linden Avenue', 'Memphis', 92132);


-- Doctor
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (7, 'M', 'Radiology', 'WPI');      --Examines same patient > 2 times, a
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (8, 'M', 'Infancy', 'WPI');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (9, 'M', 'Disease', 'Harvard');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (10, 'M', 'Medicine', 'Umass Boston');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (11, 'M', 'Neurology', 'WPI');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (12, 'M', 'Dermatology', 'UCLA');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (13, 'M', 'Radiology', 'USC');
INSERT INTO Doctor (EmployeeID, gender, specialty, GraduatedFrom) VALUES (14, 'M', 'Cardiology', 'Stanford');


-- EquipmentTechnician
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (15);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (16);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (17);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (18);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (19);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (20);
INSERT INTO EquipmentTechnician (EmployeeID) VALUES (21);


-- EquipmentType
INSERT INTO EquipmentType (equipID, equipDesc, equipModel, instructions, NumberOfUnits) 
VALUES ('MRI', 'Uses radiology to form images of patient anatomy', 'Traditional MRI', 'Select appropriate radiofrequency, repetition time, echo time, slice thickness, and then initiate scan', 3);

INSERT INTO EquipmentType (equipID, equipDesc, equipModel, instructions, NumberOfUnits) 
VALUES ('CT Scanner', 'Combines series of X-Ray images to create cross-sectional images', '40-Slice CT Scanner', 'Calibrate scanner, adjust tube current, voltage, slice thickness, and start', 3);

INSERT INTO EquipmentType (equipID, equipDesc, equipModel, instructions, NumberOfUnits) 
VALUES ('Ultrasound', 'Uses sound waves to create images of patient organs', 'External ultrasound', 'Apply gel, adjust frquency and depth, and apply tansducer to patient', 3);

-- Room
INSERT INTO Room (rNum, occupied) VALUES (1000, 1);
INSERT INTO Room (rNum, occupied) VALUES (1001, 0);
INSERT INTO Room (rNum, occupied) VALUES (1002, 0);
INSERT INTO Room (rNum, occupied) VALUES (1003, 0);
INSERT INTO Room (rNum, occupied) VALUES (1004, 0);
INSERT INTO Room (rNum, occupied) VALUES (1005, 0);
INSERT INTO Room (rNum, occupied) VALUES (1006, 0);
INSERT INTO Room (rNum, occupied) VALUES (1007, 0);
INSERT INTO Room (rNum, occupied) VALUES (1008, 0);
INSERT INTO Room (rNum, occupied) VALUES (1009, 0);
INSERT INTO Room (rNum, occupied) VALUES (1010, 0);
INSERT INTO Room (rNum, occupied) VALUES (101, 1);
INSERT INTO Room (rNum, occupied) VALUES (102, 1);
INSERT INTO Room (rNum, occupied) VALUES (103, 1);
INSERT INTO Room (rNum, occupied) VALUES (104, 1);
INSERT INTO Room (rNum, occupied) VALUES (105, 1);
INSERT INTO Room (rNum, occupied) VALUES (106, 1);
INSERT INTO Room (rNum, occupied) VALUES (107, 1);
INSERT INTO Room (rNum, occupied) VALUES (108, 1);
INSERT INTO Room (rNum, occupied) VALUES (109, 1);
INSERT INTO Room (rNum, occupied) VALUES (110, 1);
INSERT INTO Room (rNum, occupied) VALUES (111, 1);
INSERT INTO Room (rNum, occupied) VALUES (201, 1);
INSERT INTO Room (rNum, occupied) VALUES (202, 1);
INSERT INTO Room (rNum, occupied) VALUES (203, 1);
INSERT INTO Room (rNum, occupied) VALUES (204, 1);
INSERT INTO Room (rNum, occupied) VALUES (205, 1);
INSERT INTO Room (rNum, occupied) VALUES (206, 1);
INSERT INTO Room (rNum, occupied) VALUES (207, 1);
INSERT INTO Room (rNum, occupied) VALUES (208, 1);
INSERT INTO Room (rNum, occupied) VALUES (209, 1);
INSERT INTO Room (rNum, occupied) VALUES (210, 1);


-- Patient
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES 
('111223333', 'Tom', 'Brady', '20 Hermitage Rd, Sudbury, MA', '3392210734');      --Test case for most visits, and has test cases for SSN 111-22-3333
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('222334444', 'Mac', 'Jones', '100 Gillette Stadium Rd, Foxborough, MA', '1112223333');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('333445555', 'Bailey', 'Zappy', '100 Gillette Stadium Rd, Foxborough, MA', '2223334444');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('444556666', 'Wil', 'Lutz', '20 Orleans Ave, New Orleans, LA', '3334445555');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('555667777', 'Russel', 'Wilson', '30 G St, Baltimore, MD', '4445556666');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('666778888', 'Serina', 'Williams', '560 Jett Lane, Los Angeles, CA', '5556667777');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('777889999', 'Amelia', 'Earhart', '700 John St, Worcester, MA', '6667778888');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('888991111', 'Princess', 'Diana', '1 Downtown Abbey, England, UK', '7778889999');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('111998888', 'Alicia', 'Keys', '3 East St, New York City, NY', '9998881111');
INSERT INTO Patient (SSN, FirstName, LastName, Address, TelNum) VALUES ('222887777', 'Taylor', 'Swift', '1 Arrowhead Dr, Kansas City, MO', '1119998888');


-- CanRepairEquipment
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (15, 'Ultrasound');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (16, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (17, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (18, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (19, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (20, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (21, 'CT Scanner');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (15, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (16, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (17, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (18, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (19, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (20, 'MRI');
INSERT INTO CanRepairEquipment (EmployeeID, EquipmentType) VALUES (21, 'MRI');


-- RoomService
INSERT INTO RoomService (roomNum, roomService) VALUES (1001, 'MRI Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1002, 'Ultrasound Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1003, 'CT Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1004, 'MRI Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1005, 'Ultrasound Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1006, 'CT Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1007, 'MRI Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1008, 'Ultrasound Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1009, 'CT Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1010, 'ICU');
INSERT INTO RoomService (roomNum, roomService) VALUES (1001, 'Ultrasound Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1002, 'CT Scans');
INSERT INTO RoomService (roomNum, roomService) VALUES (1003, 'MRI Scans');


-- RoomAccess
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1000, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1000, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1000, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1001, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1002, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1003, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1004, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1005, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1006, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1007, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1008, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1009, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1010, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1001, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1002, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1003, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1004, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1005, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1006, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1007, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1008, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1009, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1010, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1001, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1002, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1003, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1004, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1005, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1006, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1007, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1008, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1009, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (1010, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (101, 1);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (102, 2);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (103, 3);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (104, 4);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (105, 5);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (106, 6);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (107, 7);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (108, 8);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (109, 9);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (110, 10);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (111, 11);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (201, 12);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (202, 13);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (203, 14);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (204, 15);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (205, 16);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (206, 17);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (207, 18);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (208, 19);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (209, 20);
INSERT INTO RoomAccess (roomNum, EmpID) VALUES (210, 21);


-- Equipment
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('A01-02X', 'MRI', 2010, TO_DATE('2023-11-29', 'YYYY-MM-DD'), 1001);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('A01-03X', 'MRI', 2011, TO_DATE('2023-11-29', 'YYYY-MM-DD'), 1002);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('A01-04X', 'MRI', 2011, TO_DATE('2023-11-29', 'YYYY-MM-DD'), 1003);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('B01-01X', 'CT Scanner', 2010, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1001);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('B01-02X', 'CT Scanner', 2011, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1002);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('B01-03X', 'CT Scanner', 2010, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1003);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('C01-01X', 'Ultrasound', 2011, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1004);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('C01-02X', 'Ultrasound', 2010, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1005);
INSERT INTO Equipment (SerialNumb, TypeID, PurchaseYear, LastInspection, roomNum) VALUES ('C01-03X', 'Ultrasound', 2008, TO_DATE('2023-12-02', 'YYYY-MM-DD'), 1006);


-- Admission
INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (1, TO_DATE('11/29/2023', 'MM/DD/YYYY'), TO_DATE('11/29/2023', 'MM/DD/YYYY'), 1000, 900, '111223333', TO_DATE('12/15/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (11, TO_DATE('12/15/2023', 'MM/DD/YYYY'), TO_DATE('12/15/2023', 'MM/DD/YYYY'), 1500, 1300, '111223333', TO_DATE('12/17/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (111, TO_DATE('12/17/2023', 'MM/DD/YYYY'), TO_DATE('12/25/2023', 'MM/DD/YYYY'), 2000, 1800, '111223333', TO_DATE('12/20/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (2, TO_DATE('11/25/2023', 'MM/DD/YYYY'), TO_DATE('11/27/2023', 'MM/DD/YYYY'), 4000, 3000, '222334444', TO_DATE('12/1/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (22, TO_DATE('12/1/2023', 'MM/DD/YYYY'), TO_DATE('12/2/2023', 'MM/DD/YYYY'), 1500, 1300, '222334444', NULL);

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (3, TO_DATE('10/4/2023', 'MM/DD/YYYY'), TO_DATE('10/4/2023', 'MM/DD/YYYY'), 3000, 3000, '333445555', TO_DATE('10/25/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (33, TO_DATE('10/25/2023', 'MM/DD/YYYY'), TO_DATE('10/26/2023', 'MM/DD/YYYY'), 4000, 3900, '333445555', TO_DATE('11/1/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (4, TO_DATE('9/3/2023', 'MM/DD/YYYY'), TO_DATE('9/3/2023', 'MM/DD/YYYY'), 900, 100, '444556666', TO_DATE('9/27/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (44, TO_DATE('9/27/2023', 'MM/DD/YYYY'), TO_DATE('9/27/2023', 'MM/DD/YYYY'), 1000, 400, '444556666', NULL);

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (5, TO_DATE('10/23/2023', 'MM/DD/YYYY'), TO_DATE('10/25/2023', 'MM/DD/YYYY'), 10000, 9000, '555667777', TO_DATE('11/1/2023', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (55, TO_DATE('11/1/2023', 'MM/DD/YYYY'), TO_DATE('11/1/2023', 'MM/DD/YYYY'), 1000, 900, '555667777', TO_DATE('1/1/2024', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (6, TO_DATE('6/10/2023', 'MM/DD/YYYY'), TO_DATE('6/10/2023', 'MM/DD/YYYY'), 600, 500, '666778888', TO_DATE('6/10/2024', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (7, TO_DATE('8/22/2023', 'MM/DD/YYYY'), TO_DATE('8/23/2023', 'MM/DD/YYYY'), 1500, 1000, '777889999', NULL);

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (8, TO_DATE('3/22/2022', 'MM/DD/YYYY'), TO_DATE('3/22/2022', 'MM/DD/YYYY'), 800, 700, '888991111', TO_DATE('3/22/2024', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (9, TO_DATE('5/5/2023', 'MM/DD/YYYY'), TO_DATE('5/6/2023', 'MM/DD/YYYY'), 1600, 1200, '111998888', TO_DATE('5/5/2024', 'MM/DD/YYYY'));

INSERT INTO Admission (admissionNum, AdmissionDate, LeaveDate, TotalPayment, InsurancePayment, Patient_SSN, FutureVisit)
VALUES (10, TO_DATE('5/29/2023', 'MM/DD/YYYY'), TO_DATE('5/30/2023', 'MM/DD/YYYY'), 1700, 1000, '222887777', TO_DATE('5/29/2024', 'MM/DD/YYYY'));


-- Examine
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (8, 1, 'GOAT disease');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (9, 11, 'Continued GOAT disease');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 111, 'Extreme GOAT disease');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 2, 'Lack of GOAT');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 22, 'Continued Lack of GOAT');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 3, 'Mild Concussion');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (8, 33, 'Concussion Cleared');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (9, 4, 'High right ankle sprain, recommended PT');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 44, 'Cleared to play from ankle injury');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 5, 'Common cold');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 55, 'Mono, prescribe antibiotics');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 6, 'Extreme Concussion');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (8, 7, 'Stomach bug');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 8, 'Food Poisoning');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 9, 'Fractured left tibia');
INSERT INTO Examine (DoctorID, AdmissionNum, ExamineComment) VALUES (7, 10, 'Broken right big toe');


-- StayIn
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (1, 1001, TO_DATE('11/29/2023', 'MM/DD/YYYY'), TO_DATE('11/29/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (11, 1001, TO_DATE('12/15/2023', 'MM/DD/YYYY'), TO_DATE('12/15/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (111, 1002, TO_DATE('12/17/2023', 'MM/DD/YYYY'), TO_DATE('12/17/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (2, 1003, TO_DATE('11/25/2023', 'MM/DD/YYYY'), TO_DATE('11/27/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (22, 1003, TO_DATE('12/1/2023', 'MM/DD/YYYY'), TO_DATE('12/2/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (3, 1004, TO_DATE('10/4/2023', 'MM/DD/YYYY'), TO_DATE('10/4/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (33, 1005, TO_DATE('10/25/2023', 'MM/DD/YYYY'), TO_DATE('10/26/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (4, 1005, TO_DATE('9/3/2023', 'MM/DD/YYYY'), TO_DATE('9/3/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (44, 1006, TO_DATE('9/27/2023', 'MM/DD/YYYY'), TO_DATE('9/27/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (5, 1007, TO_DATE('10/23/2023', 'MM/DD/YYYY'), TO_DATE('10/25/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (55, 1008, TO_DATE('11/1/2023', 'MM/DD/YYYY'), TO_DATE('11/1/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (6, 1001, TO_DATE('6/10/2023', 'MM/DD/YYYY'), TO_DATE('6/10/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (7, 1002, TO_DATE('8/22/2023', 'MM/DD/YYYY'), TO_DATE('8/23/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (8, 1003, TO_DATE('3/22/2022', 'MM/DD/YYYY'), TO_DATE('3/22/2022', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (9, 1004, TO_DATE('5/5/2023', 'MM/DD/YYYY'), TO_DATE('5/6/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (10, 1005, TO_DATE('5/29/2023', 'MM/DD/YYYY'), TO_DATE('5/30/2023', 'MM/DD/YYYY'));






-- Part 3 --------------------------------------------------------


-- Q1.  Report the id, specialty, gender and school of graduation for doctors that have graduated from WPI (“WPI”)

 

SELECT EmployeeID, GraduatedFrom, specialty, gender

FROM Doctor

WHERE GraduatedFrom = 'WPI';

 

-- Q2.  For a given division manager (say, ID = 10),

-- report all regular employees that are supervised by this manager. Display the employees ID, names, and salary.

 

SELECT e.empID, e.FNAME, e.LNAME, e.Salary

FROM Employee e

WHERE e.supervisorID = 5;


 

-- Q3.  For each patient, report the sum of amounts paid by the insurance company for that patient,

-- i.e., report the patients SSN, and the sum of insurance payments over all visits.

-- Note: If you keep the insurance coverage as a percentage, then compute this percentage before getting the sum.

 

SELECT SSN, SUM(InsurancePayment) AS totalInsurance

FROM Patient, Admission

WHERE Patient.SSN = Admission.Patient_SSN

GROUP BY Patient.SSN;

 

-- Q4.  Report the number of visits done for each patient, i.e.,

-- for each patient, report the patient SSN, first and last names, and the count of visits done by this patient

 

SELECT SSN, FirstName, LastName, COUNT(admissionNum) AS NumbVisits

FROM Patient, Admission

WHERE Patient.SSN = Admission.Patient_SSN

GROUP BY Patient.SSN, Patient.FirstName, Patient.LastName;


 

-- Q5.  Report the room number that has an equipment unit with serial number ‘A01-02X’

 

SELECT roomNum

FROM Equipment

WHERE SerialNumb = 'A01-02X';

 

-- Q6.  Report the employee who has access to the largest number of rooms.

-- We need the employee ID, and the number of rooms they can access.

-- Note: If there are several employees with the same maximum number, then report all of these employees.

 

SELECT EmpID, COUNT(roomNum) AS RoomCount
FROM RoomAccess
GROUP BY EmpID
HAVING COUNT(roomNum) = (SELECT MAX(RoomCount) FROM (SELECT COUNT(roomNum) AS RoomCount FROM RoomAccess GROUP BY EmpID));


 

-- Q7.  Report the number of regular employees, division managers, and general managers in the hospital.

-- The output should look like:


SELECT 'Regular Employee' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=0 
GROUP BY empRank
UNION
SELECT 'Division Manager' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=1
GROUP BY empRank
UNION
SELECT 'General Manager' AS empRank, COUNT(empID) AS Count
FROM Employee
WHERE empRank=2
GROUP BY empRank;

-- Q8.  For patients who have a scheduled future visit (which is part of their most recent visit),

-- report that patient’s SSN, first name, and last name, and the visit date.

-- Do not report patients who do not have a scheduled visit.

 

SELECT p.SSN, p.FirstName, p.LastName, a.FutureVisit AS VisitDate
FROM Patient p, Admission a
WHERE p.SSN = a.Patient_SSN AND a.FutureVisit IS NOT NULL 
    AND a.FutureVisit = (
        SELECT MAX(a.FutureVisit)
        FROM Admission a
        WHERE a.Patient_SSN = p.SSN
    );

 

-- Q9.  Report all equipment types that have less than two technicians that can maintain them.

 
SELECT ET.equipID, ET.equipDesc, ET.equipmodel, COUNT(CR.EmployeeID) AS NumbTecs
FROM EquipmentType ET, CanRepairEquipment CR
WHERE CR.EquipmentType = ET.equipID
GROUP BY ET.equipID, ET.equipDesc, ET.equipModel
HAVING COUNT(CR.EmployeeID) < 2;




-- Q10. Report the date of the coming future visit for patient with SSN = 111-22-3333.

-- Note: This date should exist in the last (most recent) visit of that patient.



SELECT a.FutureVisit AS VisitDate
FROM Patient p, Admission a
WHERE p.SSN = a.Patient_SSN AND a.FutureVisit IS NOT NULL AND p.SSN = 111223333
    AND a.FutureVisit = (
        SELECT MAX(a.FutureVisit)
        FROM Admission a
        WHERE a.Patient_SSN = p.SSN
    );
 
 

-- Q11. For patient with SSN = 111-22-3333, report the doctors (only ID) who have examined this patient more than 2 times.

 

SELECT DoctorID

FROM Admission, Examine

WHERE Examine.AdmissionNum = Admission.admissionNum AND Admission.Patient_SSN = 111223333

GROUP BY Examine.DoctorID

HAVING COUNT(Admission.AdmissionNum) > 2;

 

-- Q12. Report the equipment types (only the ID)

-- for which the hospital has purchased equipment (units) in both 2010 and 2011. Do not report duplication.

 

SELECT DISTINCT equipID

FROM EquipmentType, Equipment

WHERE Equipment.TypeID = EquipmentType.equipID AND Equipment.PurchaseYear >= 2010 AND Equipment.PurchaseYear <= 2011

GROUP BY Equipment.TypeID

HAVING COUNT(PurchaseYear) >= 2;




-- PHASE 3, Part 1 --------------------------------------------------------------------------------------------

-- Question 1

-- Tom Brady
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (1, 1010, TO_DATE('11/29/2023', 'MM/DD/YYYY'), TO_DATE('11/29/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (11, 1010, TO_DATE('12/15/2023', 'MM/DD/YYYY'), TO_DATE('12/15/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (111, 1010, TO_DATE('12/17/2023', 'MM/DD/YYYY'), TO_DATE('12/17/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (111, 1010, TO_DATE('12/18/2023', 'MM/DD/YYYY'), TO_DATE('12/18/2023', 'MM/DD/YYYY'));
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (111, 1010, TO_DATE('12/19/2023', 'MM/DD/YYYY'), TO_DATE('12/19/2023', 'MM/DD/YYYY'));

INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (2, 1010, TO_DATE('2023-11-27', 'YYYY-MM-DD'), TO_DATE('2023-11-27', 'YYYY-MM-DD')); -- Add mac Jones stay in ICU Multiple times
INSERT INTO StayIn (AdmissionNum, RoomNum, StartDate, EndDate) VALUES (22, 1010, TO_DATE('2023-12-2', 'YYYY-MM-DD'), TO_DATE('2023-12-2', 'YYYY-MM-DD')); -- Add mac Jones stay in ICU Multiple times

DROP VIEW CriticalCases;

CREATE VIEW CriticalCases AS
SELECT p.SSN AS Patient_SSN, p.firstName, p.lastName, count(a.admissionNum) AS numberOfAdmissionsToICU
FROM Admission a, Patient p,(
    SELECT si.AdmissionNum
    FROM StayIn si, RoomService rs
    WHERE rs.roomNum = si.roomNum
    AND si.roomNum = 1010
) si
WHERE si.admissionNum = a.AdmissionNum
AND a.Patient_SSN = p.SSN
GROUP BY p.SSN, p.FirstName, p.LastName
HAVING COUNT(*) > 1;

SELECT * FROM CriticalCases;

-- Question 2


DROP VIEW DoctorsLoad;


CREATE VIEW DoctorsLoad AS
SELECT
    D.EmployeeID AS DoctorID,
    D.GraduatedFrom,
    CASE
        WHEN COUNT(DISTINCT E.AdmissionNum) > 10 THEN 'Overload'
        ELSE 'Underload'
    END AS Load
FROM
    Doctor D
LEFT JOIN
    Examine E ON D.EmployeeID = E.DoctorID
GROUP BY
    D.EmployeeID, D.GraduatedFrom;



SELECT * FROM DoctorsLoad;


-- Question 3


DROP VIEW Critical_Case_Patients;

CREATE VIEW Critical_Case_Patients AS
SELECT p.SSN, p.FirstName, p.LastName, p.Address, p.TelNum
FROM CriticalCases cc, Patient p
WHERE cc.numberOfAdmissionsToICU > 4 AND cc.Patient_SSN = p.SSN;

SELECT * FROM Critical_Case_Patients;


-- Question 4


DROP VIEW OverloadedWPIDoctors;


CREATE VIEW OverloadedWPIDoctors AS
SELECT
    dl.DoctorID,
    E.FNAME AS FirstName,
    E.LNAME AS LastName
FROM
    DoctorsLoad dl, Employee E
WHERE
    dl.DoctorID = E.empID AND Load = 'Overload' AND GraduatedFrom = 'WPI';

SELECT * FROM OverloadedWPIDoctors;


-- Question 5


DROP VIEW UnderloadedDoctorsComments;

CREATE VIEW UnderloadedDoctorsComments AS
SELECT e.DoctorID, ca.Patient_SSN, e.ExamineComment
FROM Examine e, DoctorsLoad dl,(
    SELECT admissionNum, CC.Patient_SSN 
    FROM Admission A, CriticalCases CC
    WHERE A.Patient_SSN = CC.Patient_SSN
) ca
WHERE ca.admissionNum = e.AdmissionNum
AND e.DoctorID = dl.DoctorID
AND dl.Load = 'Underload';

SELECT * FROM UnderloadedDoctorsComments;
