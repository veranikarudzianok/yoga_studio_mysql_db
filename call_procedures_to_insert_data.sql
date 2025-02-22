DELETE FROM teachers;
CALL InsertTeachers(20);

DELETE FROM students;
CALL InsertStudents(70);

DELETE FROM classes;
CALL InsertClasses(40);

DELETE FROM subscriptions;
CALL InsertSubscriptions(100);

DELETE FROM attendance;
CALL InsertAttendance(100);

DELETE FROM payments;
CALL InsertPayments(200);

DELETE FROM memberships;
ALTER TABLE memberships AUTO_INCREMENT = 1;
INSERT INTO memberships (name, discount_percentage, monthly_fee) 
VALUES 
    ('Regular', 0, 50.00), 
    ('Premium', 10, 100.00), 
    ('VIP', 20, 150.00);

DELETE FROM student_memberships;
CALL InsertStudentMemberships(20);

DELETE FROM reviews;
CALL InsertReviews(50);