-- GDPR and Data Guidelines

-- 

-- 1. Add a status column to track if a customer is Active or Anonymized
ALTER TABLE Customers 
ADD COLUMN GDPRStatus VARCHAR(20) DEFAULT 'Active';

-- 2. Add a column to record the exact date they requested their data wiped
ALTER TABLE Customers 
ADD COLUMN RequestedErasureDate DATE DEFAULT NULL;

-- Encrypted data for litigation and audit by archiving table
CREATE TABLE CustomerLitigationArchive (
    ArchiveID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    SecurePayload TEXT, -- This will hold a combined, encrypted-style string of the old name/email
    ArchivedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- This forces MySQL to modify the column into a true raw binary block, stripping any text validation rules
ALTER TABLE CustomerLitigationArchive 
MODIFY COLUMN SecurePayload LONGBLOB;

-- Archiving the Data for Legal Teams
INSERT INTO CustomerLitigationArchive (CustomerID, SecurePayload)
SELECT CustomerID, CONCAT('WIPED_USER_BACKUP | Name: ', CustomerName, ' | Email: ', Email, ' | Phone: ', Phone)
FROM Customers
WHERE CustomerID = 1;

SELECT * FROM CustomerLitigationArchive;

-- Masking the Customer Table Data 
UPDATE Customers
SET 
    CustomerName = 'GDPR_ANONYMOUS_USER',
    Email = 'deleted@compliant.com',
    Phone = '000-000-0000',
    GDPRStatus = 'Anonymized',
    RequestedErasureDate = CURDATE()  -- Dynamically grabs today's date
WHERE CustomerID = 1;

SELECT * FROM customers
WHERE customerID = 1;

SELECT C.CustomerID, C.CustomerName, C.GDPRStatus, SUM(OD.Quantity * P.Price) AS TotalSpent
FROM Customers C
JOIN Orders O ON O.CustomerID = C.CustomerID
JOIN OrderDetails OD ON OD.OrderID = O.OrderID
JOIN Products P ON P.ProductID = OD.ProductID
WHERE C.CustomerID = 1
GROUP BY C.CustomerID, C.CustomerName, C.GDPRStatus;

-- Building a procedure to anonymise customer data upon deletion request. 
DELIMITER /

CREATE PROCEDURE AnonymizeCustomer(IN target_id INT)
BEGIN
    -- 1. Combine PII and AES-Encrypt it before pushing to the archive
    INSERT INTO CustomerLitigationArchive (CustomerID, SecurePayload)
    SELECT 
        CustomerID, 
        AES_ENCRYPT(
            CONCAT('Name: ', CustomerName, ' | Email: ', Email, ' | Phone: ', Phone), 
            'Decryptkey' -- This is our private decryption passphrase
        )
    FROM Customers
    WHERE CustomerID = target_id;

    -- 2. Overwrite and Mask the Real Customer Profile (Same as before)
    UPDATE Customers
    SET 
        CustomerName = 'GDPR_ANONYMOUS_USER',
        Email = 'deleted@compliant.com',
        Phone = '000-000-0000',
        GDPRStatus = 'Anonymized',
        RequestedErasureDate = CURDATE()
    WHERE CustomerID = target_id;
    
END / 

DELIMITER ;



SELECT * FROM Customers WHERE CustomerID = 2;

CALL AnonymizeCustomer(2);

-- 1. Check the main profile table (Data is successfully masked)
SELECT CustomerID, CustomerName, GDPRStatus, RequestedErasureDate 
FROM Customers 
WHERE CustomerID = 2;

-- 2. Check the archive table (Legal backup is successfully stored)
SELECT * FROM CustomerLitigationArchive WHERE CustomerID = 2;

DELIMITER $$

-- Creating the BEFORE DELETE Trigger
CREATE TRIGGER trg_BlockCustomerDelete
BEFORE DELETE ON Customers
FOR EACH ROW
BEGIN
    -- Signal an error state (45000 is a generic unhandled exception code in SQL)
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'CRITICAL ERROR: Hard deletes are forbidden for financial compliance. Use AnonymizeCustomer() instead.';
END$$


DELIMITER ;

DELETE FROM Customers WHERE CustomerID = 3;

CALL AnonymizeCustomer(3);

SELECT * FROM CustomerLitigationArchive WHERE CustomerID = 3;

-- Decryption 
SELECT 
    ArchiveID,
    CustomerID,
    CAST(AES_DECRYPT(SecurePayload, 'Decryptkey') AS CHAR) AS DecryptedLegalData
FROM CustomerLitigationArchive
WHERE CustomerID = 3;