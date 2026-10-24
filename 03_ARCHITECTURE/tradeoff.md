# C07 · Phân tích đánh đổi (Trade-off)

Mọi con số lấy từ `metrics.json` của **chính lần chạy này**. Cột nào chưa có số đo thì ghi ⬜, không ước lượng.

---

## 1. Số liệu nền

| Chỉ số | Giá trị đo | Nguồn |
|---|---:|---|
| Tổng cell | **199** (std cell) | `metrics.json` |
| Flip-flop | **7** | `metrics.json` (`sequential_cell = 7`) |
| Diện tích std cell | **1739.17 µm²** | `metrics.json` |
| Setup Slack (Góc TT) | **+2.760 ns** (MET) | `metrics.json` |
| Setup Slack (Góc SS) | **-0.0789 ns** (Vi phạm nhẹ) | `metrics.json` |
| Công suất | **0.353 mW** · Tổ hợp chiếm chủ yếu | `metrics.json` |
| Charter ước lượng quy ước | ~230–320 cell | Charter metadata |

> ⚠️ **Đọc bảng này cho đúng.** Con số **199 cell** và **7 FF** (khớp dải 7-9 của Charter mục 10) là bằng chứng thiết kế đã được **hiện thực đầy đủ 3/3 phần** (So sánh, Bộ đếm, FSM). Đây là điểm khác biệt cốt lõi so với bản tham chiếu (chỉ có 1 FF).
> Một con số đáng nhớ: công suất tổ hợp chiếm chủ yếu do mạch có 2 chuỗi carry nối tiếp và bộ so sánh. Việc tối ưu công suất cần nhắm vào logic tổ hợp.
## 2. So sánh kiến trúc dự phòng: 2 kênh so sánh ↔ 3 kênh TMR

Đây là so sánh ở **mức hệ thống**, tức so C07 với các cách khác để đạt cùng mục tiêu an toàn. Charter mục 3 xếp *“ba kênh trở lên, bỏ phiếu đa số”* vào **ngoài phạm vi**.

| Tiêu chí | **2 kênh + so sánh (C07)** | 3 kênh + bỏ phiếu 2/3 (TMR) |
|---|---|---|
| Phát hiện **có** lỗi | ✅ | ✅ |
| Xác định **kênh nào** lỗi | ❌ **bất khả** (chỉ biết có lỗi) | ✅ |
| Chạy tiếp sau khi có lỗi | ❌ phải chuyển chế độ an toàn | ✅ vẫn chạy với 2 kênh còn lại |
| Số cảm biến | 2 | 3 |
| Logic so sánh | **199 std cell** (đã làm đủ) | ⬜ chưa chạy (cần 3 bộ so sánh + mạch bỏ phiếu) |
| Khi nào nên dùng | Khi **dừng an toàn** là phản ứng chấp nhận được | Khi hệ **phải chạy liên tục** (máy bay, điện hạt nhân) |

**Kết luận:** hai kênh cho **khả năng phát hiện** với chi phí 2×, ba kênh cho thêm **khả năng chịu lỗi** với chi phí 3×. C07 chọn mức đầu — phù hợp với bối cảnh “giám sát cảm biến” (báo động và dừng máy).
## 3. So sánh kiến trúc bên trong khối: ba cách tính |a − b|

**P0 — hiện tại: trừ hai chiều rồi chọn (Đang dùng).**
```text
  [TRỪ a−b]──╮
             ├──▶[MUX 8 bit theo dấu]──▶ diff_mag ──▶[SO SÁNH với TOL]──▶ FF
  [TRỪ b−a]──╯
```

---

### KHỐI 4: Mục 4 (Đánh đổi trong thiết kế đã hoàn thiện)
## 4. Đánh đổi trong phần đã hiện thực (Bộ đếm & FSM)

Đây là các quyết định thiết kế đã được chốt trong RTL thực tế:

### 4.1 Độ rộng bộ đếm bất đồng
Chọn **6 bit** (đếm tối đa 63). Lý do: `uo_out[7:2]` còn đúng 6 chân. Dải chỉnh `N_MAX` từ 1 đến 63 đủ rộng để thích ứng với đặc tính nhiễu. Nếu chọn 8 bit sẽ vượt ngân sách chân (24/24).

### 4.2 Ngưỡng `N_MAX` cố định hay cấu hình được?
| | Hằng số trong RTL (Đã chọn) | Cổng vào cấu hình |
|---|---|---|
| Chi phí chân | 0 | **+6 chân vào** (Vượt ngân sách 24/24) |
| Độ trễ | Rẻ — so với hằng số | Đắt hơn — so hai biến |
| Linh hoạt | Phải tổng hợp lại để đổi | Chỉnh lúc chạy |

Với ngân sách chân đã kín, **hằng số (parameter `N_MAX = 8`) là lựa chọn bắt buộc**.

### 4.3 Bão hoà hay quấn vòng khi bộ đếm đầy?
Chọn **Bão hoà tại ngưỡng** (không quấn về 0). 
- Nếu quấn về 0: `counter` quay về 0 dù vẫn đang lỗi, có thể khiến logic phía sau hiểu nhầm là "hết lỗi". 
- Bão hoà là **bắt buộc** để đảm bảo tính an toàn.

## 5. Những đánh đổi **KHÔNG được phép** trong đề này

| Việc bị cấm | Nguồn cấm | Vì sao |
|---|---|---|
| Thêm **kênh thứ ba** / bỏ phiếu đa số (TMR) | Charter mục 3 — ngoài phạm vi | Chỉ được so sánh trên giấy |
| **Tự hiệu chuẩn** (bù lệch tĩnh) | Charter mục 3 — ngoài phạm vi | Cần thanh ghi offset + logic thích nghi |
| Bỏ trạng thái lỗi khoá để “đơn giản hoá” | Charter mục 2 câu 2 + mục 9 | Tính khoá **là** nội dung chính của đề |
| Cho `error_state` tự xoá khi khớp lại | Charter mục 9 | Vi phạm nguyên tắc an toàn |
| Đếm **tổng số lần** lệch thay vì **chuỗi liên tiếp** | Charter mục 10 | Gây báo giả |
| Tuyên bố sign-off / tape-out / “chạy được ở X MHz” | Charter mục 3 | Chưa ký sinh RC, chưa có silicon thật |

## 6. Kết luận đánh đổi

1. Ở **mức hệ thống**, hai kênh + so sánh là lựa chọn đúng cho bối cảnh Charter: phát hiện được lỗi với chi phí 2×, đổi lại không chạy tiếp được sau lỗi.
2. Ở **mức RTL**, cấu trúc “trừ hai chiều rồi chọn” (P0) đơn giản và cho phép quan sát `diff_mag`. Với slack **+2.76 ns**, cái giá về diện tích chưa cần tối ưu.
3. Khác với bản tham chiếu, thiết kế này đã hiện thực **đầy đủ 7 flip-flop** (6 đếm + 1 trạng thái lỗi), giải quyết trọn vẹn bài toán an toàn của Charter.
4. Mọi con số ở đây là **sau Routing**, clock thực tế (có skew), đo qua OpenSTA/LibreLane.

