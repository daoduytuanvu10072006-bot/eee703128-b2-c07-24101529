# C07 · Máy trạng thái (FSM)

---

## 1. Kết luận ngắn

**RTL của sinh viên CÓ FSM**, đáp ứng đúng yêu cầu của Charter C07 (yêu cầu chỉ ra logic khoá trạng thái lỗi). Thiết kế đã khắc phục được điểm yếu của bản tham chiếu bằng cách tích hợp thành công bộ đếm 6-bit và trạng thái lỗi khoá, giúp mạch trở thành một hệ thống tuần tự hoàn chỉnh.

## 2. Bằng chứng cho việc "CÓ FSM"

Một FSM cần thanh ghi trạng thái và hàm chuyển đọc trạng thái hiện tại. Thiết kế đã có đủ cả hai:

| # | Bằng chứng | Nguồn | Kết luận |
|---|---|---|---|
| **B-1** | RTL có biến `error_state` được gán trong khối `always @(posedge clk or negedge rst_n)` | `rtl/project.sv` | Có thanh ghi trạng thái thực sự |
| **B-2** | Netlist có **7** cell tuần tự (6 cho counter, 1 cho error_state) | `metrics.json` (`sequential_cell = 7`) | Khớp với thiết kế FSM |
| **B-3** | Trạng thái lỗi có cơ chế khoá (vòng hồi tiếp): khi `error_state == 1`, điều kiện `else if (!error_state)` bị vô hiệu hoá, bộ đếm và trạng thái bị "đóng băng" | `rtl/project.sv` | Có hàm chuyển phụ thuộc trạng thái (vòng hồi tiếp Q -> Logic -> D) |
| **B-4** | Bảng chuyển trạng thái có nhắc tới trạng thái hiện tại (xem Mục 4) | Tài liệu này | Trạng thái kế phụ thuộc cả đầu vào và trạng thái hiện tại |

**Quy tắc nhận biết:** Một FSM thực sự có vòng hồi tiếp. Khi `error_state` đã lên 1, nó chặn không cho bộ đếm và chính nó thay đổi giá trị, tạo thành vòng khoá `Q -> Logic -> D`.


## 3. Đồ thị trạng thái hiện có

Hệ thống có 2 trạng thái, chuyển dịch dựa trên tín hiệu `disagree` và giá trị bộ đếm:

```text
                      ┌─────────────────────────────────┐
                      │                                 │
                      ▼                                 │
                ┌───────────┐                           │
   reset ──────▶│  NORMAL   │                           │
                │ (err = 0) │───────┐                   │
                │ (cnt = 0) │       │                   │
                └───────────┘       │ disagree = 1      │
                      ▲             │ & cnt < N_MAX     │
                      │             ▼                   │
                      │       ┌───────────┐             │
                      │       │  NORMAL   │             │
                      │       │ (err = 0) │             │
                      │       │ cnt = cnt+1│            │
                      │       └─────┬─────┘             │
                      │             │                   │
    rst_n = 0         │             │ disagree = 1      │
  (Lối thoát duy nhất)│             │ & cnt == N_MAX    │
                      │             ▼                   │
                      │       ┌───────────┐             │
                      └───────│   ERROR   │             │
                              │ (err = 1) │─────────────┘
                              └───────────┘
                           (Bất kể đầu vào, giữ nguyên)
```


## 4. Bảng chuyển trạng thái đầy đủ

| Trạng thái hiện tại | `rst_n` | `disagree` | `counter` | Trạng thái kế | `counter` kế | `error_state` kế |
|---|:-:|:-:|---|---|---|:-:|
| bất kỳ | 0 | × | × | `NORMAL` | `0` | `0` |
| `NORMAL` | 1 | 0 | bất kỳ | `NORMAL` | `0` ⬅ *xoá* | `0` |
| `NORMAL` | 1 | 1 | `< N_MAX` | `NORMAL` | `counter + 1` | `0` |
| `NORMAL` | 1 | 1 | `= N_MAX` | **`ERROR`** | `N_MAX` | **`1`** |
| **`ERROR`** | 1 | × | × | **`ERROR`** ⬅ *khoá* | giữ nguyên | **`1`** |

*Hai điểm dễ viết sai (và đã được xử lý đúng trong RTL):*
1. Xoá bộ đếm về 0 khi `disagree = 0`: Đảm bảo đếm chuỗi liên tiếp thay vì đếm tổng số lần (tránh báo giả).
2. Khoá trạng thái `ERROR`: Cờ không tự xoá khi hai kênh khớp lại, đảm bảo không bỏ sót lỗi thật.

## 5. Mealy hay Moore

FSM này là **Moore**. 
- Đầu ra `error_state` là hàm chỉ của trạng thái hiện tại (Q của flip-flop), không phụ thuộc trực tiếp vào đầu vào tổ hợp trong cùng chu kỳ.
- Điều này đảm bảo tín hiệu báo lỗi không bao giờ bị glitch, rất quan trọng trong các hệ thống an toàn.

## 6. Mã hoá trạng thái và trạng thái bất hợp lệ

| Câu hỏi | Trả lời cho thiết kế này |
|---|---|
| Mã hoá | **Nhị phân** (1 bit `error_state`): `0` là `NORMAL`, `1` là `ERROR`. |
| Số FF | **7** (6 bit cho `counter` + 1 bit cho `error_state`). |
| Trạng thái bất hợp lệ | Không có. Vì dùng 1 bit nên chỉ có 2 trạng thái hợp lệ. |
| Xử lý tràn bộ đếm | Bộ đếm đã bị chặn không cho tăng khi đạt `N_MAX` (hoặc giữ nguyên khi đã sang `ERROR`), nên không bao giờ bị quấn vòng (overflow). |

## 7. Khử `X` lúc cấp nguồn

RTL sử dụng **reset bất đồng bộ** (`always @(posedge clk or negedge rst_n)`). 
Điều này có nghĩa là ngay khi `rst_n` xuống mức thấp (0), các flip-flop lập tức được nạp giá trị 0 mà không cần chờ xung nhịp. Ở mức gate-level, Yosys sẽ tổng hợp thành các cell flip-flop có chân Reset (`dfrtp_1`), đảm bảo toàn bộ trạng thái `X` (bất định) được xoá sạch ngay từ đầu.


