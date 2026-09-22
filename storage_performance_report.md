# BÁO CÁO TỐI ƯU HÓA HIỆU NĂNG VÀ DUNG LƯỢNG - HE QUẢN TRỊ QUICKFEED

**Người thực hiện:** DBA  
**Đối tượng báo cáo:** Tech Lead & System Admin  

---

## 1. Đánh giá Đánh đổi giữa Read (Đọc) và Write (Ghi)

Khi một câu lệnh `INSERT` bài viết mới được gửi đến CSDL, MySQL không chỉ đơn thuần chèn bản ghi vào bảng chính (Clustered Index). Hệ thống bắt buộc phải **cập nhật đồng thời cấu trúc cây B-Tree của tất cả các Secondary Index hiện có**.

* **Thảm họa vật lý:** Việc duy trì 5 Index phụ khiến mỗi thao tác `INSERT` nhân bản thành 6 hành vi ghi đĩa vật lý (1 Data Page + 5 Index Pages).
* **Hậu quả Timeout:** Khi số lượng dữ liệu tăng, các trang chỉ mục (Index Pages) bị phân mảnh (Page Split), gây hiện tượng nghẽn I/O ổ cứng và khóa bản ghi (Locking). Người dùng bị xoay vòng 5-10 giây do câu lệnh `INSERT` phải chờ hoàn tất việc cập nhật 5 cây B-Tree.

---

## 2. Khái niệm Cardinality & Lý do Cắt bỏ 3 Index

**Cardinality (Độ phân biệt dữ liệu):** Là số lượng giá trị duy nhất (Unique values) chứa trong một cột so với tổng số hàng.

| Tên Index | Kiểu dữ liệu | Mức Cardinality | Quyết định | Lý do bảo vệ |
| :--- | :--- | :--- | :--- | :--- |
| `idx_user_id` | INT | **Rất Cao** | **GIỮ LẠI** | Lọc theo từng người dùng cụ thể. Giúp truy xuất bài viết cá nhân cực nhanh. |
| `idx_created_at` | DATETIME | **Rất Cao** | **GIỮ LẠI** | Phục vụ truy vấn sắp xếp (ORDER BY) theo mốc thời gian trên Bảng tin. |
| `idx_is_visible` | BOOLEAN | **Cực Thấp (2)** | **XÓA** | Chỉ chứa 0 và 1. Khi 99% bài viết có `is_visible = 1`, Optimizer sẽ bỏ qua Index này và thực hiện Full Table Scan. Tạo Index hoàn toàn vô dụng. |
| `idx_post_type` | VARCHAR(10) | **Rất Thấp (3)** | **XÓA** | Chỉ có 'TEXT', 'IMAGE', 'VIDEO'. Chi phí Bookmark Lookup (tìm ngược về bảng chính) đắt hơn việc quét bộ nhớ. |
| `idx_content` | TEXT(255) | **Trung bình** | **XÓA** | B-Tree Prefix Index làm phình to kích thước ổ cứng khủng khiếp. Khi tìm kiếm văn bản cần dùng **FULLTEXT Index** thay vì B-Tree. |

---

## 3. Câu hỏi Vấn đáp Chuyên sâu (Tech Lead Review)

### Q1: Tại sao cột Giới tính hoặc Trạng thái (Boolean/Enum) lại là ứng cử viên tồi cho B-Tree Index?
**Trả lời:** Vì độ phân biệt dữ liệu (Cardinality) quá thấp. Khi quét chỉ mục B-Tree, MySQL lấy ra danh sách hàng triệu Pointer (con trỏ), sau đó phải thực hiện hàng triệu phép tra cứu ngẫu nhiên (Random I/O Bookmark Lookup) về Clustered Index để lấy toàn bộ cột. Chi phí Random I/O này lớn hơn gấp nhiều lần so với việc đọc tuần tự toàn bộ dữ liệu (Sequential Read / Full Table Scan). do đó MySQL Query Optimizer sẽ tự động từ chối dùng Index này.

### Q2: Nếu bảng Posts là một bảng Lịch sử/Archive (chỉ lưu, không UPDATE/DELETE, hiếm khi INSERT), việc có nhiều Index còn là thảm họa không?
**Trả lời:** **Không còn là thảm họa về tốc độ Write nữa**, nhưng vẫn gây lãng phí về **Storage và RAM Buffer Pool**. 
Trong hệ thống OLAP/Archive:
* Do tần suất INSERT cực thấp, chi phí ghi cây B-Tree được chấp nhận để đổi lấy tốc độ READ đa chiều.
* Tuy nhiên, việc lạm dụng các Index có Cardinality thấp vẫn làm phình to dung lượng ổ cứng vô ích và chiếm không gian bộ nhớ đệm (InnoDB Buffer Pool), làm giảm không gian lưu trữ các Data Pages quan trọng khác.