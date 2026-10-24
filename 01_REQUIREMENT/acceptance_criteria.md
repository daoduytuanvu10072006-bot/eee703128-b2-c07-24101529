# C07 · Tiêu chí đạt (Acceptance Criteria)

Nguồn: **Charter C07 mục 6**, cộng các tiêu chí suy ra từ mục 8 và mục 9.
Trạng thái: ✅ ĐẠT (có bằng chứng do tool sinh) · ⚠️ CÓ VẤN ĐỀ · ⬜ CHƯA CHẠY · 🟡 MỞ.

---

## 1. Bốn tiêu chí gốc của Charter (mục 6)

- Bảng giao diện đầy đủ, nhất quán với đặc tả; tín hiệu nào cũng có chiều và độ rộng.
- Mỗi khẳng định đi kèm bằng chứng và điều kiện tạo ra bằng chứng đó.
- Trả lời câu phân tích riêng bằng dữ liệu của chính mình.
- Nêu giới hạn trung thực; không dùng phát biểu vượt mức như “đã sign-off”.

| # | Tiêu chí | Cách kiểm | Bằng chứng | Trạng thái |
|---|---|---|---|---|
| AC-1 | Bảng giao diện đầy đủ, nhất quán với đặc tả | Đối chiếu bảng với cổng module trong RTL | RTL `project.sv` và Báo cáo Mục 1 | ✅ |
| AC-2 | Mỗi khẳng định kèm bằng chứng và điều kiện tạo ra | Rà từng dòng trong báo cáo | Báo cáo PDF (Mục 4, 5, 6) | ✅ |
| AC-3 | Trả lời câu phân tích riêng bằng dữ liệu của chính mình | Charter mục 9 | Báo cáo PDF (Mục 8) + Artifacts | ✅ |
| AC-4 | Nêu giới hạn trung thực, không phát biểu vượt mức | Quét kết luận | Báo cáo PDF (Mục 9) | ✅ |

## 2. Tiêu chí chức năng

| # | Tiêu chí | Bằng chứng | Trạng thái |
|---|---|---|---|
| AC-5 | Mô hình chuẩn Python chạy PASS (nếu có) | (Không bắt buộc, dùng testbench SV) | - |
| AC-6 | Mô phỏng RTL chạy hết testbench, không assertion nào vi phạm | `simulation.log` (9 PASS, 0 FAIL) | ✅ |
| AC-7 | Ca kiểm thử bắt buộc của Charter đều có trong testbench | `tb.sv` (có đủ 9 ca) | ✅ |
| AC-8 | Có artifact số (waveform / báo cáo) làm bằng chứng | Artifacts CI (wave.vcd, metrics.json) | ✅ |

## 3. Tiêu chí cấu trúc phần cứng

| # | Tiêu chí | Ngưỡng | Đo được | Trạng thái |
|---|---|---|---|---|
| AC-9 | Số flip-flop phù hợp phân loại Charter **Tuần tự** | 7 - 9 FF | 7 | ✅ |
| AC-10 | Quy mô cell hợp lý cho 1×1 tile | < 2 000 cell | 199 | ✅ |
| AC-11 | RTL tổng hợp được ra standard cell sky130 | không lỗi | PASS | ✅ |

## 4. Tiêu chí thời gian

| # | Tiêu chí | Đo được | Trạng thái |
|---|---|---|---|
| AC-12 | Có báo cáo STA do chính mình sinh | PASS | ✅ |
| AC-13 | Xác định được đường tới hạn (startpoint → endpoint) | `uio_in[7]` → `counter[5]` | ✅ |
| AC-14 | Nêu rõ giả định timing khi báo số | Clock 10ns, Góc TT & SS | ✅ |
| AC-14b| Vi phạm Setup ở góc chậm (SS) | -0.0789 ns | ⚠️ |

## 5. Tiêu chí vật lý

| # | Tiêu chí | Trạng thái |
|---|---|---|
| AC-15 | Floorplan / Placement / Routing | ✅ (LibreLane) |
| AC-16 | DRC sạch | ✅ (0 vi phạm) |
| AC-17 | LVS khớp | ✅ (Pass) |
| AC-18 | Sinh được file GDSII | ✅ (Đã có GDS) |
