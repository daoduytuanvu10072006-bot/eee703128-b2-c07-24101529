# C07 · Phần điều khiển (Control)

---

## 1. Hiện trạng: C07 có đầy đủ phần điều khiển (FSM)

Charter phân loại C07 là mạch **Tuần tự** và yêu cầu một khối có bộ nhớ trạng thái thật. Thiết kế của sinh viên đã hiện thực thành công phần điều khiển này, bao gồm một bộ đếm (để lọc thời gian) và một FSM (để khoá trạng thái).

| Tín hiệu | Có phải điều khiển? | Lý do |
|---|:-:|---|
| `clk` | Không | Hạ tầng |
| `rst_n` | Có | Điều khiển ngoài, đưa toàn bộ FSM và bộ đếm về trạng thái ban đầu. |
| `disagree` (nội bộ) | **Có** | Điều khiển bộ đếm (tăng hoặc reset) và kích hoạt FSM. |
| `counter` (nội bộ) | **Có** | Trạng thái của bộ đếm, dùng để so sánh với ngưỡng `N_MAX`. |
| `error_state` (nội bộ) | **Có** | Trạng thái khoá (Lock state). Một khi lên 1, nó chặn mọi thay đổi tiếp theo. |

## 2. Các tín hiệu điều khiển thực sự trong RTL

Hệ thống điều khiển của C07 hoạt động dựa trên 2 tín hiệu nội bộ chính:
1. **`disagree` (Tín hiệu điều kiện):** Quyết định bộ đếm sẽ tăng (`disagree = 1`) hay bị xoá về 0 (`disagree = 0`).
2. **`counter == N_MAX` (Tín hiệu kích hoạt):** Khi bộ đếm đạt ngưỡng, nó phát tín hiệu chuyển trạng thái FSM sang `ERROR`.

## 3. Vị trí phần điều khiển trong hệ thống

Vì C07 đã tích hợp sẵn FSM, khối tự giải quyết được các vấn đề cốt lõi của đề bài:

| Việc | Ai làm | Ghi chú |
|---|---|---|
| Quyết định khi nào so sánh | C07 | Khối so sánh **mọi chu kỳ** |
| Cấu hình dung sai (`TOL`) | Tầng ngoài / Parameter | C07 dùng parameter `TOL = 2` |
| **Lọc bất đồng ngắn khỏi bất đồng kéo dài** | 🟢 **C07 đã làm** | Thông qua Bộ đếm 6-bit (Charter mục 4: `uo_out[7:2]`) |
| **Khoá trạng thái lỗi** | 🟢 **C07 đã làm** | Thông qua FSM `error_state` (Charter mục 4: `uo_out[1]`) |
| Quyết định phản ứng (dừng máy) | Tầng ngoài | C07 chỉ báo lỗi, không tự ngắt máy |
| Đồng bộ hai kênh | Tầng ngoài | RTL không có bộ đồng bộ |

## 4. Bảng ưu tiên điều khiển (Đã hiện thực trong RTL)

Bảng ưu tiên dưới đây được thực thi nghiêm ngặt trong khối `always` của RTL:

| Ưu tiên | Điều kiện | Trạng thái kế tiếp của `counter` | Trạng thái kế tiếp của `error_state` |
|:-:|---|---|---|
| 1 | `rst_n = 0` | `0` | `0` |
| 2 | `disagree = 0` | **`0`** ← Chữ "LIÊN TIẾP" nằm ở đây | Giữ nguyên (Không bị xoá) |
| 3 | `disagree = 1` và `counter < N_MAX` | `counter + 1` | `0` |
| 4 | `disagree = 1` và `counter == N_MAX` | `counter` (đứng yên) | **`1` (Chuyển sang lỗi)** |

*Lưu ý quan trọng:* Hàng ưu tiên số 2 chứa **hai** chi tiết dễ sai cùng lúc:
- `counter` **phải** bị xoá khi hai kênh khớp lại (tránh bẫy đếm tổng số lần thay vì đếm chuỗi liên tiếp).
- `error_state` **tuyệt đối không được xoá** (giữ nguyên tính chất khoá).

## 5. Đánh đổi an toàn ↔ khả dụng của việc “chỉ thoát bằng reset”

Charter mục 9 yêu cầu bàn về đánh đổi này. Thiết kế của sinh viên chọn giải pháp **Khoá tới khi reset**, phù hợp với bối cảnh "hệ thống an toàn".

| | Khoá tới khi reset (Thiết kế hiện tại) | Tự xoá khi hai kênh khớp lại |
|---|---|---|
| **An toàn** | ✅ Cao — một lỗi thoáng qua vẫn để lại dấu vết vĩnh viễn | ❌ Thấp — cảm biến hỏng chập chờn có thể tự xoá cờ |
| **Khả dụng** | ❌ Thấp — phải reset thủ công khi có lỗi | ✅ Cao — hệ tự phục hồi |
| **Chẩn đoán** | ✅ Giữ được bằng chứng sự cố | ❌ Mất bằng chứng |
| **Rủi ro chính** | Báo giả gây dừng máy không cần thiết | Bỏ sót lỗi thật |

Cái giá của việc "mất khả dụng" được giảm nhẹ bằng cách chọn `N_MAX` (mặc định = 8). Với ngưỡng này, hệ thống có thể bỏ qua các xung nhiễu ngắn hơn 8 chu kỳ mà không bị khoá oan. Bộ đếm chính là **nút xoay cân bằng** giữa an toàn (khoá sớm) và khả dụng (khoá muộn).
