-- ============================================================================
-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU DEMO
-- ============================================================================
CREATE DATABASE IF NOT EXISTS demo;
USE demo;


-- ============================================================================
-- BƯỚC 2: TẠO BẢNG PRODUCTS VÀ CHÈN DỮ LIỆU MẪU
-- ============================================================================
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(12, 2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus VARCHAR(20) DEFAULT 'Active'
);

-- Chèn dữ liệu mẫu
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus) VALUES
('P001', 'Laptop Dell XPS 13', 1500.00, 10, 'Ultra-thin laptop with M.2 SSD', 'Active'),
('P002', 'iPhone 15 Pro', 1200.00, 25, 'Titanium body flagship smartphone', 'Active'),
('P003', 'Samsung Galaxy S24', 1000.00, 15, 'AI-powered Android smartphone', 'Active'),
('P004', 'iPad Air 5', 600.00, 30, 'M1 chip mid-range tablet', 'Active'),
('P005', 'MacBook Air M2', 1100.00, 8, 'Lightweight laptop with Apple Silicon', 'Inactive');


-- ============================================================================
-- BƯỚC 3: TẠO INDEX VÀ ĐÁNH GIÁ HIỆU NĂNG VỚI EXPLAIN
-- ============================================================================

-- 1. Trạng thái TRƯỚC KHI tạo Index (MySQL phải dùng Full Table Scan -> type: ALL)
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'iPhone 15 Pro' AND productPrice = 1200.00;

-- 2. Tạo Unique Index trên cột productCode
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 3. Tạo Composite Index trên 2 cột productName và productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- 4. Trạng thái SAU KHI tạo Index
-- - Với productCode: type chuyển sang 'const', số dòng quét rows = 1 (Tối ưu tuyệt đối)
-- - Với composite index: type chuyển sang 'ref', chỉ định sử dụng key 'idx_name_price'
EXPLAIN SELECT * FROM Products WHERE productCode = 'P002';
EXPLAIN SELECT * FROM Products WHERE productName = 'iPhone 15 Pro' AND productPrice = 1200.00;


-- ============================================================================
-- BƯỚC 4: THAO TÁC VỚI VIEW
-- ============================================================================

-- 1. Tạo View lấy các cột: productCode, productName, productPrice, productStatus
CREATE VIEW product_display_view AS
SELECT productCode, productName, productPrice, productStatus
FROM Products;

-- Truy vấn từ View
SELECT * FROM product_display_view;

-- 2. Sửa đổi View (Chỉ lọc các sản phẩm có trạng thái 'Active')
CREATE OR REPLACE VIEW product_display_view AS
SELECT productCode, productName, productPrice, productStatus
FROM Products
WHERE productStatus = 'Active';

-- Kiểm tra lại View sau khi sửa
SELECT * FROM product_display_view;

-- 3. Xóa View
DROP VIEW IF EXISTS product_display_view;


-- ============================================================================
-- BƯỚC 5: THAO TÁC VỚI STORED PROCEDURE (CRUD FULL)
-- ============================================================================

DELIMITER //

-- 1. Procedure: Lấy tất cả thông tin sản phẩm
DROP PROCEDURE IF EXISTS getAllProducts //
CREATE PROCEDURE getAllProducts()
BEGIN
    SELECT * FROM Products;
END //

-- 2. Procedure: Thêm mới một sản phẩm
DROP PROCEDURE IF EXISTS addProduct //
CREATE PROCEDURE addProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_description TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Products(productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_description, p_status);
END //

-- 3. Procedure: Sửa thông tin sản phẩm theo ID
DROP PROCEDURE IF EXISTS updateProductById //
CREATE PROCEDURE updateProductById(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_description TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Products
    SET productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_description,
        productStatus = p_status
    WHERE id = p_id;
END //

-- 4. Procedure: Xóa sản phẩm theo ID
DROP PROCEDURE IF EXISTS deleteProductById //
CREATE PROCEDURE deleteProductById(
    IN p_id INT
)
BEGIN
    DELETE FROM Products WHERE id = p_id;
END //

DELIMITER ;


-- ============================================================================
-- CHẠY THỬ VÀ KIỂM TRA CÁC STORED PROCEDURE
-- ============================================================================

-- Lấy danh sách ban đầu
CALL getAllProducts();

-- Thêm sản phẩm mới
CALL addProduct('P006', 'Sony WH-1000XM5', 400.00, 12, 'Noise-canceling headphones', 'Active');

-- Cập nhật sản phẩm vừa thêm (ID = 6)
CALL updateProductById(6, 'P006', 'Sony WH-1000XM5 (Updated)', 380.00, 15, 'Discounted Noise-canceling headphones', 'Active');

-- Xóa sản phẩm vừa thêm (ID = 6)
CALL deleteProductById(6);

-- Kiểm tra lại danh sách cuối cùng
CALL getAllProducts();