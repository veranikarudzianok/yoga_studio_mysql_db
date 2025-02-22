DROP PROCEDURE IF EXISTS InsertTeachers;
DELIMITER $$
CREATE PROCEDURE InsertTeachers(IN num_teachers INT)
BEGIN
    DECLARE i INT DEFAULT 1;

	-- Reset the auto-increment value to 1
    ALTER TABLE teachers AUTO_INCREMENT = 1;
    
    -- Loop to insert random teacher data
    WHILE i <= num_teachers DO
        -- Insert a teacher record with random name, email, and phone number
        INSERT INTO teachers (name, email, phone, specialization, experience_years)
        VALUES (
            CONCAT(
                ELT(FLOOR(1 + (RAND() * 25)), 'Alice','Bob','Charlie','David','Emma','Frank','Grace','Hannah','Ian','Jack','Karen','Liam','Mia','Noah','Olivia','Paul','Quinn','Rachel','Steve','Tina','Uma','Vincent','Wendy','Xavier','Yara','Zach'),
                ' ',
                ELT(FLOOR(1 + (RAND() * 25)), 'Anderson','Brown','Clark','Davis','Evans','Foster','Garcia','Harris','Irwin','Jackson','Knight','Lopez','Martin','Nguyen','Owens','Perez','Quinn','Rodriguez','Smith','Thompson','Underwood','Valdez','Wilson','Xu','Yang','Zimmerman')
            ),  -- Random name by selecting a random first and last name
            CONCAT('teacher', i, '@test.com'),  -- Email as teacher[id]@test.com
            CONCAT('37529', LPAD(FLOOR(RAND() * 10000000), 7, '0')),  -- Random phone number in format 37529XXXXXXX
            ELT(FLOOR(1 + (RAND() * 5)), 'Power', 'Relaxation', 'Pranayama', 'Creative sequence', 'Flow'),  -- Random specialization
       		FLOOR(1 + (RAND() * 30))  -- Random experience years between 1 and 30
        );
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InsertStudents;
DELIMITER $$
CREATE PROCEDURE InsertStudents(IN num_students INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE to_insert_value INT;

    -- Reset the auto-increment value to 1
    ALTER TABLE students AUTO_INCREMENT = 1;

    WHILE i <= num_students DO
        -- Generate random numbers for determining if the phone and birthdate should be NULL
        SET to_insert_value = FLOOR(RAND() * 2); -- This will return either 0 or 1

        INSERT INTO students (name, email, phone, birthdate)
        VALUES (
            CONCAT(
                SUBSTRING_INDEX(SUBSTRING_INDEX('Alice,Bob,Charlie,David,Emma,Frank,Grace,Hannah,Ian,Jack,Karen,Liam,Mia,Noah,Olivia,Paul,Quinn,Rachel,Steve,Tina,Uma,Vincent,Wendy,Xavier,Yara,Zach', ',', FLOOR(1 + (RAND() * 26))), ',', -1),
                ' ',
                SUBSTRING_INDEX(SUBSTRING_INDEX('Anderson,Brown,Clark,Davis,Evans,Foster,Garcia,Harris,Irwin,Jackson,Knight,Lopez,Martin,Nguyen,Owens,Perez,Quinn,Rodriguez,Smith,Thompson,Underwood,Valdez,Wilson,Xu,Yang,Zimmerman', ',', FLOOR(1 + (RAND() * 26))), ',', -1)
            ),
            CONCAT('student', i, '@example.com'),
            CASE
                WHEN to_insert_value = 0 THEN NULL -- Set phone to NULL if to_insert_value is 0
                ELSE CONCAT('37529', LPAD(FLOOR(RAND() * 10000000), 7, '0')) -- Otherwise generate phone
            END,
            CASE
                WHEN to_insert_value = 0 THEN NULL -- Set birthdate to NULL if to_insert_value is 0
                ELSE DATE_ADD('1990-01-01', INTERVAL FLOOR(RAND() * 3650) DAY) -- Otherwise generate birthdate
            END
        );
        SET i = i + 1;
    END WHILE;
END $$ 
DELIMITER ;

DROP PROCEDURE IF EXISTS InsertClasses;
DELIMITER $$
CREATE PROCEDURE InsertClasses(IN num_classes INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_teacher_id SMALLINT UNSIGNED;

	-- Reset the auto-increment value to 1
    ALTER TABLE classes AUTO_INCREMENT = 1;
    
    -- Loop to insert random class data
    WHILE i <= num_classes DO
        -- Select a random teacher_id from the teachers table
        SET random_teacher_id = (SELECT teacher_id FROM teachers ORDER BY RAND() LIMIT 1);
        
        -- Insert a class record with random style, level, price, and schedule
        INSERT INTO classes (style, level, teacher_id, one_time_price, monthly_price, schedule)
        VALUES (
            ELT(FLOOR(1 + (RAND() * 5)), 'Hatha', 'Ashtanga', 'Vinyasa', 'Kundalini', 'Yin'),  -- Random style
            ELT(FLOOR(1 + (RAND() * 3)), 'Beginner', 'Intermediate', 'Advanced'),  -- Random level
            random_teacher_id,  -- Random teacher_id from teachers
            ROUND(10 + (RAND() * 20), 2),  -- Random one_time_price between 10 and 30
            ROUND(100 + (RAND() * 100), 2),  -- Random monthly_price between 100 and 200
            DATE_ADD('2025-03-01', INTERVAL FLOOR(RAND() * 31) DAY)  -- Random date between March 1 and March 31, 2025
        );
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InsertSubscriptions;
DELIMITER $$
CREATE PROCEDURE InsertSubscriptions(IN num_subscriptions INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_student_id SMALLINT UNSIGNED;
    DECLARE random_class_id SMALLINT UNSIGNED;
    DECLARE random_day INT;
    DECLARE random_hour INT;
    DECLARE random_minute INT;
    DECLARE random_second INT;
    DECLARE random_date TIMESTAMP;

	-- Reset the auto-increment value to 1
    ALTER TABLE subscriptions AUTO_INCREMENT = 1;

    -- Loop to insert random subscription data
    WHILE i <= num_subscriptions DO
        -- Select random student_id from the students table
        SET random_student_id = (SELECT student_id FROM students ORDER BY RAND() LIMIT 1);
        
        -- Select random class_id from the classes table
        SET random_class_id = (SELECT class_id FROM classes ORDER BY RAND() LIMIT 1);
        
        -- Generate random day, hour, minute, and second within December 2024
        SET random_day = FLOOR(1 + (RAND() * 31));  -- Random day between 1 and 31
        SET random_hour = FLOOR(RAND() * 24);       -- Random hour between 0 and 23
        SET random_minute = FLOOR(RAND() * 60);     -- Random minute between 0 and 59
        SET random_second = FLOOR(RAND() * 60);     -- Random second between 0 and 59
        
        -- Create the random timestamp within December 2024
        SET random_date = CONCAT('2025-01-', LPAD(random_day, 2, '0'), ' ', LPAD(random_hour, 2, '0'), ':', LPAD(random_minute, 2, '0'), ':', LPAD(random_second, 2, '0'));
        
        -- Insert the subscription record
        INSERT INTO subscriptions (student_id, class_id, subscription_date)
        VALUES (
            random_student_id,  -- Random student_id from students table
            random_class_id,    -- Random class_id from classes table
            random_date         -- Random timestamp in Jan 2025
        );
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InsertAttendance;

DELIMITER $$
CREATE PROCEDURE InsertAttendance(IN num_attendance INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_student_id SMALLINT UNSIGNED;
    DECLARE random_class_id SMALLINT UNSIGNED;

	-- Reset the auto-increment value to 1
    ALTER TABLE subscriptions AUTO_INCREMENT = 1;

    WHILE i <= num_attendance DO
        -- Select a random student_id from the students table
        SET random_student_id = (SELECT student_id FROM students ORDER BY RAND() LIMIT 1);
        
        -- Select a random class_id from the classes table
        SET random_class_id = (SELECT class_id FROM classes ORDER BY RAND() LIMIT 1);
        
        -- Insert the attendance record
        INSERT INTO attendance (student_id, class_id)
        VALUES (
            random_student_id,  -- Random student_id from students table
            random_class_id    -- Random class_id from classes table
        );
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS InsertPayments;
DELIMITER $$
CREATE PROCEDURE InsertPayments(IN num_payments INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_student_id SMALLINT UNSIGNED;
    DECLARE random_subscription_id INT UNSIGNED;
    DECLARE random_class_id SMALLINT UNSIGNED;
    DECLARE random_amount DECIMAL(6,2);
    DECLARE random_payment_method ENUM('Cash', 'Credit Card', 'PayPal');
    DECLARE class_schedule DATE;
    DECLARE random_days_before INT;
    DECLARE random_payment_date TIMESTAMP;

	-- Reset the auto-increment value to 1
    ALTER TABLE payments AUTO_INCREMENT = 1;

    WHILE i <= num_payments DO
        -- Select a random subscription_id from the subscriptions table
        SET random_subscription_id = (SELECT subscription_id FROM subscriptions ORDER BY RAND() LIMIT 1);
        
        -- Get the student_id and class_id linked to the chosen subscription_id
        SET random_student_id = (SELECT student_id FROM subscriptions WHERE subscription_id = random_subscription_id);
        SET random_class_id = (SELECT class_id FROM subscriptions WHERE subscription_id = random_subscription_id);

        -- Get a random amount from either one_time_price or monthly_price of the corresponding class
        SET random_amount = (
            SELECT CASE 
                WHEN RAND() < 0.5 THEN one_time_price 
                ELSE monthly_price 
            END 
            FROM classes 
            WHERE class_id = random_class_id
        );

        -- Get the class schedule date
        SET class_schedule = (SELECT schedule FROM classes WHERE class_id = random_class_id);

        -- Generate a random number of days before the class schedule (between 5 and 30 days before)
        SET random_days_before = FLOOR(5 + (RAND() * 25));
        SET random_payment_date = DATE_SUB(class_schedule, INTERVAL random_days_before DAY);

        -- Select a random payment method
        SET random_payment_method = ELT(FLOOR(1 + RAND() * 3), 'Cash', 'Credit Card', 'PayPal');

        -- Insert the payment record
        INSERT INTO payments (student_id, subscription_id, amount, payment_date, payment_method)
        VALUES (
            random_student_id,    -- Random student_id from subscriptions table
            random_subscription_id, -- Random subscription_id from subscriptions table
            random_amount,         -- Random one_time_price or monthly_price from classes table
            random_payment_date,   -- Random date before the class schedule
            random_payment_method  -- Random payment method
        );

        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InsertStudentMemberships;
DELIMITER $$
CREATE PROCEDURE InsertStudentMemberships(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_student_id SMALLINT UNSIGNED;
    DECLARE random_membership_id SMALLINT UNSIGNED;
    DECLARE start_date DATE;
    DECLARE expiration_date DATE;
    
    -- Reset auto-increment (if needed, but not required since student_id is the primary key)
    -- ALTER TABLE student_memberships AUTO_INCREMENT = 1;
    
    WHILE i <= num_records DO
        -- Select a random student_id from students table
        SET random_student_id = (SELECT student_id FROM students ORDER BY RAND() LIMIT 1);
        
        -- Select a random membership_id from memberships table
        SET random_membership_id = (SELECT membership_id FROM memberships ORDER BY RAND() LIMIT 1);
        
        -- Generate a random start date within 2024
        SET start_date = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY);
        
        -- Generate an expiration date in 2025 (6 to 12 months after start_date)
        SET expiration_date = DATE_ADD(start_date, INTERVAL (6 + FLOOR(RAND() * 7)) MONTH);
        
        -- Insert into student_memberships table
        INSERT IGNORE INTO student_memberships (student_id, membership_id, start_date, expiration_date)
        VALUES (random_student_id, random_membership_id, start_date, expiration_date);
        
        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS InsertReviews;

DELIMITER $$
CREATE PROCEDURE InsertReviews(IN num_reviews INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_student_id SMALLINT UNSIGNED;
    DECLARE random_teacher_id SMALLINT UNSIGNED;
    DECLARE random_rating TINYINT;
    DECLARE random_review_date DATE;
    DECLARE random_review_text TEXT;
    DECLARE require_attention BIT;

    -- Reset auto-increment
    ALTER TABLE reviews AUTO_INCREMENT = 1;
    
    -- Loop to insert multiple reviews
    WHILE i <= num_reviews DO
        -- Select a random student_id from students table
        SET random_student_id = (SELECT student_id FROM students ORDER BY RAND() LIMIT 1);

        -- Select a random teacher_id from teachers table
        SET random_teacher_id = (SELECT teacher_id FROM teachers ORDER BY RAND() LIMIT 1);

        -- Generate a random rating between 1 and 5
        SET random_rating = FLOOR(1 + RAND() * 5);

        -- Generate a random review date in 2024
        SET random_review_date = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY);

        -- Assign review text and require_attention based on rating
        CASE 
            WHEN random_rating = 1 THEN 
                BEGIN
                    SET random_review_text = 'Terrible experience, very disappointed.';
                    SET require_attention = TRUE;
                END;
            WHEN random_rating = 2 THEN 
                BEGIN
                    SET random_review_text = 'Not a great experience, wouldn’t recommend.';
                    SET require_attention = TRUE;
                END;
            WHEN random_rating = 3 THEN 
                BEGIN
                    SET random_review_text = 'It was okay, but nothing special.';
                    SET require_attention = FALSE;
                END;
            WHEN random_rating = 4 THEN 
                BEGIN
                    SET random_review_text = 'Good class, enjoyed it!';
                    SET require_attention = FALSE;
                END;
            WHEN random_rating = 5 THEN 
                BEGIN
                    SET random_review_text = 'Amazing teacher! Best class ever!';
                    SET require_attention = FALSE;
                END;
        END CASE;

        -- Insert into the reviews table
        INSERT INTO reviews (student_id, teacher_id, rating, review_text, review_date, require_attention)
        VALUES (random_student_id, random_teacher_id, random_rating, random_review_text, random_review_date, require_attention);

        SET i = i + 1;
    END WHILE;
END $$
DELIMITER ;