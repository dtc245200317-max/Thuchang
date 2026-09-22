-- ============================================================================
-- DỰ ÁN QUICKFEED - SCRIPT TỐI ƯU HÓA INDEX VÀ DUNG LƯỢNG LƯU TRỮ
-- Người thực hiện: DBA
-- ============================================================================

-- 1. Khởi tạo CSDL và Bảng (Mô phỏng Legacy State)
CREATE DATABASE IF NOT EXISTS quickfeed_db;
USE quickfeed_db;

DROP TABLE IF EXISTS Posts;

CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    post_type VARCHAR(10),
    is_visible BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tạo 5 Index ban đầu (Legacy Script gây cạn kiệt tài nguyên)
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_content ON Posts(content(255));
CREATE INDEX idx_post_type ON Posts(post_type);
CREATE INDEX idx_is_visible ON Posts(is_visible);
CREATE INDEX idx_created_at ON Posts(created_at);


-- ============================================================================
-- 2. KIỂM TRA DUNG LƯỢNG LƯU TRỮ TRƯỚC KHI CẮT BỎ INDEX
-- Sử dụng information_schema để tính dung lượng Data và Index (MB)
-- ============================================================================
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 2) AS `Data_Size_MB`,
    ROUND(((index_length) / 1024 / 1024), 2) AS `Index_Size_MB`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Total_Size_MB`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' AND table_name = 'Posts';

-- Xem danh sách Index và chỉ số Cardinality hiện tại
SHOW INDEX FROM Posts;


-- ============================================================================
-- 3. TIẾN HÀNH "PHẪU THUẬT": CẮT BỎ CÁC INDEX DƯ THỪA / HẠN CHẾ VÔ DỤNG
-- ============================================================================
-- Lỗi 1: Cột TEXT (content) tốn RAM/Disk phình to => DROP
ALTER TABLE Posts DROP INDEX idx_content;

-- Lỗi 2: Cardinality quá thấp (chỉ 3 giá trị 'TEXT', 'IMAGE', 'VIDEO') => DROP
ALTER TABLE Posts DROP INDEX idx_post_type;

-- Lỗi 3: Cardinality cực thấp (chỉ 2 giá trị 0 và 1) => DROP
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- GIỮ LẠI: idx_user_id (Load trang cá nhân) và idx_created_at (Sắp xếp Bảng tin)


-- ============================================================================
-- 4. KIỂM TRA LẠI DUNG LƯỢNG SAU KHI TỐI ƯU
-- ============================================================================
SELECT 
    table_name AS `Table`,
    ROUND(((data_length) / 1024 / 1024), 2) AS `Data_Size_MB`,
    ROUND(((index_length) / 1024 / 1024), 2) AS `Index_Size_MB`,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS `Total_Size_MB`
FROM information_schema.TABLES
WHERE table_schema = 'quickfeed_db' AND table_name = 'Posts';

-- ============================================================================
-- (GỢI Ý TỐI ƯU THÊM) Khi cần tìm kiếm nội dung trong content
-- Sử dụng FULLTEXT INDEX thay thế cho B-Tree Index truyền thống
-- ============================================================================
-- ALTER TABLE Posts ADD FULLTEXT INDEX ft_idx_content(content);