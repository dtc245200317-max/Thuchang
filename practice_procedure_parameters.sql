-- Chọn cơ sở dữ liệu làm việc
USE classicmodels;

-- =======================================================
-- 1. THAM SỐ LOẠI IN (Input)
-- Truyền giá trị vào để Procedure sử dụng để truy vấn
-- =======================================================
DELIMITER //
DROP PROCEDURE IF EXISTS getCusById //

CREATE PROCEDURE getCusById(IN cusNum INT(11))
BEGIN
    SELECT * FROM customers WHERE customerNumber = cusNum;
END //
DELIMITER ;

-- Gọi Procedure loại IN: Truyền trực tiếp giá trị 175 vào
CALL getCusById(175);


-- =======================================================
-- 2. THAM SỐ LOẠI OUT (Output)
-- Trích xuất dữ liệu từ Procedure ra bên ngoài để sử dụng
-- =======================================================
DELIMITER //
DROP PROCEDURE IF EXISTS GetCustomersCountByCity //

CREATE PROCEDURE GetCustomersCountByCity(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    -- Đếm số lượng khách hàng và gán kết quả vào biến total thông qua lệnh INTO
    SELECT COUNT(customerNumber)
    INTO total
    FROM customers
    WHERE city = in_city;
END //
DELIMITER ;

-- Gọi Procedure loại OUT: Biến nhận kết quả phải có dấu @ ở trước
CALL GetCustomersCountByCity('Lyon', @total);
-- Hiển thị kết quả của biến @total
SELECT @total AS TotalCustomersInLyon;


-- =======================================================
-- 3. THAM SỐ LOẠI INOUT (Input + Output)
-- Nhận giá trị ban đầu truyền vào, xử lý, và trả về lại chính biến đó
-- =======================================================
DELIMITER //
DROP PROCEDURE IF EXISTS SetCounter //

CREATE PROCEDURE SetCounter(
    INOUT counter INT,
    IN inc INT
)
BEGIN
    SET counter = counter + inc;
END //
DELIMITER ;

-- Gọi Procedure loại INOUT: Khởi tạo giá trị ban đầu, sau đó gọi hàm nhiều lần
SET @counter = 1;

CALL SetCounter(@counter, 1); -- @counter = 1 + 1 = 2
CALL SetCounter(@counter, 1); -- @counter = 2 + 1 = 3
CALL SetCounter(@counter, 5); -- @counter = 3 + 5 = 8

-- Hiển thị giá trị cuối cùng
SELECT @counter AS FinalCounter;