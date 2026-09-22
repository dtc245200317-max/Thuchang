-- 1. Tạo CSDL và chuyển sang CSDL company
CREATE DATABASE IF NOT EXISTS company;
USE company;

-- Xóa bảng cũ nếu đã tồn tại để làm sạch môi trường
DROP TABLE IF EXISTS employees;

-- Tạo bảng employees
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

-- 2. Tạo Trigger phân loại phòng ban tự động dựa trên mức lương
DELIMITER //

DROP TRIGGER IF EXISTS update_department //

CREATE TRIGGER update_department
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END //

DELIMITER ;

-- 3. Demo chèn dữ liệu
-- Lưu ý: Dù truyền giá trị 'A' cho cột department, Trigger BEFORE INSERT 
-- sẽ can thiệp và ghi đè lại tên phòng ban tương ứng với mức lương.
INSERT INTO employees (name, department, salary)
VALUES 
    ('John Doe', 'A', 3500),      -- Lương 3500  => Tự đổi thành 'Sales'
    ('Jane Smith', 'A', 2000),     -- Lương 2000  => Tự đổi thành 'Support'
    ('David Johnson', 'A', 6000);  -- Lương 6000  => Tự đổi thành 'Management'

-- 4. Truy vấn kiểm tra kết quả
SELECT * FROM employees;