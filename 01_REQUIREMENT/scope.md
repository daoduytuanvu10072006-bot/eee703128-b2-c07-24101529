# C07 · Phạm vi (Scope)

Trích và cấu trúc hoá từ **Project Charter — C07, mục 3**.

---

## 1. TRONG PHẠM VI

Tám thành phần bắt buộc của hồ sơ: bối cảnh ứng dụng · sơ đồ khối hệ thống · phân loại analog/digital/mixed · bảng giao diện của chính khối này · một artifact số có chú thích · sơ đồ vòng đời · RTM-lite (yêu cầu → khối → bằng chứng → giới hạn) · kết luận và giới hạn.

### Tám thành phần bắt buộc nằm ở đâu trong cây thư mục này

| # | Thành phần | Vị trí |
|---|---|---|
| 1 | Bối cảnh ứng dụng | `01_REQUIREMENT/application.md` §1 |
| 2 | Sơ đồ khối hệ thống | `03_ARCHITECTURE/system_diagram.md` (sẽ bổ sung) |
| 3 | Phân loại analog / digital / mixed | `01_REQUIREMENT/application.md` §3 |
| 4 | Bảng giao diện của chính khối này | `02_SPECIFICATION/interface.md` §2 (sẽ bổ sung) |
| 5 | Một artifact số có chú thích | `05_VERIFICATION/waveforms/` · `06_GDSII/synthesis/` (sẽ bổ sung) |
| 6 | Sơ đồ vòng đời | `03_ARCHITECTURE/system_diagram.md` (sẽ bổ sung) |
| 7 | RTM-lite | `07_TRACEABILITY/RTM.csv` (sẽ bổ sung) |
| 8 | Kết luận và giới hạn | `07_TRACEABILITY/limitations.md` (sẽ bổ sung) |

## 2. MỞ RỘNG — Luồng Vật lý (Physical Flow)

**Đã hoàn thành:** Sinh viên đã chạy thành công chuỗi công cụ RTL-to-GDSII tự động bằng LibreLane với PDK sky130A trên máy chủ GitHub Actions (thông qua workflow `rtl2gds.yml`).
- **Bằng chứng:** File `metrics.json`, file GDS (`tt_um_c07_dual_channel.gds`) và các báo cáo DRC/LVS được đính kèm trong mục Artifacts của lần chạy CI thành công trên GitHub.

## 3. NGOÀI PHẠM VI

Ba kênh trở lên, bỏ phiếu đa số, tự hiệu chuẩn. Với mọi đề: thiết kế analog mức transistor, tự làm physical design, ASIC sign-off, tape-out, chế tạo và kiểm tra sau chế tạo.

> ❗ Hệ quả về cách viết kết luận: **không** được dùng phát biểu vượt mức như "đã sign-off", "đã tape-out", "đã chế tạo", "đã kiểm tra trên silicon".
