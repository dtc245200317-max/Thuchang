-- ============================================================================
-- DỰ ÁN SMARTFACTORY - SCRIPT TỐI ƯU HÓA INDEX HỆ THỐNG IOT
-- Người thực hiện: Database Optimization Expert
-- ============================================================================

-- 1. Tạo CSDL và Bảng SensorLogs
CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

DROP TABLE IF EXISTS SensorLogs;

CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- ============================================================================
-- 2. MÔ PHỎNG TRẠNG THÁI CŨ: "FAT COVERING INDEX"
-- Index phình to chứa tất cả các cột, gây thắt cổ chai luồng GHI (Write Bottleneck)
-- ============================================================================
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);

-- Kiểm tra kế hoạch thực thi (EXPLAIN) trên Fat Index
-- Kết quả cột Extra: "Using index" (Nghĩa là Covering Index - không cần xem Table gốc)
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

-- Xem thông số dung lượng vật lý ban đầu
SHOW TABLE STATUS LIKE 'SensorLogs';


-- ============================================================================
-- 3. THỰC HIỆN CHUYỂN ĐỔI: LOẠI BỎ FAT INDEX VÀ TẠO LEAN INDEX
-- ============================================================================
-- Xóa Index cồng kềnh gây lãng phí bộ nhớ và làm chậm INSERT
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- Tạo Lean Index tinh gọn: Chỉ giữ 2 cột phục vụ Lọc (WHERE) và Sắp xếp (ORDER BY)
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);


-- ============================================================================
-- 4. KIỂM TRA LẠI KẾ HOẠCH THỰC THI (EXPLAIN) VỚI LEAN INDEX
-- ============================================================================
-- Kết quả: 
-- - Cột key: idx_lean_search (Vẫn dùng Index để lọc vị trí cực nhanh)
-- - Cột type: range / ref (Tối ưu vùng dữ liệu quét)
-- - Cột Extra: KHÔNG còn "Using index" -> MySQL thực hiện Bookmark Lookup về Clustered Index để lấy temperature, humidity, status.
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs 
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

-- Kiểm tra lại dung lượng Index_length sau khi tối ưu
SHOW TABLE STATUS LIKE 'SensorLogs';