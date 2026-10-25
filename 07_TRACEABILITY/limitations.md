# C07 · Giới hạn và những gì KHÔNG được khẳng định

Tài liệu này tuân thủ nghiêm ngặt Charter mục 11. Mọi kết luận trong báo cáo phải đi kèm điều kiện.

## 1. Những gì đã chứng minh được (Có bằng chứng)
- **Chức năng:** Mạch chạy đúng 9/9 ca kiểm thử (bao gồm FSM khóa và đếm liên tiếp).
- **Cấu trúc:** Tổng hợp thành công ra 199 standard cell, **7 Flip-flop** (khớp dự kiến 7-9 FF).
- **Timing:** Đạt slack dương ở góc Typical (+2.76 ns).
- **Vật lý:** Đã sinh file GDS, DRC sạch (0 vi phạm), LVS Pass.

## 2. Những gì CHƯA chứng minh được (Giới hạn)
- **Chưa kiểm tra trên Silicon thật:** Đây là bài kiểm tra học thuật, không phải sản phẩm thương mại.
- **Chưa chạy mô phỏng Gate-level / Post-layout (SDF):** Kết quả mô phỏng hiện tại là zero-delay (chưa tính độ trễ ký sinh của dây dẫn).
- **Vi phạm Timing nhẹ ở góc SS:** Ở điều kiện khắc nghiệt (Slow-Slow), mạch vi phạm setup -0.0789 ns. Cần tăng chu kỳ clock lên ~12ns nếu muốn hoạt động an toàn tuyệt đối ở mọi điều kiện.
- **Công suất:** Con số 0.353 mW được ước lượng bằng hoạt động mặc định (chưa dùng file VCD thực tế nên có thể thấp hơn thực tế do glitch).

## 3. BỐN CÂU CẤM VIẾT (Theo Charter mục 11)
Tuyệt đối không được dùng các từ sau trong báo cáo hoặc khi bảo vệ:
1. "Đã sign-off"
2. "Đã tape-out"
3. "Đã chế tạo"
4. "Mạch chạy được ở X MHz" (Vì chưa có silicon thật, tần số chỉ là giả định phân tích).

*Kết luận đúng đắn:* "Đã chạy thành công flow RTL-to-GDSII bằng LibreLane trên PDK sky130A và thu được layout dạng tệp GDS."
