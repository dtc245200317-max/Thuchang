-- Chọn cơ sở dữ liệu làm việc
USE classicmodels;

-- =======================================================
-- 1. TẠO VIEW
-- Tạo một bảng ảo chỉ chứa các cột cần thiết: Mã KH, Tên KH và Số điện thoại
-- =======================================================
CREATE VIEW customer_views AS
SELECT customerNumber, customerName, phone
FROM customers;

-- Truy vấn dữ liệu từ View vừa tạo giống như một bảng bình thường
SELECT * FROM customer_views;


-- =======================================================
-- 2. CẬP NHẬT VIEW
-- Thay đổi cấu trúc của View để lấy thêm cột họ tên người liên hệ 
-- và chỉ lọc những khách hàng ở thành phố 'Nantes'
-- =======================================================
CREATE OR REPLACE VIEW customer_views AS
SELECT customerNumber, customerName, contactFirstName, contactLastName, phone
FROM customers
WHERE city = 'Nantes';

-- Kiểm tra lại dữ liệu sau khi View đã được cập nhật
SELECT * FROM customer_views;


-- =======================================================
-- 3. XÓA VIEW
-- Xóa bảng ảo khỏi hệ thống khi không còn nhu cầu sử dụng
-- =======================================================
DROP VIEW IF EXISTS customer_views;