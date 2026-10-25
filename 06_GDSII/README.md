# C07 · Tầng 06 — Kết quả Physical Design (GDSII)

Thư mục này chứa toàn bộ kết quả chạy flow RTL-to-GDSII tự động thông qua LibreLane trên GitHub Actions.

## Cấu trúc thư mục
- `gds/`: File layout cuối cùng (.gds) (nếu tải về).
- `metrics.json`: Báo cáo tổng hợp toàn bộ thông số (diện tích, cell, timing, power).
- `f03_lock_scaffold_explicit.png`: Hình ảnh layout 2D/3D.
- `drc/`, `lvs/`, `power/`, `sta/`, `synthesis/`: Các báo cáo chi tiết từng bước.

## Trạng thái
- Tổng hợp: ✅ PASS (199 std cell, 7 FF)
- Timing (Setup): ✅ PASS ở góc Typical (+2.76 ns)
- DRC: ✅ 0 vi phạm
- LVS: ✅ Pass
