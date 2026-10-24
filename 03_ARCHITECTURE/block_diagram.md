# C07 · Sơ đồ khối bên trong (Block Diagram)

Vẽ theo mã nguồn RTL thực tế (`rtl/project.sv`), đối chiếu với báo cáo tổng hợp (`metrics.json`) và phân tích thời gian (STA).

---

## 1. Sơ đồ ASCII — Kiến trúc toàn mạch (Hoàn chỉnh)

Thiết kế của sinh viên đã hiện thực **đầy đủ 3 phần** của Charter: Khối so sánh độ lệch, Khối bộ đếm (6-bit), và Khối FSM khóa trạng thái lỗi.

```text
  ui_in[7:0] (A) ═══════════╗
                            ║
  uio_in[7:0] (B) ══════════╬════════════╗
                            ║            ║
                      ┌─────▼────────────▼─────┐
                      │  TÍNH ĐỘ LỆCH |A - B|  │
                      │  (Bộ trừ 8-bit + MUX)  │
                      └────────────┬───────────┘
                                   │ diff_mag[7:0]
                      ┌────────────▼───────────┐
                      │     SO SÁNH > TOL      │ (TOL = 2)
                      └────────────┬───────────┘
                                   │ disagree (Bất đồng tức thời)
                                   │
                                   ├───────────────────────────────────▶ uo_out[0]
                                   │
                      ┌────────────▼───────────┐
                      │      BỘ ĐẾM 6-BIT      │ (Reset về 0 nếu disagree = 0)
                      │  (Tăng nếu disagree=1) │
                      └────────────┬───────────┘
                                   │ counter[5:0]
                                   ├───────────────────────────────────▶ uo_out[7:2]
                                   │
                      ┌────────────▼───────────┐
                      │      FSM TRẠNG THÁI    │
     rst_n ──────────▶│ (Chuyển sang ERROR nếu│
                      │ counter đạt N_MAX = 8) │
                      └────────────┬───────────┘
                                   │ error_state
                                   └───────────────────────────────────▶ uo_out[1]


## 2. Ánh xạ cấu trúc RTL → Phần cứng sinh ra

| Khối chức năng | Cấu trúc RTL | Phần cứng sinh ra (Từ báo cáo Synthesis) |
|---|---|---|
| **Tính độ lệch** | `if (A > B) diff = A - B; else diff = B - A;` | 2 mạch trừ 8-bit (chứa các cell `maj3_1`, `xor2_1`) và 1 MUX 8-bit. |
| **So sánh ngưỡng** | `disagree = (diff > TOL);` | Bộ so sánh 8-bit (các cổng `a21oi`, `o21ai`). |
| **Bộ đếm** | `counter <= counter + 1;` | **6 Flip-flop** (`dfxtp_1`). |
| **FSM Khóa** | `else if (!error_state)` | **1 Flip-flop** cho `error_state`. Tổng cộng toàn mạch có **7 FF**. |
| **Reset** | `if (!rst_n)` | Do RTL dùng reset bất đồng bộ, flip-flop chuẩn được dùng là `dfrtp_1` (có chân Reset). |

**Ghi chú quan trọng:** Tổng số ô nhớ (Flip-flop) đo được từ `metrics.json` là **7 FF**. Con số này khớp hoàn hảo với dự đoán 7-9 FF của Charter, chứng minh thiết kế đã được hiện thực đầy đủ.

## 3. Khối con nào nằm trên đường tới hạn?

Dựa trên phân tích STA (OpenSTA):
- **Startpoint:** Chân đầu vào dữ liệu `ui_in[7]` hoặc `uio_in[7]`.
- **Endpoint:** Đầu vào D của Flip-flop bộ đếm hoặc trạng thái lỗi (`counter[5]` / `error_state`).

**Đường đi qua các giai đoạn:**
```text
 Đầu vào ─▶ [1] Bộ trừ 8-bit ─▶ [2] MUX chọn (bit dấu) ─▶ [3] Bộ so sánh TOL ─▶ [4] Logic cộng bộ đếm ─▶ FF

## 4. Đánh giá cơ chế "Khóa" (Logic Lock)

Trong sơ đồ khối ở Mục 1, phần khóa nằm ở khối **FSM Trạng thái**.
- Trong RTL, cơ chế này được thực hiện bằng cách đặt điều kiện `else if (!error_state)` trong khối `always`.
- Nếu `error_state == 1`, nhánh điều kiện này bị vô hiệu hóa, bộ đếm và trạng thái lỗi bị "đóng băng".
- Lối thoát duy nhất là tín hiệu `rst_n` (Reset), đưa toàn bộ hệ thống về 0.

Ước lượng chi phí phần cứng cho cơ chế khóa: 1 cổng OR trong vòng hồi tiếp của 1 Flip-flop.

