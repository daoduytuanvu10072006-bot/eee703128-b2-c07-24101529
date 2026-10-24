# C07 · Giao diện (Interface)

---

## 1. Ánh xạ chân theo Charter (mục 4)

> Theo danh mục đề: ui_in[7:0]=kênh A · uio_in[7:0]=kênh B · uo_out[0]=bất đồng tức thời · uo_out[1]=trạng thái lỗi · uo_out[7:2]=bộ đếm bất đồng
> Ngân sách chân: 16 bit vào + 8 bit ra = 24 trên 24 chân.
> Ánh xạ chân đã khả thi, không phải đổi gì.
> Một ô Tiny Tapeout có đúng 24 chân: ui_in 8 chỉ vào, uo_out 8 chỉ ra, uio 8 chọn chiều từng chân. uio_in và uio_out là cùng một bộ chân vật lý.

## 2. Bảng giao diện đã CHỐT — module `tt_um_c07_dual_channel`

Bảng dưới đây đọc trực tiếp từ thiết kế RTL thực tế (`rtl/project.sv`), tuân thủ đúng khung chân chuẩn của Tiny Tapeout.

| Tín hiệu | Chân | Chiều | Độ rộng (bit) | Mức tích cực / Giả định | Vai trò |
|---|---|---|:-:|---|---|
| `ui_in` | `ui_in[7:0]` | Input | 8 | - | Kênh A (dữ liệu vào) |
| `uio_in` | `uio_in[7:0]` | Input | 8 | - | Kênh B (dữ liệu vào) |
| `uo_out[0]` | `uo_out[0]` | Output | 1 | Cao (1) | Cờ bất đồng tức thời (`disagree`) |
| `uo_out[1]` | `uo_out[1]` | Output | 1 | Cao (1) | Cờ trạng thái lỗi (`error_state`) |
| `uo_out[7:2]` | `uo_out[7:2]` | Output | 6 | - | Giá trị bộ đếm (`counter`) |
| `clk` | `clk` | Input | 1 | Cạnh lên | Xung nhịp hệ thống |
| `rst_n` | `rst_n` | Input | 1 | Thấp (0) | Reset bất đồng bộ, tích cực mức thấp |
| `ena` | `ena` | Input | 1 | Cao (1) | Enable (luôn bằng 1 khi TT chọn thiết kế) |
| `uio_out` | `uio_out[7:0]` | Output | 8 | - | Không dùng (gán = 0) |
| `uio_oe` | `uio_oe[7:0]` | Output | 8 | - | Không dùng (gán = 0, tất cả là input) |

## 3. Ngân sách chân Tiny Tapeout

| Hạng mục | Số bit |
|---|---:|
| Tổng bit vào (`ui_in` + `uio_in`) | **16** |
| Tổng bit ra (`uo_out`) | **8** |
| **Tổng cộng** | **24** |
| Ô Tiny Tapeout có | **24** |
| **Chênh lệch** | **0 (VỪA KHÍT)** |

> ✅ **ĐIỂM MỞ ĐÃ ĐƯỢC GIẢI QUYẾT:** Thiết kế đã tận dụng tối đa và vừa khít 24/24 chân của Tiny Tapeout. 
> - Tín hiệu dung sai (`TOL`) và ngưỡng đếm (`N_MAX`) được cấu hình dưới dạng `parameter` trong RTL thay vì đưa ra chân vật lý, giúp tiết kiệm chân.
> - Chân `uio_out` và `uio_oe` được nối đất (gán bằng 0) vì không có giao tiếp hai chiều.

## 4. Điều kiện hợp lệ của đầu vào

| Điều kiện | Ai bảo đảm |
|---|---|
| Các cổng vào `ui_in`, `uio_in` không chứa `X`/`Z` khi lấy mẫu | Tầng ngoài |
| Tín hiệu đầu vào đã được đồng bộ với xung nhịp `clk` | Tầng ngoài |
| Chuỗi reset (`rst_n = 0`) được giữ đủ dài trước khi bắt đầu hoạt động | Tầng ngoài |
