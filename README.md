# EEE703128 — Bài kiểm tra số 2 — C07

**Đề tài:** Bộ so sánh hai kênh dự phòng và báo bất đồng  
**Sinh viên:** Đào Duy Tuấn Vũ  — MSSV[24101529]  
**Giảng viên:** Đinh Văn Nam

## Cấu trúc
- `src/project.v` — RTL thiết kế
- `test/tb.v` — Testbench 6 ca kiểm thử

## Cách chạy mô phỏng
```bash
iverilog -o sim.vvp test/tb.v src/project.v
vvp sim.vvp
gtkwave wave.vcd

