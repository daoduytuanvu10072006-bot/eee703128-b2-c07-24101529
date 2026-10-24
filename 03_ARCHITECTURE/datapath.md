# C07 · Đường dữ liệu (Datapath)

---

## 1. Kiến trúc Datapath kết hợp Điều khiển

Thiết kế C07 của sinh viên không chỉ là một mạch tổ hợp đơn thuần. Theo báo cáo tổng hợp (`metrics.json`), thiết kế bao gồm:
- **112 cell tổ hợp** (Multi-input combinational, inverter, buffer).
- **7 cell tuần tự** (Sequential cell: 6 FF cho bộ đếm, 1 FF cho trạng thái lỗi).

```text
  ui_in (A) ══╗
              ╠══▶ ┌──────────────────────────────────────┐ ──▶ disagree (Tổ hợp)
  uio_in (B) ═╣    │  |A−B| rồi so với dung sai (TOL)     │ ──▶ counter (6 FF)
              ║    │  Datapath + FSM                       │ ──▶ error_state (1 FF)
              ╝    └──────────────────────────────────────┘
```
## 2. Bảng các đường dữ liệu

| Đường | Độ rộng | Từ | Đến | Bản chất |
|---|---:|---|---|---|
| `ui_in[7:0]` | 8 | Cổng vào | Bộ trừ + Bộ so sánh dấu | Toán hạng (kênh A) |
| `uio_in[7:0]` | 8 | Cổng vào | Bộ trừ + Bộ so sánh dấu | Toán hạng (kênh B) |
| `diff_mag[7:0]` | 8 | MUX chọn | Bộ so sánh ngưỡng | `|A − B|` |
| `disagree` | 1 | Bộ so sánh | Ngõ ra + Điều khiển bộ đếm | Bất đồng tức thời |
| `counter[5:0]` | 6 | Bộ đếm | Ngõ ra + Điều khiển FSM | Số chu kỳ bất đồng liên tiếp |
| `error_state` | 1 | FSM | Ngõ ra | Trạng thái lỗi (khoá) |

## 3. Vì sao `diff_mag` chỉ cần 8 bit

Chi tiết này đáng học vì nó liên quan đến tính an toàn của phép trừ:
- Trong nhánh `A >= B`, hiệu `A − B` nằm trong `[0, 255]`.
- Trong nhánh còn lại, `B − A` nằm trong `[1, 255]`.
Điều kiện của nhánh (dùng MUX) **bảo đảm** kết quả không âm, nên 8 bit là đủ để biểu diễn độ lệch tuyệt đối mà không bao giờ bị tràn số. Kết quả mô phỏng 9 ca (bao gồm cực trị 0 và 255) đã xác nhận điều này.

## 4. Một điểm tinh tế: bit dấu vừa là dữ liệu vừa là điều khiển

Trong hầu hết thiết kế, tín hiệu điều khiển tới sớm và dữ liệu tới muộn, nên MUX không nằm trên đường tới hạn. Ở C07, chân `S` của MUX nhận bit dấu (`A >= B`), mà bit dấu lại nằm ở **cuối** chuỗi borrow của phép trừ — tức nó là tín hiệu tới **muộn nhất**.
Hệ quả: MUX **không thể** được che bởi dữ liệu tới trước; nó cộng trọn độ trễ vào đường tới hạn. Đây là lý do cấu trúc “trừ hai chiều rồi chọn” đắt hơn vẻ ngoài.

## 5. Đồ thị phụ thuộc và độ sâu logic

```text
  mức 0    ui_in[7:0]   uio_in[7:0]                              
              │  │        │  │                                    
              ├──┴────────┴──┤                                    
              │              │                                    
  mức 1..8  ┌─▼──────────┐ ┌─▼──────────┐                         
            │ TRỪ A−B    │ │ TRỪ B−A    │   (chạy song song)      
            │ chuỗi borrow│ │chuỗi borrow│                        
            └─────┬──────┘ └─────┬──────┘                         
                  │              │                                
  mức 9      ┌────▼──────────────▼─────┐                          
             │ bit dấu (A >= B)        │  ← ở CUỐI chuỗi borrow    
             └────────────┬────────────┘                          
                          │                                       
  mức 10       ┌──────────▼──────────┐                            
               │ MUX 8 bit (chân S)  │                            
               └──────────┬──────────┘                            
                          │ diff_mag[7:0]                         
  mức 11..14   ┌──────────▼──────────┐                            
               │ SO SÁNH > TOL       │                            
               └──────────┬──────────┘                            
                          │ disagree                              
  mức 15       ┌──────────▼──────────┐                            
               │ Logic cộng Bộ đếm  │                            
               └──────────┬──────────┘                            
                          ▼                                       
  mức 16             FF `counter[5:0]` & `error_state`
```
## 6. Dự đoán đường tới hạn **trước khi** xem STA

Lập luận từ RTL: mọi đường đều đi từ `ui_in`/`uio_in` qua **trừ → chọn → so sánh → cộng bộ đếm** rồi vào FF.
Đường dài nhất phải xuất phát từ **bit thấp** của một toán hạng (vì bit thấp phải đi hết chuỗi borrow), đi qua MUX, qua bộ so sánh, qua logic cộng bộ đếm và kết thúc tại Flip-flop.

## 7. Đối chiếu với STA thật (Từ `metrics.json`)

| Đại lượng | Đo được (Góc Typical - TT) | Đánh giá |
|---|---|---|
| Startpoint | **Bit MSB của `ui_in` hoặc `uio_in`** | Đi qua toàn bộ mạch |
| Endpoint | Đầu vào D của FF `counter` | Đích của chuỗi logic |
| Data arrival | **~ 7.24 ns** *(Ước tính từ Slack)* | Bao gồm cả độ trễ bộ đếm |
| Setup Slack | **+ 2.760 ns** | Đạt (MET) |
| Setup Slack (Góc SS) | **- 0.0789 ns** | Vi phạm nhẹ |

**Phân bổ độ trễ (Ước lượng):**
- **① Chuỗi borrow của phép trừ:** Chiếm tỷ lệ lớn nhất (do đi qua 8 tầng full adder).
- **② Sinh bit dấu & MUX:** Cộng thêm độ trễ do MUX phải chờ bit dấu.
- **③ So sánh với TOL:** Bộ so sánh 8-bit thứ hai.
- **④ Logic cộng bộ đếm:** Do phải chờ kết quả so sánh để quyết định tăng hay reset bộ đếm.
## 8. Cơ hội tối ưu

Với slack **+ 2.76 ns** ở chu kỳ giả định 10 ns (góc TT), thiết kế đã đạt yêu cầu. Tuy nhiên, để khắc phục vi phạm nhỏ ở góc chậm (SS), có thể áp dụng các ý tưởng:
- **Hoán vị toán hạng TRƯỚC khi trừ:** Thay vì trừ hai lần rồi chọn (tốn 2 mạch trừ), hãy dùng MUX để chọn số lớn và số bé trước, sau đó mới thực hiện một phép trừ. Điều này giúp giảm diện tích và có thể cải thiện timing.
- **Carry-Lookahead Adder (CLA):** Thay bộ trừ ripple-carry bằng CLA để giảm độ sâu logic từ O(N) xuống O(log N).

