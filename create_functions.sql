-- Deterministic function that takes an amount and a discount percentage, then returns the discounted price.
DELIMITER $$

CREATE FUNCTION calculate_discounted_price(amount DECIMAL(10,2), discount INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN amount - (amount * discount / 100);
END $$

DELIMITER ;

-- Usage of calculate_discounted_price()
SELECT calculate_discounted_price(100, 10); -- Returns 90.00

-- No SQL function that reformats a numeric phone number into a (XXX) XXX-XXXX format.
DELIMITER $$

CREATE FUNCTION format_phone_number(phone BIGINT) 
RETURNS VARCHAR(19)
NO SQL
BEGIN
    RETURN CONCAT('+(', LEFT(phone, 3), ') ', 
                  SUBSTRING(phone, 4, 2), '-', 
                  SUBSTRING(phone, 6, 3), '-', 
                  SUBSTRING(phone, 9, 2), '-', 
                  RIGHT(phone, 2));
END $$

DELIMITER ;

-- Usage of format_phone_number()
SELECT format_phone_number(375256345742);

-- The function containing SQL that calculates a student's age based on their birthdate.
DELIMITER $$

CREATE FUNCTION get_student_age(studentID INT) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE age INT;

    SELECT TIMESTAMPDIFF(YEAR, birthdate, CURDATE()) 
    INTO age 
    FROM students 
    WHERE student_id = studentID;
    
    RETURN age;
END $$

DELIMITER ;

-- Usage of get_student_age()
SELECT get_student_age(45);
