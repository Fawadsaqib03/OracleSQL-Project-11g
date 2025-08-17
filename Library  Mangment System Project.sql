-- Library Managment System

-- Student Table
CREATE TABLE Student (
  Student_ID VARCHAR2(20) PRIMARY KEY,
  Student_Name VARCHAR2(50) NOT NULL,
  Reg_Date DATE NOT NULL,
  Contact_No VARCHAR2(15) NOT NULL,
  Email VARCHAR2(100)
);
-- Author Table
CREATE TABLE Author (
  Author_ID NUMBER PRIMARY KEY,
  Author_Name VARCHAR2(100) NOT NULL
);

-- Genre Table
CREATE TABLE Genre (
  Genre_ID NUMBER PRIMARY KEY,
  Genre_Name VARCHAR2(100) NOT NULL
);

-- Librarian Table
CREATE TABLE Librarian (
  Librarian_ID VARCHAR2(10) PRIMARY KEY,
  Librarian_Name VARCHAR2(50) NOT NULL,
  Contact_Info VARCHAR2(50),
  Gender VARCHAR2(10),
  Working_Hours VARCHAR2(30)
);

-- Book Table
CREATE TABLE Book (
  Book_ID VARCHAR2(10) PRIMARY KEY,
  Title VARCHAR2(100) NOT NULL,
  Condition VARCHAR2(20) NOT NULL,
  Rating NUMBER(3,1),
  Author_ID NUMBER NOT NULL,
  Genre_ID NUMBER,
  Available VARCHAR2(3) CHECK (Available IN ('Yes', 'No')),
  CONSTRAINT fk_book_author FOREIGN KEY (Author_ID) REFERENCES Author(Author_ID),
  CONSTRAINT fk_book_genre FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID)
);

-- Borrowing Table
CREATE TABLE Borrowing (
  Borrow_ID VARCHAR2(10) PRIMARY KEY,
  Student_ID VARCHAR2(20) NOT NULL,
  Book_ID VARCHAR2(10) NOT NULL,
  Librarian_ID VARCHAR2(10) NOT NULL,
  Borrow_Date DATE NOT NULL,
  Due_Date DATE NOT NULL,
  Return_Date DATE,
  Status VARCHAR2(20) CHECK (Status IN ('Borrowed', 'Returned', 'Overdue')),
  CONSTRAINT fk_borrowing_student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
  CONSTRAINT fk_borrowing_book FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID),
  CONSTRAINT fk_borrowing_librarian FOREIGN KEY (Librarian_ID) REFERENCES Librarian(Librarian_ID),
  CONSTRAINT fk_borrowing_date FOREIGN KEY (Borrow_Date) REFERENCES Borrow_Date_Details(Borrow_Date)
);

-- Borrow_Date_Details Table
CREATE TABLE Borrow_Date_Details (
  Borrow_Date DATE NOT NULL,
  Return_Date DATE,
  CONSTRAINT borrow_date_pk PRIMARY KEY (Borrow_Date)
);

-- Fine_Reason Table
CREATE TABLE Fine_Reason (
  Reason_ID NUMBER PRIMARY KEY,
  Description VARCHAR2(100) NOT NULL
);

-- Fine_Status Table
CREATE TABLE Fine_Status (
  Status_ID NUMBER PRIMARY KEY,
  Description VARCHAR2(20) NOT NULL
);

-- Fine Table
CREATE TABLE Fine (
  Fine_ID VARCHAR2(10) PRIMARY KEY,
  Borrow_ID VARCHAR2(10) NOT NULL,
  Amount NUMBER(10, 2) NOT NULL,
  Reason_ID NUMBER NOT NULL,
  Status_ID NUMBER NOT NULL,
  Issue_Date DATE NOT NULL,
  Payment_Date DATE,
  CONSTRAINT fk_fine_borrow FOREIGN KEY (Borrow_ID) REFERENCES Borrowing(Borrow_ID),
  CONSTRAINT fk_fine_reason FOREIGN KEY (Reason_ID) REFERENCES Fine_Reason(Reason_ID),
  CONSTRAINT fk_fine_status FOREIGN KEY (Status_ID) REFERENCES Fine_Status(Status_ID)
);

-- Suspension Table
CREATE TABLE Suspension (
  Suspension_ID NUMBER PRIMARY KEY,
  Student_ID VARCHAR2(20) NOT NULL,
  Reason VARCHAR2(255) NOT NULL,
  Dues_Amount NUMBER(10,2),
  Issued_By VARCHAR2(10) NOT NULL,
  Issue_Date DATE NOT NULL,
  End_Date DATE,
  CONSTRAINT fk_suspension_student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
  CONSTRAINT fk_suspension_librarian FOREIGN KEY (Issued_By) REFERENCES Librarian(Librarian_ID)
);


-- Issue_History Table
CREATE TABLE ISSUE_HISTORY (
  ish_id VARCHAR2(10) PRIMARY KEY,
  st_id VARCHAR2(20),
  fine_id VARCHAR2(10),
  bk_id VARCHAR2(10),
  lib_id VARCHAR2(10),
  issue_date DATE,
  return_date DATE,
  CONSTRAINT issueh_st_id_fk FOREIGN KEY (st_id) REFERENCES Student(Student_ID),
  CONSTRAINT issueh_fine_id_fk FOREIGN KEY (fine_id) REFERENCES Fine(Fine_ID),
  CONSTRAINT issueh_bk_id_fk FOREIGN KEY (bk_id) REFERENCES Book(Book_ID),
  CONSTRAINT issueh_lib_id_fk FOREIGN KEY (lib_id) REFERENCES Librarian(Librarian_ID)
);
-- Book_Info Table
CREATE TABLE BOOK_INFO (
  book_info_id NUMBER PRIMARY KEY,
  bk_id VARCHAR2(10),
  bk_name VARCHAR2(50),
  CONSTRAINT book_info_bk_id_fk FOREIGN KEY (bk_id) REFERENCES Book(Book_ID)
);


-- Librarian_Info Table
CREATE TABLE LIBRARIAN_INFO (
  librarian_info_id NUMBER PRIMARY KEY,
  lib_id VARCHAR2(10),
  lib_name VARCHAR2(30),
  CONSTRAINT librarian_info_libid_fk FOREIGN KEY (lib_id) REFERENCES Librarian(Librarian_ID)
);



--queires--
select * from librarian_info;

describe book_info;

--INNER JOIN--
SELECT 
  B.Book_ID,
  B.Title,
  A.Author_Name,
  G.Genre_Name
FROM Book B
INNER JOIN Author A ON B.Author_ID = A.Author_ID
INNER JOIN Genre G ON B.Genre_ID = G.Genre_ID;

--LEFT JOIN--
SELECT 
  S.Student_ID,
  S.Student_Name,
  BR.Borrow_ID,
  BR.Book_ID,
  BR.Borrow_Date
FROM Student S
LEFT JOIN Borrowing BR ON S.Student_ID = BR.Student_ID;

--left JOin--
SELECT 
  F.Fine_ID,
  B.Borrow_ID,
  FR.Description AS Reason,
  FS.Description AS Status,
  F.Amount,
  F.Issue_Date,
  F.Payment_Date
FROM Fine F
INNER JOIN Borrowing B ON F.Borrow_ID = B.Borrow_ID
INNER JOIN Fine_Reason FR ON F.Reason_ID = FR.Reason_ID
INNER JOIN Fine_Status FS ON F.Status_ID = FS.Status_ID;

--inner join
SELECT 
  BI.book_info_id,
  BI.bk_name,
  B.Title,
  B.Condition,
  B.Rating
FROM BOOK_INFO BI
INNER JOIN Book B ON BI.bk_id = B.Book_ID;

SELECT 
  LI.librarian_info_id,
  LI.lib_name,
  L.Contact_Info,
  L.Working_Hours
FROM LIBRARIAN_INFO LI
INNER JOIN Librarian L ON LI.lib_id = L.Librarian_ID;

SELECT 
  SP.Suspension_ID,
  S.Student_Name,
  SP.Reason,
  SP.Dues_Amount,
  L.Librarian_Name AS Issued_By,
  SP.Issue_Date,
  SP.End_Date
FROM Suspension SP
INNER JOIN Student S ON SP.Student_ID = S.Student_ID
INNER JOIN Librarian L ON SP.Issued_By = L.Librarian_ID;


SELECT 
  IH.ish_id,
  ST.Student_Name,
  BK.Title AS Book_Title,
  FN.Amount AS Fine_Amount,
  LB.Librarian_Name,
  IH.issue_date,
  IH.return_date
FROM ISSUE_HISTORY IH
INNER JOIN Student ST ON IH.st_id = ST.Student_ID
INNER JOIN Book BK ON IH.bk_id = BK.Book_ID
INNER JOIN Fine FN ON IH.fine_id = FN.Fine_ID
INNER JOIN Librarian LB ON IH.lib_id = LB.Librarian_ID;


SELECT 
  BR.Borrow_ID,
  ST.Student_Name,
  BK.Title,
  BR.Borrow_Date,
  BR.Due_Date,
  BRD.Return_Date
FROM Borrowing BR
INNER JOIN Borrow_Date_Details BRD ON BR.Borrow_Date = BRD.Borrow_Date
INNER JOIN Student ST ON BR.Student_ID = ST.Student_ID
INNER JOIN Book BK ON BR.Book_ID = BK.Book_ID;

SELECT 
  s.Student_ID,
  s.Student_Name,
  b.Book_ID,
  bk.Title AS Book_Title,
  b.Borrow_Date
FROM 
  Student s
LEFT JOIN Borrowing b ON s.Student_ID = b.Student_ID
LEFT JOIN Book bk ON b.Book_ID = bk.Book_ID;
 
--right join--
SELECT 
  bk.Book_ID,
  bk.Title,
  s.Student_Name,
  b.Borrow_Date
FROM 
  Book bk
RIGHT JOIN Borrowing b ON bk.Book_ID = b.Book_ID
RIGHT JOIN Student s ON b.Student_ID = s.Student_ID;

--join with genre and author
SELECT 
  bk.Title,
  a.Author_Name,
  g.Genre_Name
FROM 
  Book bk
JOIN Author a ON bk.Author_ID = a.Author_ID
JOIN Genre g ON bk.Genre_ID = g.Genre_ID;

--Join to show fines with student and reason--
SELECT 
  f.Fine_ID,
  s.Student_Name,
  fr.Description AS Reason,
  f.Amount,
  fs.Description AS Fine_Status
FROM 
  Fine f
JOIN Borrowing b ON f.Borrow_ID = b.Borrow_ID
JOIN Student s ON b.Student_ID = s.Student_ID
JOIN Fine_Reason fr ON f.Reason_ID = fr.Reason_ID
JOIN Fine_Status fs ON f.Status_ID = fs.Status_ID;

--Students with Suspensions and who issued them
SELECT 
  s.Student_Name,
  su.Reason,
  su.Dues_Amount,
  su.Issue_Date,
  su.End_Date,
  l.Librarian_Name AS Issued_By
FROM 
  Suspension su
JOIN Student s ON su.Student_ID = s.Student_ID
JOIN Librarian l ON su.Issued_By = l.Librarian_ID;
--Books along with their info (Book_Info)
SELECT 
  b.Book_ID,
  b.Title,
  bi.bk_name
FROM 
  Book b
JOIN BOOK_INFO bi ON b.Book_ID = bi.bk_id;

--Issue History with related data
SELECT 
  ih.ish_id,
  s.Student_Name,
  bk.Title AS Book_Title,
  l.Librarian_Name,
  f.Amount AS Fine_Amount,
  ih.issue_date,
  ih.return_date
FROM 
  ISSUE_HISTORY ih
JOIN Student s ON ih.st_id = s.Student_ID
JOIN Book bk ON ih.bk_id = bk.Book_ID
JOIN Librarian l ON ih.lib_id = l.Librarian_ID
LEFT JOIN Fine f ON ih.fine_id = f.Fine_ID;


