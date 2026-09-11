# 01 — Problem Scan (Cá nhân: longkhanh)

> Copy & hoàn thiện từ Phase 1 (SCAN) và Phase 2 (QUICK-ASSESS) trong `01-worksheet.md`.

---

## 🔍 Phase 1 — SCAN

Dùng **4 Lenses** (Lặp lại / Tốn thời gian / AI có thể tốt hơn / Pain từ người khác) để quét ít nhất 5 bài toán thực tế thuộc các công ty thành viên Vingroup (VinFast, Xanh SM, Vinhomes, Vinmec, Vinpearl/VinWonders).

| # | Subsidiary (VinFast/Xanh SM...) | Lens | Mô tả ngắn bài toán |
|---|----------------------------------|------|---------------------|
| 1 | **VinFast** | Lặp lại | Kỹ thuật viên trung tâm dịch vụ đọc log lỗi chẩn đoán (DTC code) từ xe rồi gõ tay mô tả lỗi + đối chiếu điều khoản bảo hành vào hệ thống ticket — lặp lại hàng trăm lượt/ngày trên toàn hệ thống trạm dịch vụ. |
| 2 | **Xanh SM** | Tốn thời gian | Đội Quality/CSKH đọc thủ công hàng nghìn đánh giá chuyến đi (rating thấp + ghi chú tự do) mỗi ngày để phân loại nguyên nhân (tài xế, xe, app, giá cước) và gắn đúng phòng ban xử lý. |
| 3 | **Vinhomes** | AI-upgrade | Trợ lý cư dân hiện dùng kịch bản trả lời cố định (rule-based FAQ), không xử lý được câu hỏi diễn đạt tự nhiên về phí dịch vụ/đặt lịch tiện ích, khiến tỉ lệ escalate lên tổng đài người thật còn cao. |
| 4 | **Vinmec** | Pain từ người khác | Bác sĩ điều trị phàn nàn phải tự tay tổng hợp và soạn tóm tắt hồ sơ xuất viện dài từ nhiều lần khám, dễ bỏ sót thông tin quan trọng khi bàn giao sang khoa khác. |
| 5 | **Vinpearl/VinWonders** | Lặp lại | Nhân viên soát vé tại cổng phải tra cứu thủ công gói combo/ưu đãi phù hợp khi có nhiều chương trình khuyến mãi theo mùa chồng chéo, gây ùn ứ hàng chờ ở giờ cao điểm. |

---

## 🃏 Phase 2 — QUICK-ASSESS: 3 Quick Problem Cards

Chọn **top 3 bài toán** từ bảng trên và hoàn thiện chi tiết.

### Quick Problem Card #1 — VinFast Đối chiếu log lỗi bảo hành

```text
┌─────────────────────────────────────────────────────────────┐
│ QUICK PROBLEM CARD #1                                        │
│                                                               │
│ Bài toán: KTV dịch mã lỗi chẩn đoán (DTC) và nhập tay ticket │
│ bảo hành cho từng xe vào xưởng dịch vụ.                      │
│ Công ty thành viên: [x] VinFast                              │
│                                                               │
│ Ai đang đau (Actor)? Kỹ thuật viên trung tâm dịch vụ (KTV)   │
│                                                               │
│ Workflow thủ công hiện tại (5 bước):                          │
│   1. Xe vào xưởng, cắm máy đọc log lỗi (DTC codes)            │
│   ──> 2. KTV tra bảng mã lỗi, dịch sang mô tả dễ hiểu         │
│   ──> 3. Gõ tay mô tả lỗi + mã vào hệ thống ticket bảo hành   │
│   ──> 4. Đối chiếu điều khoản bảo hành để xác định hạng mục   │
│   ──> 5. Trình duyệt yêu cầu bảo hành lên quản lý xưởng       │
│                                                               │
│ Bước nào tốn thời gian/lỗi nhất? Bước 2-3 (⏱ 15 phút/xe),     │
│ dễ nhầm giữa các mã lỗi có ký hiệu gần giống nhau             │
│ AI có thể nhảy vào hỗ trợ ở bước nào? Bước 2-4 (tự động parse │
│ log, map mã lỗi chuẩn, draft mô tả + đối chiếu điều khoản)    │
│                                                               │
│ Đo thành công bằng gì (Metric có số)?                          │
│ Giảm thời gian xử lý từ 15 phút ──> dưới 4 phút/xe;           │
│ giảm tỉ lệ nhập sai mã lỗi từ ~8% xuống dưới 1%.               │
│                                                               │
│ Quick Architecture: [ ] No AI  [x] Rule+LLM  [ ] Agent        │
└─────────────────────────────────────────────────────────────┘
```

### Quick Problem Card #2 — Xanh SM Phân loại phản hồi khách hàng

```text
┌─────────────────────────────────────────────────────────────┐
│ QUICK PROBLEM CARD #2                                        │
│                                                               │
│ Bài toán: Đọc và phân loại thủ công feedback/rating chuyến   │
│ đi để gắn đúng nguyên nhân và đẩy đúng phòng ban xử lý.       │
│ Công ty thành viên: [x] Xanh SM (GSM)                         │
│                                                               │
│ Ai đang đau (Actor)? Nhân viên Quality/CSKH                   │
│                                                               │
│ Workflow thủ công hiện tại (4 bước):                          │
│   1. Khách đánh giá chuyến (rating + ghi chú tự do)           │
│   ──> 2. Nhân viên đọc từng feedback (~5.000 lượt/ngày)       │
│   ──> 3. Phân loại nguyên nhân (tài xế/xe/app/giá cước)       │
│   ──> 4. Gắn nhãn, đẩy đúng phòng ban, tổng hợp báo cáo tuần  │
│                                                               │
│ Bước nào tốn thời gian/lỗi nhất? Bước 2-3 (⏱ ~1 phút/lượt     │
│ → ~83 giờ nhân sự/ngày cho toàn bộ khối lượng)                │
│ AI có thể nhảy vào hỗ trợ ở bước nào? Bước 2-4 (tự động phân  │
│ loại đa nhãn + tóm tắt pattern lỗi lặp lại theo tuần)         │
│                                                               │
│ Đo thành công bằng gì (Metric có số)?                          │
│ Giảm thời gian xử lý mỗi feedback từ 1 phút ──> dưới 5 giây;  │
│ độ chính xác phân loại đạt ≥ 90% so với nhãn nhân viên gán.   │
│                                                               │
│ Quick Architecture: [ ] No AI  [ ] Rule  [x] LLM  [ ] Agent  │
└─────────────────────────────────────────────────────────────┘
```

### Quick Problem Card #3 — Vinmec Soạn tóm tắt xuất viện

```text
┌─────────────────────────────────────────────────────────────┐
│ QUICK PROBLEM CARD #3                                        │
│                                                               │
│ Bài toán: Bác sĩ tự tay tổng hợp và soạn tóm tắt hồ sơ xuất  │
│ viện từ nhiều lần khám, dễ thiếu sót khi bàn giao khoa khác. │
│ Công ty thành viên: [x] Vinmec                                │
│                                                               │
│ Ai đang đau (Actor)? Bác sĩ điều trị                          │
│                                                               │
│ Workflow thủ công hiện tại (5 bước):                          │
│   1. Bệnh nhân đủ điều kiện xuất viện                         │
│   ──> 2. Bác sĩ tổng hợp hồ sơ (chẩn đoán, thuốc, chỉ định)   │
│   ──> 3. Soạn tóm tắt xuất viện bằng tay                      │
│   ──> 4. Ký duyệt                                             │
│   ──> 5. Bàn giao cho bệnh nhân/khoa tiếp nhận khác           │
│                                                               │
│ Bước nào tốn thời gian/lỗi nhất? Bước 2-3 (⏱ 20-30 phút/ca),  │
│ quá tải vào giờ cao điểm xuất viện, dễ bỏ sót chi tiết         │
│ AI có thể nhảy vào hỗ trợ ở bước nào? Bước 2-3 (draft tóm tắt │
│ tự động từ dữ liệu hồ sơ điện tử — EMR — có sẵn)               │
│                                                               │
│ Đo thành công bằng gì (Metric có số)?                          │
│ Giảm thời gian soạn tóm tắt từ 25 phút ──> dưới 5 phút/ca     │
│ (bác sĩ chỉ review + chỉnh sửa); 100% ca vẫn qua bác sĩ ký    │
│ duyệt cuối trước khi phát hành (không cho AI tự publish).      │
│                                                               │
│ Quick Architecture: [ ] No AI  [ ] Rule  [x] LLM  [ ] Agent  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🗳️ Lý do chọn 3 thẻ này (và loại 2 thẻ còn lại)

Với tư duy AI Engineer đánh giá theo 2 tiêu chí — **mức độ khả thi kỹ thuật** và **mức độ rủi ro/compliance** — 3 bài toán được chọn đều có đặc điểm chung: dữ liệu đầu vào có cấu trúc rõ ràng (log lỗi, feedback text, hồ sơ EMR), đầu ra là *draft* chứ không phải hành động tự động hoàn toàn, và đều giữ được một bước con người phê duyệt (HITL) trước khi có tác động thật.

- **Card #3 (Vinhomes Trợ lý cư dân) bị loại khỏi vòng Deep-Dive:** phạm vi câu hỏi liên quan tới phí dịch vụ/tranh chấp căn hộ có rủi ro pháp lý nếu AI trả lời sai — cần một lớp rule-based router xác nhận trước khi để LLM trả lời tự do, nên chưa đủ chín để đưa thẳng vào Deep-Dive ở giai đoạn này.
- **Card #5 (Vinpearl Combo vé) bị loại:** tuy dễ làm về mặt kỹ thuật (tra cứu có cấu trúc, gần giống rule-based lookup hơn là bài toán cần LLM), nhưng tác động kinh doanh (giảm ùn ứ ở cổng vào mùa cao điểm) nhỏ hơn nhiều so với 3 bài toán trên, nên ưu tiên thấp hơn cho vòng Deep-Dive lần này.
