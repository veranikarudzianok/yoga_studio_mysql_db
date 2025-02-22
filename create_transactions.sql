DROP PROCEDURE IF EXISTS AddSubscriptionAndPayment;
DELIMITER $$
CREATE PROCEDURE AddSubscriptionAndPayment(
    IN p_student_id SMALLINT UNSIGNED, 
    IN p_class_id SMALLINT UNSIGNED, 
    IN p_amount DECIMAL(6, 2), 
    IN p_payment_method ENUM('Cash', 'Credit Card', 'PayPal'), 
    OUT trans_result VARCHAR(500)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
-- Set failure message and rollback
        ROLLBACK;
        SET trans_result = 'Error occurred during transaction!';
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert into subscriptions
    INSERT INTO subscriptions (student_id, class_id, subscription_date)
    VALUES (p_student_id, p_class_id, NOW());

    -- Get the last inserted subscription_id
    SET @subscription_id = LAST_INSERT_ID();

    -- Insert into payments
    INSERT INTO payments (student_id, subscription_id, amount, payment_date, payment_method)
    VALUES (p_student_id, @subscription_id, p_amount, NOW(), p_payment_method);

    -- Commit if everything is successful
    COMMIT;
    SET trans_result = 'Transaction "Add Subscription And Payment" - OK';
END$$
DELIMITER ;

-- Usage
CALL AddSubscriptionAndPayment(1, 2, 50.00, 'Credit Card', @trans_result);
SELECT @trans_result
