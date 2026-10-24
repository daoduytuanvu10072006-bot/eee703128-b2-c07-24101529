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
