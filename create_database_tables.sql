DROP SCHEMA IF EXISTS yoga_studio;
CREATE SCHEMA yoga_studio;
USE yoga_studio;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS teachers;
CREATE TABLE teachers (
    teacher_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    phone BIGINT UNSIGNED UNIQUE,
    specialization VARCHAR(50),
    experience_years TINYINT CHECK (experience_years >= 0)
);

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS classes;
CREATE TABLE classes(
	class_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	style ENUM('Hatha', 'Ashtanga', 'Vinyasa', 'Kundalini', 'Yin'),
	level ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL,
	teacher_id SMALLINT UNSIGNED,
	one_time_price DECIMAL(6,2), 
    monthly_price DECIMAL(6,2), 
    schedule DATE NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS students;
CREATE TABLE students (
    student_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(50) UNIQUE,
    phone BIGINT UNSIGNED UNIQUE,
    birthdate DATE
);

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS subscriptions;
CREATE TABLE subscriptions (
    subscription_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    student_id SMALLINT UNSIGNED,
    class_id SMALLINT UNSIGNED,
    subscription_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE
);

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS attendance;
CREATE TABLE attendance (
    attendance_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    student_id SMALLINT UNSIGNED,
    class_id SMALLINT UNSIGNED,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE
);

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id SMALLINT UNSIGNED,
    subscription_id INT UNSIGNED,
    amount DECIMAL(6,2),
    payment_date DATE,
    payment_method ENUM('Cash', 'Credit Card', 'PayPal') NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE
);

--
-- Table structure for table `memberships`
--

DROP TABLE IF EXISTS memberships;
CREATE TABLE memberships (
    membership_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name ENUM('Regular', 'Premium', 'VIP') NOT NULL,
    discount_percentage INT CHECK (discount_percentage BETWEEN 0 AND 100),
    monthly_fee DECIMAL(6,2) NOT NULL
);

--
-- Table structure for table `student_memberships`
--

DROP TABLE IF EXISTS student_memberships;
CREATE TABLE student_memberships (
    student_id SMALLINT UNSIGNED PRIMARY KEY,
    membership_id SMALLINT UNSIGNED,
    start_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (membership_id) REFERENCES memberships(membership_id) ON DELETE CASCADE
);

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id SMALLINT UNSIGNED,
    teacher_id SMALLINT UNSIGNED,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    require_attention BIT DEFAULT FALSE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE
);
