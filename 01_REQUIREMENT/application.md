# C07 · Bối cảnh ứng dụng

| | |
|---|---|
| Mã đề | **C07** |
| Tên đề | Bộ so sánh hai kênh dự phòng và báo bất đồng |
| Nhóm đề | C · Ngưỡng, cảnh báo và giám sát |
| Độ khó | Trung bình |
| Loại mạch | **Tuần tự** |
| Quy mô ước lượng (Charter) | ~230–320 cell · 1×1 tile |
| Nguồn gốc | Project Charter — C07, mục 1 |

---

## 1. Mục tiêu và bối cảnh ứng dụng

Trích nguyên văn Charter mục 1:

> Phân tích khối số “Bộ so sánh hai kênh dự phòng và báo bất đồng” ở mức khối. Bối cảnh ứng dụng: Khối giám sát hai cảm biến dự phòng trong hệ thống an toàn: bất đồng kéo dài là dấu hiệu một cảm biến hỏng.

## 2. Vị trí khối C07 trong hệ thống

```text
   ┌──────────────┐      ┌──────────────────────────────┐      ┌──────────────┐
   │  Nguồn tín   │─────▶│      ►►► KHỐI C07 ◄◄◄        │─────▶│  Tầng tiêu   │
   │  hiệu / dữ   │      │  Bộ so sánh hai kênh dự phòng │      │  thụ kết quả │
   │  liệu vào    │      │  Loại mạch: Tuần tự          │      │              │
   └──────────────┘      └──────────────────────────────┘      └──────────────┘
