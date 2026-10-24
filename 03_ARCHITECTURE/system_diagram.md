# C07 · Sơ đồ hệ thống (System Diagram)

---

## 1. Bối cảnh ứng dụng theo Charter mục 1

> *“Khối giám sát hai cảm biến dự phòng trong hệ thống an toàn: bất đồng kéo dài là dấu hiệu một cảm biến hỏng.”*

Đây là kiến trúc **dự phòng đôi có so sánh** (dual-redundant with comparison), mẫu cơ bản nhất trong thiết kế hệ thống an toàn. Thiết kế của sinh viên đã hiện thực thành công toàn bộ 3 nhánh đầu ra yêu cầu của Charter:

```text
  ┌─────────────┐                                    ┌──────────────────┐
  │ Cảm biến A  │──▶ ADC A ──▶ ui_in[7:0] ═══════════▶│                  │
  │ (kênh chính)│                                    │                  │
  └─────────────┘                                    │      ▓▓ C07 ▓▓   │
                                                     │                  │
  ┌─────────────┐                                    │  Datapath + FSM  │
  │ Cảm biến B  │──▶ ADC B ──▶ uio_in[7:0] ══════════▶│                  │
  │ (dự phòng)  │                                    │                  │
  └─────────────┘                                    │                  │
                                                     │                  │
        TOL=2 (từ parameter) ═══════════════════════▶│                  │
                                                     └────────┬─────────┘
                                                              │
                          ┌───────────────────────────────────┼────────────────┐
                          │                                   │                │
                          ▼ uo_out[0] (✅ ĐÃ CÓ)  ▼ uo_out[7:2] (✅ ĐÃ CÓ)  ▼ uo_out[1] (✅ ĐÃ CÓ)
                  ┌───────────────┐      ┌────────────────┐      ┌──────────────────┐
                  │ Hiển thị/log  │      │ Chẩn đoán:     │      │ LOGIC AN TOÀN:   │
                  │ "đang lệch"   │      │ lệch bao lâu   │      │ chuyển sang chế  │
                  │ (disagree)    │      │ rồi (counter)  │      │ độ an toàn (error_state) │

```

---

### KHỐI 2: Mục 2 và 3 (Lý thuyết dự phòng và Ranh giới khối)
```markdown
## 2. Vì sao hệ an toàn cần hai kênh, và vì sao hai kênh là chưa đủ

| Số kênh | Phát hiện được gì | Sửa chữa được gì | Chi phí |
|---|---|---|---|
| 1 kênh | Không phát hiện được gì | Không | 1× |
| **2 kênh (C07)** | **Phát hiện được có lỗi** (hai kênh bất đồng) | **Không** — không biết kênh nào sai | 2× |
| 3 kênh (TMR, bỏ phiếu 2/3) | Phát hiện **và** xác định kênh sai | Có — lấy giá trị đa số, vẫn chạy tiếp | 3× |

Đây là điểm bản chất cần nêu khi bảo vệ: **hệ hai kênh chỉ trả lời “có lỗi”, không trả lời “lỗi ở đâu”.** Vì vậy phản ứng đúng của hệ khi `fault` lên không phải là “tin kênh A” mà là **chuyển sang trạng thái an toàn** (dừng máy, giữ giá trị cuối, báo người vận hành). Charter mục 3 xếp ba kênh trở lên và bỏ phiếu đa số vào **ngoài phạm vi**.

## 3. Ranh giới khối

| Chức năng | Thuộc C07? | Ghi chú |
|---|:-:|---|
| Đọc cảm biến, chuyển đổi A/D | ❌ | Tầng ngoài |
| **Đồng bộ hoá hai kênh về cùng miền clock** | ❌ | **Tầng ngoài.** RTL không có bộ đồng bộ nào. |
| **Bảo đảm hai kênh được lấy mẫu cùng thời điểm** | ❌ | **Tầng ngoài.** Lệch pha lấy mẫu là nguyên nhân báo giả phổ biến. |
| Tính độ lệch tuyệt đối | ✅ | `always_comb`, 2 mạch trừ + 1 mux |
| So độ lệch với dung sai | ✅ | `diff_mag > TOL` |
| **Lọc theo thời gian (đếm liên tiếp)** | ✅ **ĐÃ CÓ** | Bộ đếm 6-bit (`counter`) |
| **Khoá trạng thái lỗi** | ✅ **ĐÃ CÓ** | FSM `error_state` (chỉ thoát bằng reset) |
| Giữ `TOL` ổn định | ❌ | Tầng ngoài (hoặc parameter trong RTL). |
| Quyết định dừng máy / chuyển chế độ an toàn | ❌ | Tầng ngoài — C07 chỉ báo, không hành động |

## 4. Phân loại khối

| Tiêu chí | Kết luận | Bằng chứng |
|---|---|---|
| Analog / Digital / Mixed | **Digital thuần** | Toàn bộ cell là standard cell `sky130_fd_sc_hd`; không có macro analog. |
| Tổ hợp / Tuần tự | **Tuần tự** | **7** `dfxtp_1` (6 counter + 1 state). Công suất tuần tự chiếm tỉ lệ đáng kể. |
| Đồng bộ / Bất đồng bộ | Đồng bộ một miền clock | Một `create_clock` trong `config.json`; reset bất đồng bộ. |
| Có FSM? | **Có FSM thật** | Xem `fsm.md` — flip-flop `error_state` có vòng hồi tiếp khoá trạng thái. |

> 🔎 So sánh nội bộ đáng nhớ: Bài mẫu của thầy (bản tham chiếu) chỉ có 1 FF và công suất tổ hợp 89,2%. Thiết kế của sinh viên đã bổ sung đầy đủ bộ đếm và FSM, nâng tổng số FF lên **7** (khớp dải dự đoán 7-9 của Charter mục 10).

## 5. Sơ đồ vòng đời RTL → GDSII, trạng thái thật

```text
  ┌────────────────┐
  │ 01 Yêu cầu     │ ✅  từ Charter C07
  └───────┬────────┘
  ┌───────▼────────┐
  │ 02 Đặc tả      │ ✅  Có đầy đủ interface, parameters, functional_spec
  └───────┬────────┘
  ┌───────▼────────┐
  │ 03 Kiến trúc   │ ✅  block · datapath · control · fsm · timing
  └───────┬────────┘
  ┌───────▼────────┐
  │ 04 RTL         │ ✅  HOÀN CHỈNH (project.sv) — Hiện thực đủ 3/3 chức năng
  └───────┬────────┘
  ┌───────▼────────┐
  │ 05 Mô phỏng RTL│ ✅ PASS   Icarus Verilog · 9 ca kiểm thử (9/9 PASS)
  └───────┬────────┘
  ┌───────▼────────┐
  │ Tổng hợp logic │ ✅ PASS   LibreLane (Yosys) → 199 std cell · 7 FF
  └───────┬────────┘
  ┌───────▼────────┐
  │ STA & CTS      │ ✅ PASS   Setup slack dương ở TT (+2.76 ns), vi phạm nhẹ ở SS (-0.07 ns)
  └───────┬────────┘
  ┌───────▼────────┐
  │ Công suất      │ ✅       Tổng ~ 0.353 mW (Đo qua metrics.json)
  └───────┬────────┘
  ┌───────▼────────┐
  │ Floorplan→Route│ ✅ CHẠY XONG bởi LibreLane (OpenROAD)
  └───────┬────────┘
  ┌───────▼────────┐
  │ DRC / LVS      │ ✅ SẠCH   (0 vi phạm DRC, LVS Pass)
  └───────┬────────┘
  ┌───────▼────────┐
  │ GDSII          │ ✅ ĐÃ SINH RA (tt_um_c07_dual_channel.gds)
  └───────┬────────┘
  ┌───────▼────────┐
  │ Sign-off       │ ⬛ NGOÀI PHẠM VI  Charter mục 3
  └───────┬────────┘
  ┌───────▼────────┐
  │ Tape-out · chế │ ⬛ NGOÀI PHẠM VI  Charter mục 3
  │ tạo thật       │
  └────────────────┘
```

**Điểm đặc biệt của vòng đời C07:** Toàn bộ chuỗi từ RTL đến GDSII đã được thực thi thành công thông qua GitHub Actions (LibreLane), tạo ra bằng chứng vật lý đầy đủ (GDS, DRC, LVS sạch). Tuy nhiên, đây là kết quả của quy trình học thuật, không phải là sign-off hay tape-out công nghiệp.

