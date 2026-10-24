# C07 · Ca biên và ca kiểm thử (Corner Cases)

Nguồn đọc: `tb/tb.sv` (Testbench của sinh viên), `simulation.log` (Log mô phỏng từ CI).

---

## 0. Trạng thái tổng quát

Mô phỏng RTL **PASS 9/9 ca** (`simulation.log`: `=== KET QUA: 9 PASS, 0 loi ===`). 
Khác với bản tham chiếu của giảng viên (chỉ có 1 FF), thiết kế của sinh viên đã hiện thực đầy đủ **cả 3 phần** của Charter: Bộ so sánh, Bộ đếm 6-bit, và FSM khóa trạng thái lỗi. Do đó, toàn bộ 5 ca bắt buộc của Charter mục 8 đều có thể viết và đã được kiểm chứng thành công.

## 1. Ca bắt buộc của Charter mục 8 — đối chiếu testbench thật

Charter mục 8: *“Hai kênh khớp · lệch trong dung sai · lệch vượt dung sai ngắn (chưa lỗi) · lệch kéo dài (vào trạng thái lỗi) · reset để thoát”*.

| Ca Charter | Lý do kỹ thuật phải có | Có? | Bằng chứng trong `tb.sv` |
|---|---|:-:|---|
| **Hai kênh khớp** | Kiểm nhánh cơ bản và kiểm cả `ch_a == ch_b` ở hai cực | ✅ | **CA1**: `A=10, B=10` |
| **Lệch trong dung sai** | Kiểm rằng nhiễu nhỏ **không** bị báo | ✅ | **CA2**: `A=10, B=11` (lệch 1), **CA3**: `A=10, B=12` (lệch 2) |
| **Lệch vượt dung sai NGẮN (chưa lỗi)** | Kiểm bộ lọc thời gian: lệch ngắn phải nâng `disagree` nhưng **không** được kích `fault` | ✅ | **CA4**: Lệch 3 chu kỳ rồi khớp lại. Cờ `error_state` vẫn bằng 0, bộ đếm reset về 0. |
| **Lệch KÉO DÀI (vào trạng thái lỗi)** | Kiểm ngưỡng `N_MAX` và tính đơn điệu của `fault` | ✅ | **CA5**: Lệch liên tục 12 chu kỳ. `error_state` bật lên 1. |
| **Reset để thoát** | Kiểm rằng reset là **lối thoát duy nhất** khỏi trạng thái lỗi | ✅ | **CA7**: Đang ở lỗi, kéo `rst_n=0`. Mạch về trạng thái bình thường. |

**Tỷ lệ phủ ca bắt buộc: 5/5.**

## 2. Ca tự xây dựng đã có — và vì sao chúng được chọn

Testbench có 9 ca, trong đó sinh viên tự phát triển thêm 4 ca so với yêu cầu tối thiểu:

| ID | Ca | Mục đích phát hiện lỗi |
|---|---|---|
| **CA3** | Lệch đúng bằng ngưỡng `TOL` (`A=10, B=12`) | Kiểm quy ước sử dụng toán tử `>`. Lệch đúng bằng 2 phải **KHÔNG** báo bất đồng. |
| **CA6** | **Khớp lại nhưng vẫn giữ lỗi** (Từ CA5, đổi `B=10`) | **Ca quan trọng nhất**: Chứng minh cơ chế "khóa" của trạng thái lỗi. Dù 2 kênh đã khớp, `error_state` vẫn giữ nguyên 1 (chỉ reset mới xóa). |
| **CA8** | A < B nhưng lệch lớn (`A=200, B=100`) | Kiểm tính đối xứng của hàm `\|A-B\|`. Đảm bảo thuật toán trừ không bị tràn số khi số bị trừ nhỏ hơn số trừ. |
| **CA9** | Cực trị dải 8-bit (`A=255, B=0`) | Kiểm tràn số ở mức giá trị lớn nhất. |

## 3. Phân tích cái bẫy của Charter mục 10 (Bẫy đếm không liên tiếp)

Charter mục 10 cảnh báo: *"Chỗ hay tắc: Đếm bất đồng KHÔNG liên tiếp (quên xoá bộ đếm khi hai kênh khớp lại)"*.

- **Cách xử lý trong RTL:** Trong khối `always`, nếu `disagree == 0`, bộ đếm được gán `counter <= 0`.
- **Bằng chứng kiểm chứng:** Ca **CA4** trong testbench thực hiện đúng kịch bản này. Hai kênh lệch nhau 3 chu kỳ (bộ đếm lên tới 3), sau đó khớp lại (bộ đếm bị xóa về 0). Điều này chứng minh thiết kế không bị mắc bẫy "đếm tổng số lần" (sẽ dẫn đến báo động giả).

## 4. Ca KHÔNG áp dụng cho đề này

| Ca | Vì sao không áp dụng |
|---|---|
| Ba kênh trở lên, bỏ phiếu đa số (2-out-of-3) | Charter mục 3 — **ngoài phạm vi**. Hệ hai kênh không thể xác định chính xác kênh nào hỏng. |
| Tự hiệu chuẩn (bù lệch tĩnh) | Charter mục 3 — **ngoài phạm vi**. |
| Ca CDC giữa hai kênh | Thiết kế chỉ có **một** miền clock theo SDC. Bộ đồng bộ phải nằm ở tầng ngoài. |
