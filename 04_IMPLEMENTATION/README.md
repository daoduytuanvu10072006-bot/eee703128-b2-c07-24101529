# C07 · Tầng 04 — Hiện thực (Implementation)

---

## 1. Nội dung thư mục

```text
04_IMPLEMENTATION/
├── rtl/               project.sv (Top module: tt_um_c07_dual_channel)
├── constraints/       (Sử dụng config.json của LibreLane)
├── scripts/           config_librelane.json
└── README.md
```

---

### KHỐI 2: Quy trình chạy và Sửa đổi nguồn
## 2. Thứ tự chạy (trên máy local hoặc CI)

Quy trình RTL-to-GDSII đã được tự động hóa hoàn toàn thông qua GitHub Actions (file `.github/workflows/rtl2gds.yml`).
Kết quả chạy thực tế trên CI:
- **Mô phỏng RTL (Icarus):** ✅ PASS (9/9 ca kiểm thử)
- **Tổng hợp & PnR (LibreLane + sky130A):** ✅ PASS (Đã sinh file GDS, DRC sạch)

## 3. Sửa nguồn tối thiểu đã áp dụng

Nguồn gốc lấy từ thiết kế của sinh viên. Các sửa đổi sau đã được áp dụng để biên dịch được bằng Icarus Verilog 12.0 và tuân thủ chuẩn Tiny Tapeout:
- Đổi tên module thành `tt_um_c07_dual_channel` với đầy đủ các chân `ui_in`, `uio_in`, `uo_out`, `ena`, `clk`, `rst_n`.
- Sử dụng `parameter` cho TOL và N_MAX thay vì cổng vào để tiết kiệm chân.

## 4. Môi trường đã dùng để sinh bằng chứng (Trên GitHub Actions)

| Công cụ | Phiên bản |
|---|---|
| Mô phỏng | Icarus Verilog 12.0 (stable) |
| Tổng hợp & PnR | LibreLane (sử dụng Nix) |
| PDK | sky130A |

---

*Phiên bản: v1.0 · Ngày: 2026-10-24*

