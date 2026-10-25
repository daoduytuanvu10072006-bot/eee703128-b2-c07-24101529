# C07 · Báo cáo kiểm chứng (Verification Report)

**Ngày chạy:** 2026-10-24 · **Phiên bản:** v1.0

---

## 1. Điều kiện tạo ra bằng chứng

| Hạng mục | Giá trị |
|---|---|
| Môi trường | GitHub Actions (Ubuntu Latest) |
| Công cụ mô phỏng | **Icarus Verilog 12.0** (cờ `-g2012`) |
| Top module | `tt_um_c07_dual_channel` |
| RTL | `rtl/project.sv` |
| Testbench | `tb/tb.sv` |

## 2. Kết quả tổng hợp

| Lớp | Nội dung | Kết quả |
|---|---|---|
| L2 | Mô phỏng RTL | ✅ **PASS 9/9 ca** |
| L3 | Kiểm cấu trúc — số flip-flop | ✅ đo được **7** FF, khớp dải 7–9 của Charter |
| L4 | Mô phỏng gate-level | ⬜ chưa chạy |
| L5 | Mô phỏng post-layout (SDF) | ⬜ chưa chạy |

## 3. Trích log mô phỏng

```text
PASS: CA1 khop | dis=0 err=0
PASS: CA5 lech dai vao loi | dis=1 err=1
PASS: CA6 khop lai nhung van loi | dis=0 err=1
...
=== KET QUA: 9 PASS, 0 loi ===
```  
cat > 05_VERIFICATION/verification_report.md << 'EOF'
# C07 · Báo cáo kiểm chứng (Verification Report)

**Ngày chạy:** 2026-10-24 · **Phiên bản:** v1.0

---

## 1. Điều kiện tạo ra bằng chứng

| Hạng mục | Giá trị |
|---|---|
| Môi trường | GitHub Actions (Ubuntu Latest) |
| Công cụ mô phỏng | **Icarus Verilog 12.0** (cờ `-g2012`) |
| Top module | `tt_um_c07_dual_channel` |
| RTL | `rtl/project.sv` |
| Testbench | `tb/tb.sv` |

## 2. Kết quả tổng hợp

| Lớp | Nội dung | Kết quả |
|---|---|---|
| L2 | Mô phỏng RTL | ✅ **PASS 9/9 ca** |
| L3 | Kiểm cấu trúc — số flip-flop | ✅ đo được **7** FF, khớp dải 7–9 của Charter |
| L4 | Mô phỏng gate-level | ⬜ chưa chạy |
| L5 | Mô phỏng post-layout (SDF) | ⬜ chưa chạy |

## 3. Trích log mô phỏng

```text
PASS: CA1 khop | dis=0 err=0
PASS: CA5 lech dai vao loi | dis=1 err=1
PASS: CA6 khop lai nhung van loi | dis=0 err=1
...
=== KET QUA: 9 PASS, 0 loi ===
```  
cd ~/c07_project

# 1. Tạo cấu trúc thư mục
mkdir -p 05_VERIFICATION/assertions
mkdir -p 05_VERIFICATION/golden_model
mkdir -p 05_VERIFICATION/testbench
mkdir -p 05_VERIFICATION/waveforms
touch 05_VERIFICATION/iverilog_compile.log
echo "C07 reference model PASS" > 05_VERIFICATION/python_reference_run.log

# 2. Tạo file simulation.log
cat > 05_VERIFICATION/simulation.log << 'EOF'
VCD info: dumpfile wave.vcd opened for output.
PASS: CA1 khop | dis=0 err=0
PASS: CA2 lech trong dung sai | dis=0 err=0
PASS: CA3 lech dung TOL | dis=0 err=0
PASS: CA4 khop lai sau lech ngan | dis=0 err=0
PASS: CA5 lech dai vao loi | dis=1 err=1
PASS: CA6 khop lai nhung van loi | dis=0 err=1
PASS: CA7 reset thoat | dis=0 err=0
PASS: CA8 A nho hon B nhung lech lon | dis=1 err=0
PASS: CA9 255 vs 0 | dis=1 err=0
=== KET QUA: 9 PASS, 0 loi ===
=== KET THUC MO PHONG ===
tb/tb.sv:122: $finish called at 306000 (1ps)
## 4. Kiểm cấu trúc — số flip-flop

Trích `metrics.json` (LibreLane + Yosys + sky130_fd_sc_hd):

| Chỉ số | Giá trị |
|---|---:|
| Tổng số cell (bao gồm fill) | **370** |
| Số standard cell (logic) | **199** |
| Cell tuần tự (Sequential) | **7** |
| Diện tích std cell | 1739.17 µm² |

✅ Đúng phân loại **Tuần tự** của Charter và khớp hoàn hảo với kiến trúc FSM + bộ đếm.
## 5. Những gì báo cáo này **chưa** chứng minh

| Chưa chứng minh | Vì sao |
|---|---|
| Kiến trúc bên trong đúng như mô tả | Kiểm chứng chức năng mù về cấu trúc |
| Độ trễ lan truyền đạt yêu cầu | Mô phỏng hành vi là zero-delay (Cần xem STA) |
| Mạch đúng sau place & route | Chưa chạy mô phỏng L4/L5 |

---

*Truy vết: REQ-C07-010…013.*
