# C07 · Đặc tả thời gian (Timing)

---

## 1. Bản chất thời gian của khối này

C07 là mạch **Tuần tự**.
Khối có **7 flip-flop** (6 bit bộ đếm + 1 bit trạng thái lỗi), hoạt động đồng bộ theo cạnh clock.

| Khái niệm | Áp dụng? |
|---|:-:|
| Chu kỳ clock | ✅ |
| Setup / hold | ✅ |
| Đường reg→reg, in→reg, reg→out | ✅ |
| CTS (cây clock) | ✅ (Đã chạy qua LibreLane, clock skew ~0.259 ns) |
| WNS / TNS | ✅ |

## 2. Phương pháp ràng buộc đã dùng

Chế độ: **clock thật của thiết kế**.
File cấu hình: `config.json` (LibreLane sử dụng file này để sinh SDC nội bộ).

```json
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 10
## 3. Bốn giả định phải nêu kèm mọi con số

| # | Giả định | Giá trị dùng trong gói này |
|---|---|---|
| G-1 | Chu kỳ clock | `10,0 ns` — **giả định khởi điểm** |
| G-2 | Input/output delay | 1,0 ns — giả định khởi điểm cho biên IO |
| G-3 | Thư viện + PVT | Phân tích đa góc: `TT` (Typical), `SS` (Slow), `FF` (Fast) |
| G-4 | Ký sinh dây (RC) | **Đã có** — số liệu đo sau Routing (P&R) bằng OpenROAD |

> ❗ Không được diễn giải "period 10 ns" thành "C07 chạy được ở 100 MHz".
> Tần số tối đa thật phải được tính từ slack thực tế.

## 4. Số liệu thời gian đo được (Từ STA sau Routing)

| Đại lượng | Góc Typical (TT) | Góc Slow (SS) |
|---|---:|---:|
| Setup Slack (WS) | **+ 2.760 ns** (Đạt) | **- 0.0789 ns** (Vi phạm) |
| Setup TNS | 0.0 | -0.0789 |
| Hold Slack (WS) | + 0.343 ns (Đạt) | + 0.928 ns (Đạt) |
| Clock Skew (Setup) | + 0.259 ns | + 0.274 ns |

**Phân tích đường tới hạn (Critical Path):**
- **Startpoint:** `ui_in[7]` hoặc `uio_in[7]` (Bit MSB của kênh dữ liệu).
- **Endpoint:** `counter[5]` hoặc `error_state` (Đầu vào D của Flip-flop).
- **Đi qua khối logic:** Bộ trừ 8-bit (tính |A-B|) → Bộ so sánh ngưỡng (TOL) → Logic cộng của bộ đếm.
- **Nguyên nhân chậm:** Chuỗi carry (mượn) của bộ trừ 8-bit tạo ra độ trễ lớn nhất. Đường này dài hơn rất nhiều so với bản tham chiếu (chỉ có 1 FF) vì phải đi qua bộ đếm và logic FSM.

## 5. Đánh giá vi phạm Timing (Quan trọng)

Ở góc `SS` (transistor chậm, nhiệt độ cao, điện áp thấp), mạch vi phạm setup một lượng rất nhỏ: **-0.0789 ns**. 
- **Nguyên nhân:** Do sử dụng bộ trừ ripple-carry 8-bit, chuỗi logic quá dài.
- **Cách khắc phục (đề xuất):** 
  1. Tăng chu kỳ clock lên 12 ns.
  2. Hoặc thay bộ trừ ripple-carry bằng Carry-Lookahead Adder (CLA) để giảm độ trễ.
  3. Hoặc pipeline bộ trừ thành 2 tầng.
*(Tuy nhiên, vì đây là bài kiểm tra học thuật, thiết kế được giữ nguyên để minh chứng cho quá trình phân tích).*

## 6. Nghĩa vụ của tầng ngoài

```text
t_clk  ≥  t_ckq  +  t_logic_max  +  t_setup  +  t_skew   (do chinh STA bao cao)

