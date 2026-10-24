# C07 · Bảng yêu cầu (Requirements)

Mọi yêu cầu đều **suy trực tiếp từ Project Charter — C07**. Cột *Nguồn* chỉ rõ mục nào của Charter sinh ra yêu cầu đó. Không có yêu cầu nào do người soạn tự thêm.

Mức: **M** = bắt buộc · **S** = nên có · **O** = tuỳ chọn.

---

## 1. Yêu cầu chức năng và cấu trúc

| ID | Mức | Nội dung yêu cầu | Nguồn |
|---|---|---|---|
| REQ-C07-001 | M | Khối thực hiện đúng chức năng mô tả trong Charter mục 1: *Bộ so sánh hai kênh dự phòng và báo bất đồng*. | mục 1 |
| REQ-C07-002 | M | Giao diện đúng ánh xạ chân Charter mục 4 (xem `01_REQUIREMENT/application.md`). | mục 4 |
| REQ-C07-003 | M | Loại mạch phải đúng phân loại Charter: **Tuần tự** — có ô nhớ, đồng bộ theo clock. | mục 10 |
| REQ-C07-004 | M | Quy mô nằm trong khoảng hợp lý cho ô 1×1 tile (Charter ước lượng ~230–320 cell · 1×1 tile). | metadata |

## 2. Yêu cầu kiểm chứng

| ID | Mức | Nội dung yêu cầu | Nguồn |
|---|---|---|---|
| REQ-C07-010 | M | Chạy đủ các ca kiểm thử bắt buộc của Charter mục 8 (xem §4). | mục 8 |
| REQ-C07-011 | M | Bổ sung **ít nhất hai ca tự xây dựng**, trong đó có **ca biên**. | mục 8 |
| REQ-C07-012 | M | Mỗi khẳng định phải đi kèm **bằng chứng** và **điều kiện tạo ra bằng chứng**. | mục 6 |
| REQ-C07-013 | S | Thu một **artifact số có chú thích** và nêu điều kiện tạo ra nó. | mục 3, 5 |

## 3. Yêu cầu phân tích riêng (đặc thù của C07)

> Charter mục 9 — bắt buộc trả lời bằng số liệu của chính mình:
>
> Trạng thái lỗi chỉ thoát bằng reset — một lựa chọn thiết kế an toàn. Chỉ ra trong sơ đồ trạng thái và trong báo cáo phần logic nào thực hiện việc 'khoá' này, và bàn về đánh đổi giữa an toàn và khả dụng.
> Bắt buộc trả lời bằng số liệu của chính mình. Mỗi đề một câu khác nhau.

| ID | Mức | Nội dung |
|---|---|---|
| REQ-C07-020 | M | Trả lời câu phân tích riêng ở trên bằng dữ liệu do chính mình sinh ra (trình bày trong Báo cáo cá nhân Mục 8). |
| REQ-C07-021 | M | Trả lời các câu hỏi kỹ thuật Charter mục 2 (xem §5) bằng bằng chứng. |

## 4. Ca kiểm thử bắt buộc (Charter mục 8)

- Hai kênh khớp · lệch trong dung sai · lệch vượt dung sai ngắn (chưa lỗi) · lệch kéo dài (vào trạng thái lỗi) · reset để thoát
- Bổ sung ít nhất hai ca tự xây dựng, trong đó có ca biên.

Danh sách thực thi và kết quả: Xem file `tb/tb.sv` và log mô phỏng trên CI (`simulation.log`).

## 5. Câu hỏi kỹ thuật của Charter (mục 2)

1. **Vì sao cần cả 'bất đồng tức thời' lẫn 'trạng thái lỗi' — hai tín hiệu này khác nhau ở đâu?**
2. **Trạng thái lỗi chỉ thoát được bằng reset — quyết định thiết kế đó đánh đổi cái gì?**
3. **Cần bao nhiêu ô nhớ cho bộ đếm bất đồng, và vì sao đúng số đó?**

> Sinh viên được phép thay bằng câu hỏi của mình, miễn là cụ thể và trả lời được bằng bằng chứng — không viết "tìm hiểu về…". *(Charter mục 2)*

Câu trả lời kèm bằng chứng: Trình bày trong Báo cáo cá nhân (Mục 8) và số liệu từ `metrics.json`.

## 6. Yêu cầu bàn giao (Charter mục 5)

- Hồ sơ phân tích đủ tám thành phần, có số phiên bản và ngày sửa.
- Bảng giao diện: tên tín hiệu, chiều, độ rộng, mức tích cực, giả định.
- Một artifact số có chú thích và nêu điều kiện tạo ra nó.
- Kết luận nêu rõ đã chứng minh được gì và chưa chứng minh được gì.

## 7. Mốc thực hiện (Charter mục 7)

- M1 · T7. Chốt đề và viết charter: ứng dụng, mục tiêu, 2–3 câu hỏi kỹ thuật.
- M2 · T8–9. Bảng hành vi suy từ đặc tả; đọc RTL và waveform; lập danh sách ca kiểm thử.
- M3 · T11–12. Sơ đồ khối hỗ trợ; thu artifact số, chú thích và đối chiếu bảng hành vi.
- M4 · T13–14. Hoàn thiện bảng giao diện, RTM-lite, sơ đồ vòng đời; rà từng khẳng định.
- M5 · T15. Nộp hồ sơ và trình bày; trả lời câu phân tích riêng bằng số của chính mình.

## 8. Rủi ro chính (Charter mục 10)

> Chỗ hay tắc: Đếm bất đồng KHÔNG liên tiếp (quên xoá bộ đếm khi hai kênh khớp lại) — đề nói rõ 'liên tiếp'.
> Dấu hiệu làm đúng: 6 ô nhớ đếm + 1 trạng thái lỗi ≈ 7–9 ô nhớ.
