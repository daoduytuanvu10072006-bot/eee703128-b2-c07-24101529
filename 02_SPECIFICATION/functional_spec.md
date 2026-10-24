# C07 · Đặc tả chức năng (Functional Specification)

---

## 0. TRẠNG THÁI: ĐÃ HIỆN THỰC ĐẦY ĐỦ 3/3 CHỨC NĂNG

Khác với bản tham chiếu (chỉ có 1 FF), thiết kế RTL của sinh viên đã hiện thực **trọn vẹn** yêu cầu của Charter C07:
1. **Bộ so sánh độ lệch** (Bất đồng tức thời).
2. **Bộ đếm bất đồng liên tiếp** (Lọc theo thời gian).
3. **FSM trạng thái lỗi khoá** (Chỉ thoát bằng reset).

### 0.1 Đối chiếu Charter mục 4 với cổng thật của module

| Charter mục 4 yêu cầu | Cổng tương ứng trong `project.sv` | Trạng thái |
|---|---|:-:|
| `ui_in[7:0]` = kênh A | `ui_in[7:0]` | ✅ có |
| `uio_in[7:0]` = kênh B | `uio_in[7:0]` | ✅ có |
| `uo_out[0]` = **bất đồng tức thời** | `uo_out[0]` | ✅ có |
| `uo_out[1]` = **trạng thái lỗi** (chỉ thoát bằng reset) | `uo_out[1]` | ✅ **CÓ** (Khắc phục lỗi W-1 của bản mẫu) |
| `uo_out[7:2]` = **bộ đếm bất đồng** (6 bit) | `uo_out[7:2]` | ✅ **CÓ** (Khắc phục lỗi W-2 của bản mẫu) |

### 0.2 Đối chiếu dấu hiệu làm đúng (Charter mục 10)

| # | Yêu cầu Charter | Bằng chứng từ `metrics.json` | Phán xử |
|---|---|---|---|
| **W-3** | Dấu hiệu làm đúng: *6 ô nhớ đếm + 1 trạng thái lỗi ≈ **7–9 ô nhớ*** | `design__instance__count__class:sequential_cell = 7` | ✅ **THOẢ** (Đo được đúng 7 flip-flop) |

---

## 1. Phát biểu bài toán
Khối nhận hai giá trị 8 bit từ hai cảm biến dự phòng (`ui_in`, `uio_in`). Mỗi chu kỳ clock, khối tính độ lệch tuyệt đối và so với ngưỡng dung sai. Nếu độ lệch vượt ngưỡng liên tiếp trong nhiều chu kỳ, khối sẽ chuyển sang trạng thái lỗi vĩnh viễn (chỉ thoát bằng reset).

## 2. Định nghĩa toán học
diff_mag = | ch_a − ch_b | (dây tổ hợp, 8 bit)
disagree = 1 khi diff_mag > TOL (TOL mặc định = 2)

> **Quy ước biên:** Sinh viên sử dụng toán tử **`>` (lớn hơn)**. Độ lệch **bằng đúng** ngưỡng `TOL` **KHÔNG** tính là bất đồng.
> *Lưu ý: Điều này ngược lại với quy ước `>=` của bản tham chiếu, và đã được kiểm chứng nhất quán trong toàn bộ testbench.*

## 3. Đặc tả tín hiệu ra

| Tín hiệu | Định nghĩa | Loại |
|---|---|---|
| `uo_out[0]` (`disagree`) | Bằng 1 nếu `diff > TOL`. Về 0 ngay chu kỳ sau khi hai kênh khớp lại. | Tổ hợp (kết hợp với đầu ra) |
| `uo_out[7:2]` (`counter`) | Đếm số chu kỳ `disagree = 1` liên tiếp. Tự động reset về 0 khi `disagree = 0`. | Tuần tự (6 flip-flop) |
| `uo_out[1]` (`error_state`) | Bằng 1 khi `counter` đạt ngưỡng `N_MAX` (mặc định 8). Khi đã lên 1, nó sẽ giữ nguyên 1. | Tuần tự (1 flip-flop) |

## 4. Trạng thái sau reset
`rst_n` tích cực mức thấp, **bất đồng bộ** (asynchronous reset).

| Tín hiệu | Sau khi `rst_n = 0` |
|---|---|
| `counter` | `0` |
| `error_state` | `0` |

## 5. Bảng chuyển trạng thái (FSM + Counter)

| Trạng thái hiện tại | `disagree` | Trạng thái kế tiếp | Hành động |
|:-:|:-:|---|---|
| NORMAL (`err=0`) | 0 | NORMAL (`err=0`) | `counter = 0` |
| NORMAL (`err=0`) | 1 | NORMAL (`err=0`) | `counter = counter + 1` |
| NORMAL (`err=0`) | 1 | **ERROR (`err=1`)** | Xảy ra khi `counter == N_MAX - 1` |
| ERROR (`err=1`) | × | **ERROR (`err=1`)** | Giữ nguyên `counter` và `err` (Không quan tâm input) |

## 6. Độ trễ
- `disagree` phản ánh đầu vào tức thời (tổ hợp).
- `counter` cập nhật sau mỗi cạnh lên clock.
- `error_state` cập nhật sau cạnh lên clock khi điều kiện ngưỡng được thoả.

## 7. Tính chất bất biến (Invariants)

| ID | Phát biểu | Bằng chứng |
|---|---|---|
| **INV-1** | **Đối xứng:** `disagree(a,b) == disagree(b,a)` | Testbench (CA8, CA9) kiểm tra cả hai chiều. |
| **INV-2** | **Không tràn số:** `diff_mag` luôn nằm trong `[0,255]`. | Dùng nhánh if/else để đảm bảo số bị trừ luôn lớn hơn hoặc bằng. |
| **INV-3** | **Khóa trạng thái (INV-F1):** Một khi `error_state = 1`, nó không bao giờ tự về 0 trừ khi `rst_n = 0`. | Netlist có 7 FF và vòng hồi tiếp OR. Testbench CA6 chứng minh. |
| **INV-4** | **Xóa bộ đếm (INV-F3):** `counter` lập tức về 0 khi `disagree = 0`. | Testbench CA4 kiểm tra bẫy "không liên tiếp". |

## 8. Điều kiện biên và hành vi không xác định

| Tình huống | Hành vi | Trạng thái |
|---|---|---|
| `ch_a == ch_b` | `disagree = 0`, `counter` giữ nguyên 0 | ✅ Đã kiểm (CA1) |
| `|ch_a − ch_b| == TOL` | **Không tính là bất đồng** (dùng `>`). | ✅ Đã kiểm (CA3) |
| Bất đồng ngắt quãng | Bộ đếm lập tức về 0, không bao giờ báo lỗi | ✅ Đã kiểm (CA4) |
| Đã lỗi, hai kênh khớp lại | `disagree = 0` nhưng `error_state` vẫn = 1 | ✅ Đã kiểm (CA6) |

## 9. Cơ chế thực hiện logic "khoá" (Charter mục 9)

Theo yêu cầu của Charter, phần logic thực hiện việc "khoá" trạng thái lỗi nằm ở cấu trúc điều kiện trong khối `always`:

```systemverilog
end else if (!error_state) begin
    // Chỉ xử lý khi CHƯA lỗi. Nếu error_state == 1, khối này bị bỏ qua hoàn toàn.
    // Do đó, error_state và counter giữ nguyên giá trị.
