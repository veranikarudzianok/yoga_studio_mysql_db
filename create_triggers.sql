-- Ensures that no payment entry is inserted with a negative or zero amount.
DELIMITER //
CREATE TRIGGER prevent_negative_payment
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero.';
    END IF;
END;
//
DELIMITER ;

-- Check if the trigger returns error message
INSERT INTO payments
SET
    student_id = 1,
    subscription_id = 1,
    amount = 0
;

-- When a new student is added, they are automatically subscribed to a free trial yoga class.
DELIMITER //
CREATE TRIGGER auto_subscribe_free_class
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    DECLARE free_class_id SMALLINT;
    
    -- Check if there is a free class available
    SELECT class_id INTO free_class_id
    FROM classes
    WHERE monthly_price = 0
    LIMIT 1;

    -- If no free class exists, create one
    IF free_class_id IS NULL THEN
        INSERT INTO classes (style, level, teacher_id, one_time_price, monthly_price, schedule)
        VALUES ('Hatha', 'Beginner', 1, 0, 0, CURDATE()); -- Assigns default teacher (ID 1)

        -- Get the newly created class ID
        SET free_class_id = LAST_INSERT_ID();
    END IF;

    -- Subscribe the new student to the free class
    INSERT INTO subscriptions (student_id, class_id, subscription_date)
    VALUES (NEW.student_id, free_class_id, NOW());
END;
//
DELIMITER ;

-- Check if the trigger subscribes a student on a free class
INSERT INTO students
SET
    name = 'Test Trigger',
    email = 'testtrigger@test.com'
;


