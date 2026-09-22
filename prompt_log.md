# NHẬT KÝ TƯƠNG TÁC AI (AI PROMPT LOG)

**Chủ đề tra cứu:** Covering Index vs Write Penalty, InnoDB B-Tree Mechanics & Data Type Byte Size Calculations.

---

### Prompt 1: Tra cứu cơ chế Covering Index và Bookmark Lookup
* **Prompt:**  
  > "Giải thích sự khác biệt trong câu lệnh EXPLAIN của MySQL giữa 'Using index' (Covering Index) và việc MySQL phải thực hiện Bookmark Lookup (Clustered Index Lookup) về bảng gốc. Tác động của nó đến I/O bộ nhớ như thế nào?"
* **Ghi nhận kiến thức:**  
  * `Using index` xuất hiện ở cột `Extra` khi tất cả các cột được yêu cầu trong câu lệnh `SELECT` đều nằm sẵn trên Secondary Index B-Tree. MySQL không cần đọc Clustered Index.
  * Nếu thiếu cột, MySQL thực hiện **Bookmark Lookup**: Dùng Primary Key lấy từ Secondary Index để truy cập vào Data Page trên Clustered Index. Dù phát sinh thêm thao tác I/O nhưng nếu vùng lọc (`range`) nhỏ, chi phí này hoàn toàn không đáng kể so với việc duy trì Fat Index.

---

### Prompt 2: Tra cứu hiện tượng Write Penalty và Page Split trong IoT
* **Prompt:**  
  > "Tại sao hệ thống IoT ghi nhận dữ liệu liên tục lại bị tụt hiệu năng INSERT nghiêm trọng khi tạo Composite Index trên các cột số thực liên tục thay đổi như Temperature và Humidity? Hãy giải thích dưới góc độ InnoDB Page Split."
* **Ghi nhận kiến thức:**  
  * Dữ liệu thời gian (`recorded_at`) tăng dần đều (Sequential), nhưng `temperature` và `humidity` biến đổi ngẫu nhiên.
  * Khi đưa các cột biến đổi ngẫu nhiên vào B-Tree Index, các nút mới bị chèn chèn xen kẽ vào giữa các InnoDB Pages đã đầy.
  * Việc này kích hoạt cơ chế **InnoDB Page Split** (chia đôi trang $16\text{KB}$ hiện tại thành 2 trang mới), làm tăng thao tác Ghi đĩa vật lý (Random Write I/O) và gây khóa trang (Page Locking), dẫn đến rớt kết nối pipeline.

---

### Prompt 3: Tính toán byte kích thước dữ liệu
* **Prompt:**  
  > "Hãy so sánh dung lượng byte bộ nhớ trên InnoDB giữa các kiểu dữ liệu: VARCHAR(20) utf8mb4, DECIMAL(5,2), INT, DATETIME, và TINYINT. Việc giảm byte size ảnh hưởng thế nào đến Index Page Density?"
* **Ghi nhận kiến thức:**  
  * `VARCHAR(20) utf8mb4`: $1 - 81\text{ bytes}$.
  * `DECIMAL(5,2)`: $3\text{ bytes}$.
  * `DATETIME`: $5\text{ bytes}$.
  * `INT`: $4\text{ bytes}$.
  * `TINYINT`: $1\text{ byte}$.
  * **Index Page Density:** Kích thước key càng nhỏ thì một Page $16\text{KB}$ càng chứa được nhiều con trỏ (High Fan-out), giảm chiều cao cây B-Tree và giảm tổng số trang đĩa cần đọc/ghi.