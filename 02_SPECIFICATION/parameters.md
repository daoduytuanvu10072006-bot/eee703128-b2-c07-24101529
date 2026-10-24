# C07 · Tham số và cấu hình (Parameters)

---

## 1. Tham số thiết kế chốt từ Charter

| Tham số | Giá trị | Có được đổi không | Nguồn |
|---|---|---|---|
| Loại mạch | **Tuần tự** | ❌ | Charter metadata |
| Nhóm đề | C · Ngưỡng, cảnh báo và giám sát | ❌ | Charter metadata |
| Độ khó | Trung bình | — | Charter metadata |
| Quy mô ước lượng | ~230–320 cell · 1×1 tile | — | Charter metadata |
| Top module | `tt_um_c07_dual_channel` | ❌ | RTL (Tiny Tapeout format) |
| Số flip-flop mong đợi | 7 - 9 | ❌ | Charter mục 10 |
| Chu kỳ clock (giả định) | 10 ns (100 MHz) | ✅ | `config.json` |

## 2. Môi trường công cụ đã dùng để sinh bằng chứng

| Hạng mục | Giá trị |
|---|---|
| Môi trường chạy | **GitHub Actions (Ubuntu Latest)** |
| Mô phỏng | **Icarus Verilog 12.0** (cờ `-g2012`) |
| Flow RTL-to-GDSII | **LibreLane** (qua Nix) |
| Thư viện standard cell | `sky130_fd_sc_hd` |
| Góc PVT phân tích | TT (typical), SS (slow), FF (fast) |
| PDK đích cho P&R | **sky130A** |
| Trạng thái Flow P&R | **Đã chạy thành công ra GDSII** |

> ⚠️ Mọi con số cell, diện tích, timing, công suất trong hồ sơ này gắn chặt với **đúng** tổ hợp trên. Đổi bất kỳ thành phần nào thì số liệu đổi theo. Charter mục 6 yêu cầu nêu **điều kiện tạo ra bằng chứng** — bảng này chính là điều kiện đó.
>
> **Không so sánh chéo** số liệu giữa các đề nếu chúng chạy trên môi trường khác nhau.

## 3. Số liệu đo được (Từ file `metrics.json`)

| Chỉ số | Giá trị | Nguồn |
|---|---:|---|
| Tổng số cell (gồm cả fill/tap) | 370 | `metrics.json` |
| Số standard cell (logic) | 199 | `metrics.json` |
| Số Flip-flop (Sequential) | **7** | `metrics.json` (khớp dự đoán 7-9) |
| Diện tích tổng | 2254.66 µm² | `metrics.json` |
| Diện tích std cell (logic thật) | 1739.17 µm² | `metrics.json` |
| Setup Slack (Góc Typical - TT) | **+2.760 ns** | `metrics.json` (Đạt) |
| Setup Slack (Góc Slow - SS) | **-0.0789 ns** | `metrics.json` (Vi phạm nhẹ) |
| Hold Slack (Góc Typical - TT) | +0.343 ns | `metrics.json` (Đạt) |
| Tổng công suất (ước lượng) | 0.353 mW | `metrics.json` |
| Tỷ lệ công suất động | ~ 61 % | `metrics.json` (Internal) |
| Tỷ lệ công suất rò | ~ 0 % (2.46 nW) | `metrics.json` (Leakage) |

## 4. Cấu hình máy đọc được

Xem `config.json` ở thư mục gốc của repository.
