# NHẬT KÝ TƯƠNG TÁC AI (AI PROMPT LOG)

**Chủ đề tra cứu:** InnoDB Storage Architecture, B-Tree Overhead & Index Cardinality Optimization.

---

### Prompt 1: Tra cứu kiến thức về Dung lượng lưu trữ (Storage Overhead)
* **Prompt:**  
  > "Trong hệ quản trị cơ sở dữ liệu MySQL (Storage Engine InnoDB), cấu trúc lưu trữ của Data Page và Index Page hoạt động như thế nào? Tại sao việc tạo Index trên cột TEXT(255) lại khiến dung lượng file `.ibd` phình to hơn rất nhiều so với cột INT hay DATETIME?"
* **Ghi nhận kiến thức:**  
  * InnoDB lưu trữ dữ liệu theo các trang (Pages) có kích thước mặc định $16\text{KB}$.
  * Mỗi Entry trong Secondary Index của cột `TEXT(255)` chứa chuỗi ký tự prefix dài tối đa $255\text{ bytes}$ cộng với giá trị Primary Key (`post_id`).
  * So với cột `INT` ($4\text{ bytes}$) hay `DATETIME` ($5\text{ bytes}$), kích thước mỗi nút trên cây B-Tree của cột `TEXT` lớn hơn gấp $30-50$ lần, dẫn đến một Index Page chứa được ít con trỏ hơn $\rightarrow$ Cây B-Tree bị phình to theo chiều cao và số lượng trang.

---

### Prompt 2: Tra cứu cơ chế Optimizer & Cardinality
* **Prompt:**  
  > "Tại sao khi tôi truy vấn `SELECT * FROM Posts WHERE is_visible = 1` trên bảng có 1 triệu dòng (99% `is_visible = 1`), MySQL Query Optimizer lại chọn Full Table Scan thay vì dùng Index `idx_is_visible`? Hãy giải thích qua khái niệm Bookmark Lookup và Random I/O vs Sequential I/O."
* **Ghi nhận kiến thức:**  
  * **Secondary Index Lookup:** Tìm trên B-Tree thu được $990.000$ con trỏ Primary Key.
  * **Bookmark Lookup (Clustered Index Lookup):** Với mỗi con trỏ, MySQL phải nhảy đến vị trí ngẫu nhiên trên đĩa cứng để đọc dòng tương ứng $\rightarrow$ Phát sinh $990.000$ thao tác **Random I/O**.
  * **Full Table Scan:** Đọc liên tục các Data Pages từ đầu đến cuối đĩa cứng $\rightarrow$ Thao tác **Sequential I/O**.
  * Vì Sequential I/O nhanh hơn Random I/O hàng chục lần, Query Optimizer quyết định bỏ qua Index `idx_is_visible`.

---

### Prompt 3: Truy vấn System Tables
* **Prompt:**  
  > "Hãy cho tôi câu lệnh SQL truy vấn bảng `information_schema.TABLES` để tính chính xác `Data_Size_MB` và `Index_Size_MB` của một bảng cụ thể trong MySQL."
* **Ghi nhận kiến thức:**  
  * Cột `DATA_LENGTH`: Tổng dung lượng của dữ liệu chính (Clustered Index) tính bằng Bytes.
  * Cột `INDEX_LENGTH`: Tổng dung lượng của tất cả Secondary Indexes tính bằng Bytes.
  * Công thức chuyển sang MB: `ROUND(bytes / 1024 / 1024, 2)`.