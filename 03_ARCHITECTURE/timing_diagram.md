# C07 · Giản đồ thời gian (Timing Diagram)

---

## 0. Quy ước đọc giản đồ

- **Cạnh `n`** = cạnh lên thứ `n` của `clk`.
- Hàng **“trước cạnh n”** = giá trị tổ hợp ổn định ngay trước cạnh, tức giá trị flip-flop thực sự lấy mẫu.
- Hàng **“sau cạnh n”** = giá trị `Q` sau cạnh đó.
- Testbench dùng `always #5 clk = ~clk` nên chu kỳ là **10 đơn vị thời gian**.

> ⚠️ **Waveform thu từ mô phỏng hành vi (zero-delay) bằng Icarus Verilog.** Tín hiệu đổi giá trị đúng tại cạnh clock; không có `t_ckq`, không có độ trễ cổng, **không có glitch**. Nó chứng minh **giá trị và số chu kỳ**, không chứng minh gì về độ trễ thật. 

---

## 1. Toàn bộ giao dịch của testbench — Các ca kiểm thử quan trọng

Lấy **đúng từ** `tb/tb.sv` (9 ca kiểm thử). Dưới đây trích xuất giản đồ thời gian cho các ca then chốt (CA4, CA5, CA6) để chứng minh cơ chế đếm và khóa hoạt động đúng.

Giả sử `TOL = 2`, `N_MAX = 8`. 

```text
 Cạnh số:      1    2    3    4    5    6    7    8    9   10   11   12   13   14
 clk      ─────↑────↑────↑────↑────↑────↑────↑────↑────↑────↑────↑────↑────↑────↑──

 A (ui_in)     10   10   10   10   10   10   10   10   10   10   10   10   10   10
 B (uio_in)    50   50   50   10   10   50   50   50   50   50   50   50   50   10
 ───────────────────────────────────────────────────────────────────────────────
 disagree      1    1    1    0    0    1    1    1    1    1    1    1    1    0
               └─ CA4: Lệch 3 chu kỳ ─┘└Khớp┘└──────── CA5: Lệch liên tục ────────┘

 counter       1    2    3    0    0    1    2    3    4    5    6    7    8    8
               └──────────────────────┘└─────────────────────────────────────────

 error_state   0    0    0    0    0    0    0    0    0    0    0    0    1    1
                                                               ▲
                                                         Vào lỗi tại cnt=8
```
## 2. Ba mốc đáng đọc kỹ

| Mốc | Xảy ra gì | Ý nghĩa |
|---|---|---|
| **Cạnh 3 → 4** | Độ lệch biến mất (A=10, B=10). `disagree` từ 1 về 0. `counter` từ 3 **xoá về 0** ngay lập tức. | **Chốt cơ chế "đếm liên tiếp":** Bộ đếm chỉ đếm các chuỗi bất đồng liên tiếp. Nếu quên xoá, mạch sẽ đếm tổng số lần lệch (dẫn đến báo giả). Đây là cái bẫy của Charter mục 10. |
| **Cạnh 12 → 13** | `counter` đạt giá trị 8 (bằng `N_MAX`). `error_state` chuyển từ **0 lên 1**. | **Chứng minh FSM hoạt động:** Hệ thống phát hiện lỗi hệ thống sau 8 chu kỳ bất đồng liên tiếp. Tín hiệu `error_state` được kích hoạt. |
| **Cạnh 13 → 14** | Hai kênh khớp lại (A=10, B=10), `disagree` về 0. Nhưng `error_state` **vẫn giữ nguyên 1**. | **Chứng minh cơ chế khóa (CA6):** Một khi đã vào trạng thái lỗi, hệ thống không tự phục hồi dù cảm biến đã hết bất đồng. Lối thoát duy nhất là reset (`rst_n = 0`). |

## 3. So sánh ba tín hiệu (Đã hiện thực đầy đủ)

Giản đồ trên cho thấy rõ ba tầng ngữ nghĩa của thiết kế C07 hoàn chỉnh:

```text
 ── Bất đồng tức thời ──────────────────────────────────────────────────────────
 disagree      ┌──────────────┐         ┌──────────────────────────────┐
          ─────┘              └─────────┘                              └──────
               (Nhạy: Nhiễu ngắn cũng làm nó lên, về 0 ngay khi khớp lại)

 ── Bộ đếm thời gian ───────────────────────────────────────────────────────────
 counter       1  2  3  0  0  1  2  3  4  5  6  7  8  8
               └─── Xoá về 0 khi khớp ──┘  (Nút xoay: Đo độ dài chuỗi bất đồng)

 ── Trạng thái lỗi khoá ────────────────────────────────────────────────────────
 error_state                          ┌──────────────────────────────────────
          ────────────────────────────┘      (Khoá: Chỉ reset mới xoá được)
```

Ba hàng này trả lời trọn vẹn câu hỏi 1 của Charter mục 2 (*“vì sao cần cả bất đồng tức thời lẫn trạng thái lỗi”*):
- `disagree` **nhạy nhưng không đáng tin** — dùng nó làm tín hiệu dừng máy sẽ gây dừng oan liên tục do nhiễu.
- `error_state` **đáng tin nhưng chậm** — nó chỉ lên sau `N_MAX` chu kỳ liên tiếp, và không bao giờ tự xuống.
- `counter` là **nút xoay giữa hai thái cực đó**, đồng thời là tín hiệu chẩn đoán cho người vận hành.

## 4. Giản đồ này chứng minh gì và **không** chứng minh gì

| Câu hỏi | Waveform hành vi trả lời được? | Cần gì để trả lời |
|---|:-:|---|
| Bộ đếm có reset khi hết bất đồng? | ✅ (CA4) | — |
| Trạng thái lỗi có được kích hoạt đúng ngưỡng? | ✅ (CA5) | — |
| Cơ chế khoá trạng thái có hoạt động? | ✅ (CA6) | — |
| Quy ước biên là `>` hay `>=`? | ✅ (CA3) | — |
| Phép trừ có tràn khi lệch 255 không? | ✅ (CA9) | — |
| **Dữ liệu có kịp tới trước cạnh clock không?** | ❌ | STA: arrival **~7.24 ns** vs required 10 ns → slack **+2.76 ns** |
| **Có bao nhiêu glitch trên `diff_mag`?** | ❌ — waveform zero-delay **không sinh glitch** | Mô phỏng gate-level có SDF |
| Công suất thật là bao nhiêu? | ❌ | VCD thật; con số 0.353 mW hiện dùng hoạt động mặc định |

**Nối hai thế giới.** Trong waveform, các chuyển đổi diễn ra tức thời. Trong thực tế, khi A và B đảo hoàn toàn (ví dụ CA9: từ 0 sang 255), cả hai chuỗi borrow, bit dấu, sáu mux và chuỗi so sánh thứ hai đều phải lật — đây là khoảng thời gian glitch nặng nhất và tốn công suất động nhất. Waveform zero-delay hiển thị nó như một cột sạch sẽ.

## 5. Ghi chú về cách viết testbench

Hai chi tiết trong `tb.sv` đáng nêu:
1. **Kiểm tra tự động (Self-checking):** Testbench sử dụng task `check()` để tự động so sánh kết quả với giá trị mong đợi và in ra `PASS`/`FAIL`. Đây là cách làm chuẩn công nghiệp.
2. **Reset bất đồng bộ:** Hệ thống được reset ngay khi bắt đầu mô phỏng (`rst_n = 0` trong 20ns đầu) để đảm bảo trạng thái ban đầu xác định, sau đó mới chạy các ca kiểm thử.


