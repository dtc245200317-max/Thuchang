-- 1. Chọn cơ sở dữ liệu làm việc (classicmodels)
USE classicmodels;

-- 2. Sử dụng EXPLAIN để xem kế hoạch thực thi trước khi đánh chỉ mục
-- Lúc này MySQL chưa có chỉ mục, type sẽ là 'ALL' (quét toàn bộ bảng Table Scan).
EXPLAIN SELECT * FROM customers WHERE customerName = 'Land of Toys Inc.';

-- 3. Tạo chỉ mục (Index) đơn cho cột customerName
ALTER TABLE customers ADD INDEX idx_customerName(customerName);

-- 4. Sử dụng lại EXPLAIN để thấy sự tối ưu sau khi đánh chỉ mục
-- Lúc này type chuyển thành 'ref', possible_keys và key hiển thị 'idx_customerName', số rows phải duyệt giảm mạnh (chỉ còn 1).
EXPLAIN SELECT * FROM customers WHERE customerName = 'Land of Toys Inc.';

-- 5. Tạo chỉ mục phức hợp (Composite Index) cho 2 cột
ALTER TABLE customers ADD INDEX idx_full_name(contactFirstName, contactLastName);

-- 6. Kiểm tra kế hoạch thực thi với truy vấn liên quan đến các cột trong chỉ mục phức hợp
EXPLAIN SELECT * FROM customers WHERE contactFirstName = 'Jean' OR contactFirstName = 'King';

-- 7. Xóa chỉ mục phức hợp khi không còn sử dụng
ALTER TABLE customers DROP INDEX idx_full_name;

-- (Tuỳ chọn) Xóa chỉ mục idx_customerName để đưa bảng về trạng thái ban đầu
ALTER TABLE customers DROP INDEX idx_customerName;