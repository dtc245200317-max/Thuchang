-- Chọn cơ sở dữ liệu làm việc
USE classicmodels;

-- 1. Tạo Stored Procedure lấy toàn bộ danh sách khách hàng
DELIMITER //
CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT * FROM customers;
END //
DELIMITER ;

-- 2. Gọi (thực thi) Stored Procedure vừa tạo
CALL findAllCustomers();

-- 3. Cập nhật (Sửa) Stored Procedure
-- Do MySQL không hỗ trợ lệnh ALTER PROCEDURE để đổi nội dung bên trong (body), 
-- ta phải xóa thủ tục cũ đi (DROP) và tạo lại (CREATE)
DELIMITER //
DROP PROCEDURE IF EXISTS `findAllCustomers` //

CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT * FROM customers WHERE customerNumber = 175;
END //
DELIMITER ;

-- 4. Gọi lại Stored Procedure để xem kết quả sau khi đã thay đổi logic
CALL findAllCustomers();