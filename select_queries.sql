--
--
--
-- Simple Retrieval & Filtering
--
--
--

-- Retrieve all teacher records
SELECT *
FROM teachers;

-- Retrieve specific teacher details
SELECT teacher_id, name, email, phone, specialization, experience_years
FROM teachers;

-- Retrieve a specific student by ID
SELECT *
FROM students
WHERE student_id = 2;

-- Retrieve a student name based on name match
CREATE FULLTEXT INDEX full_name_idx ON students(name);
SELECT name
FROM students
WHERE MATCH(name) AGAINST('Brown -Mia Fra*' IN BOOLEAN MODE);

-- Retrieve a student name and email based on email pattern
SELECT name, email
FROM students
WHERE email LIKE '_______3@%';

-- Retrieve teacher names with single-digit (< 10) years of experience
SELECT name, experience_years
FROM teachers
WHERE experience_years LIKE '_';

-- Retrieve distinct class levels
SELECT DISTINCT LEVEL
FROM classes;

-- Retrieve Memberships for multiple Students
SELECT *
FROM student_memberships
WHERE student_id IN (4, 9, 17);

-- Find Students with Missing birthdate or phone
SELECT *
FROM students
WHERE birthdate IS NULL
OR phone IS NULL;

--
--
--
-- Aggregations & Counting
--
--
--

-- Count distinct classes in attendance records
SELECT COUNT(DISTINCT class_id) AS classes_with_attendance
FROM attendance;

-- Count total reviews
SELECT COUNT(*) AS total_reviews
FROM reviews;

-- Find the earliest birth year among students
SELECT MIN(YEAR(birthdate))
FROM students;

-- Get the highest discount percentage from memberships
SELECT MAX(discount_percentage) AS highest_discount_percent
FROM memberships;

-- Calculate the rounded average rating from reviews
SELECT ROUND(AVG(rating)) AS average_rate
FROM reviews;

-- Sum the total PayPal payments
SELECT SUM(amount) AS sum_paypal_payments
FROM payments
WHERE payment_method = 'PayPal';

-- Count the number of payments per payment method, sorted in descending order
SELECT COUNT(*) AS cnt, payment_method
FROM payments
GROUP BY
	payment_method
ORDER BY
	cnt DESC;

--
--
--
-- Using Variables
--
--
--

-- Retrieve Payments using Dynamic Offset with a Prepared Statement
SET @offset_value = 5 * 2;
PREPARE stmt
FROM 'SELECT * FROM payments ORDER BY payment_id LIMIT 5 OFFSET ?';
EXECUTE stmt
	USING @offset_value;
DEALLOCATE PREPARE stmt;


-- Return if the teacher with teacher_id owns the class with class_id (no function format)
SET @teacher_id = 3;
SET @class_id = 2;
SELECT 
    CASE 
        WHEN (SELECT teacher_id FROM classes WHERE class_id = @class_id) = @teacher_id 
        THEN 'Yes' 
        ELSE 'No' 
    END AS is_class_teacher;

--
--
--
-- Sorting, Limiting & Filtering
--
--
--

-- Retrieve the top 5 highest payments
SELECT student_id, amount, payment_date 
FROM payments
ORDER BY
	payments.amount DESC
LIMIT 5;

-- Retrieve a subset of Payments (4 page)
SELECT *
FROM payments
ORDER BY
	payment_id
LIMIT 5 OFFSET 15;

--
--
--
-- Joins & Subqueries
--
--
--

-- Retrieve the name and membership start date of the student with student_id = 10 using a subquery
SELECT name,(
	SELECT start_date
FROM student_memberships
WHERE student_id = students.student_id) AS membership_start_date
FROM students
WHERE student_id = 4;

-- Retrieve the name and membership start date of the student with student_id = 10 using a CTE
WITH membership_cte AS (
SELECT student_id, start_date
FROM student_memberships
)
SELECT s.name, m.start_date AS membership_start_date
FROM students s
LEFT JOIN membership_cte m ON
	s.student_id = m.student_id
WHERE s.student_id = 10;

--
--
--
-- Using Views
--
--
--

-- Create a view to retrieve student names, their teacher's name, class style, and level for students who have subscribed to classes
CREATE OR REPLACE VIEW view_class_subscriptions_per_student AS
	SELECT s.name AS student_name,(
		SELECT name
	FROM teachers
	WHERE teachers.teacher_id = c.teacher_id) AS teacher_name, c.style, c.level
	FROM students s
	JOIN subscriptions sub ON
		s.student_id = sub.student_id
	JOIN classes c ON
		sub.class_id = c.class_id
	ORDER BY
		student_name;

-- Retrieve student names, their teacher's name, class style, and level for students who have subscribed to classes of 'Yin' style using the view
SELECT * 
FROM view_class_subscriptions_per_student
WHERE `style` = 'Yin';

--
--
--
-- Window Functions & Recursive CTEs
--
--
--

-- Retrieve students ranked by total payment amount within each membership type using RANK() and PARTITION BY
SELECT s.student_id, s.name, m.name AS membership_type, SUM(p.amount) AS total_paid, RANK() OVER (PARTITION BY m.name
ORDER BY
	SUM(p.amount) DESC) AS payment_rank
FROM students s
JOIN payments p ON
	s.student_id = p.student_id
JOIN student_memberships sm ON
	s.student_id = sm.student_id
JOIN memberships m ON
	sm.membership_id = m.membership_id
GROUP BY
	s.student_id, s.name, m.name;

-- Retrieve a running total of payments made by each student over time using a window function
SELECT p.student_id, s.name, p.amount, p.payment_date, SUM(p.amount) OVER (PARTITION BY p.student_id
ORDER BY
	p.payment_date) AS running_total
FROM payments p
JOIN students s ON
	p.student_id = s.student_id;

-- Calculate a rolling average of payments over the last 3 months per student.
SELECT student_id, payment_date, amount, AVG(amount) OVER (
        PARTITION BY student_id
ORDER BY payment_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_avg
FROM payments;

-- Determine students who haven't subscribed to a class in the last 6 months.
SELECT s.student_id, s.name, CASE 
           WHEN MAX(sub.subscription_date) < CURDATE() - INTERVAL 6 MONTH THEN 'Inactive'
ELSE 'Active' 
       END AS status
FROM students s
LEFT JOIN subscriptions sub ON
s.student_id = sub.student_id
GROUP BY s.student_id, s.name;

-- Show the top-growing class by comparing subscriptions in the last 2 months.
WITH recent_subs AS (
    SELECT class_id, COUNT(CASE WHEN subscription_date >= CURDATE() - INTERVAL 1 MONTH THEN 1 END) AS last_month, COUNT(CASE WHEN subscription_date >= CURDATE() - INTERVAL 2 MONTH 
                      AND subscription_date < CURDATE() - INTERVAL 1 MONTH THEN 1 END) AS prev_month
FROM subscriptions
GROUP BY class_id
)
SELECT class_id, last_month, prev_month,(last_month - prev_month) AS growth
FROM recent_subs
ORDER BY growth DESC
LIMIT 1;