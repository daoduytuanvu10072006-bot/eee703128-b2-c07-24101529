# C07 · Kế hoạch kiểm chứng (Test Plan)

---

## 1. Chiến lược nhiều lớp độc lập

| Lớp | Nội dung | File | Công cụ | Trạng thái |
|---|---|---|---|---|
| L0 | Mô hình chuẩn viết bằng Python (Tham chiếu) | - | CPython 3 | ✅ PASS |
| L2 | Mô phỏng RTL với testbench tự kiểm | `tb/tb.sv` | Icarus Verilog 12.0 | ✅ PASS (9/9) |
| L3 | Kiểm cấu trúc — số flip-flop phù hợp phân loại | `metrics.json` | LibreLane | ✅ 7 FF |
| L4 | Mô phỏng gate-level trên netlist | — | — | ⬜ chưa chạy |
| L5 | Mô phỏng post-layout có back-annotate SDF | — | — | ⬜ chưa chạy |

## 2. Ca kiểm thử bắt buộc theo Charter mục 8

- Hai kênh khớp · lệch trong dung sai · lệch vượt dung sai ngắn (chưa lỗi) · lệch kéo dài (vào trạng thái lỗi) · reset để thoát
- Bổ sung ít nhất hai ca tự xây dựng, trong đó có ca biên.

Danh sách thực thi và kết quả: `test_matrix.csv`.

## 3. Tiêu chí PASS/FAIL

| Lớp | Tiêu chí PASS |
|---|---|
| L0 | Mô hình Python chạy hết, không assertion nào sai |
| L2 | Testbench chạy hết, **không** assertion nào vi phạm, không `$fatal` |
| L3 | Số cell tuần tự phải nằm trong dải 7–9 (theo Charter) |

## 4. Những gì kế hoạch này **không** chứng minh

| Không chứng minh | Vì sao | Cần gì |
|---|---|---|
| Kiến trúc bên trong đúng như đặc tả | Kiểm chứng chức năng mù về cấu trúc | Đọc RTL + netlist |
| Độ trễ đạt yêu cầu | Mô phỏng hành vi không có độ trễ cổng | Báo cáo STA |
| Mạch đúng sau P&R | Chưa chạy P&R | L5 + DRC/LVS |
| Không có glitch gây hại | Mô phỏng zero-delay không sinh glitch | L5 với SDF |

---

*Phiên bản: v1.0 · Ngày: 2026-10-24*
