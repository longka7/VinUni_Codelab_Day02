# Phase 1 & 2 — Individual Problem Scan and Quick Assessment

**Học viên:** Thees Anh  
**Vai trò giả định:** AI Product Engineer, Vin Smart Future

> **Lưu ý về số liệu:** Dự án không cung cấp dữ liệu vận hành nội bộ. Vì vậy, mọi con số hiện trạng dưới đây là **baseline giả định để thiết kế thử nghiệm**, không phải số liệu đã được Vingroup xác nhận. Trước khi triển khai thật cần đo lại bằng log vận hành và phỏng vấn stakeholder.

## Phase 1 — SCAN

### Bảng quét cơ hội

| # | Subsidiary | Lens | Mô tả ngắn bài toán |
|---:|---|---|---|
| 1 | Xanh SM | Stakeholder Pain | Khi xe có mức pin tới hạn hoặc gặp sự cố giữa chuyến, tài xế phải mô tả tình trạng qua nhiều kênh; điều phối viên mất thời gian xác minh vị trí, mức pin và chọn phương án hỗ trợ an toàn. |
| 2 | Vinhomes | Repetitive | Nhân viên chăm sóc cư dân đọc, phân loại và chuyển hàng loạt phản ánh lặp lại như tiếng ồn, vệ sinh, thẻ ra vào hoặc hỏng thiết bị sang đúng bộ phận. |
| 3 | Vinmec | Time-consuming | Trước buổi khám, nhân viên y tế phải đọc nhiều tài liệu để tóm tắt tiền sử, thuốc đang dùng và kết quả xét nghiệm cho bác sĩ. |
| 4 | VinFast | Repetitive | Nhân viên dịch vụ hậu mãi phân loại mô tả lỗi xe bằng ngôn ngữ tự nhiên, đối chiếu nhóm lỗi và chuyển yêu cầu đến trung tâm dịch vụ phù hợp. |
| 5 | Vinpearl / VinWonders | AI-upgrade | Chatbot đặt vé hiện tại có thể khó xử lý yêu cầu nhiều điều kiện như số người, độ tuổi, ngày đi, combo, hạn chế đổi vé và nhu cầu đặc biệt. |

### Sàng lọc nhanh

| Bài toán | Tần suất dự kiến | Giá trị nếu giải quyết | Rủi ro AI | Hướng phù hợp |
|---|---|---|---|---|
| Hỗ trợ xe Xanh SM pin tới hạn | Trung bình–cao | An toàn, giảm thời gian phản ứng | Cao; quyết định sai có thể làm xe mắc kẹt | LLM hỗ trợ + rule cứng + human approval |
| Phân loại phản ánh Vinhomes | Cao | Giảm thời gian xử lý và chuyển sai bộ phận | Trung bình | LLM feature + confidence threshold |
| Tóm tắt hồ sơ Vinmec | Cao | Tiết kiệm thời gian chuẩn bị khám | Rất cao; dữ liệu nhạy cảm và ảnh hưởng y khoa | LLM draft trong hệ thống kín + bác sĩ duyệt |
| Phân loại yêu cầu hậu mãi VinFast | Cao | Giảm thời gian triage | Trung bình–cao | LLM classification + rule escalation |
| Trợ lý tư vấn vé Vinpearl | Cao theo mùa | Tăng tốc tư vấn và giảm bỏ giỏ | Trung bình | RAG/LLM + dữ liệu giá và chính sách chuẩn |

Ba bài toán được chọn làm Quick Problem Cards là Xanh SM, Vinhomes và Vinmec vì chúng đại diện cho ba mức rủi ro khác nhau và có metric đo lường tương đối rõ.

---

## Phase 2 — QUICK-ASSESS

## Quick Problem Card #1 — Xanh SM Critical-Battery Support

**Bài toán (1 câu):** Rút ngắn thời gian xác minh và đề xuất phương án hỗ trợ an toàn cho tài xế Xanh SM khi xe báo mức pin tới hạn.

**Công ty thành viên:** Xanh SM  
**Actor:** Tài xế, điều phối viên vận hành và đội hỗ trợ/sạc lưu động.

**Workflow thủ công hiện tại (giả định cần xác minh):**

1. Tài xế gọi hoặc nhắn cho trung tâm điều phối và mô tả sự cố.
2. Điều phối viên hỏi lại vị trí GPS, mức pin, trạng thái xe và tình trạng hành khách.
3. Điều phối viên tra cứu trạm sạc hoặc đội hỗ trợ gần nhất trên các hệ thống liên quan.
4. Điều phối viên chọn phương án và soạn hướng dẫn cho tài xế.
5. Điều phối viên liên hệ đội hỗ trợ, sau đó cập nhật trạng thái cho tài xế.

**Bottleneck:** Bước 2–4 do dữ liệu đầu vào không đồng nhất và phải đối chiếu thủ công; baseline giả định **8 phút/lượt**, cần đo lại từ log dispatch.

**AI có thể hỗ trợ:** Chuẩn hóa mô tả sự cố, phát hiện mức pin tới hạn, tạo đề xuất dạng JSON và soạn bản nháp. Rule cứng phải chặn đề xuất trạm xa hơn 5 km khi pin dưới 5%.

**Success metrics:**

- Giảm thời gian từ lúc nhận yêu cầu đến khi có phương án nháp từ baseline giả định 8 phút xuống **dưới 2 phút**.
- **100%** trường hợp pin dưới 5% trong bộ test không được đề xuất trạm xa hơn 5 km.
- **100%** output chỉ là bản nháp có nhãn `[DRAFT_ONLY]` và cần con người duyệt.
- Ít nhất **95%** trường hợp test có đủ các trường JSON bắt buộc.

**Quick Architecture:** **LLM Feature + deterministic safety rules + Human-in-the-loop**, chưa dùng agent tự thực thi.

**Operational boundary:** AI không được tự gửi tin, tự điều xe hoặc tuyên bố đã thực thi. Khi pin dưới 5%, AI phải đề xuất `dispatch_mobile_charger`. Điều phối viên chịu trách nhiệm xác minh dữ liệu và phê duyệt hành động.

---

## Quick Problem Card #2 — Vinhomes Resident Request Triage

**Bài toán (1 câu):** Tự động tạo bản nháp phân loại, mức ưu tiên và bộ phận tiếp nhận cho phản ánh bằng văn bản của cư dân Vinhomes.

**Công ty thành viên:** Vinhomes  
**Actor:** Nhân viên chăm sóc cư dân và các đội vận hành tòa nhà.

**Workflow thủ công hiện tại (giả định cần xác minh):**

1. Nhận phản ánh từ ứng dụng, email hoặc tổng đài.
2. Đọc và chuẩn hóa nội dung.
3. Chọn danh mục và mức ưu tiên.
4. Chuyển ticket sang bộ phận phụ trách.
5. Soạn phản hồi xác nhận cho cư dân.

**Bottleneck:** Bước 2–4; baseline giả định **6 phút/ticket**, đồng thời có nguy cơ chuyển nhầm bộ phận.

**AI có thể hỗ trợ:** Trích xuất địa điểm/sự cố, đề xuất danh mục, mức ưu tiên, bộ phận xử lý và bản nháp phản hồi.

**Success metrics:**

- Giảm thời gian triage từ baseline giả định 6 phút xuống **dưới 90 giây/ticket**.
- Độ chính xác phân loại đạt **tối thiểu 90%** trên tập kiểm thử đã gắn nhãn.
- **100%** yêu cầu liên quan cháy, an ninh, y tế hoặc đe dọa an toàn được chuyển con người ngay.

**Quick Architecture:** **LLM Feature** kết hợp taxonomy/rule và confidence threshold.

**Operational boundary:** AI không tự đóng ticket, không cam kết SLA/bồi thường và không tự gửi phản hồi. Ticket an toàn khẩn cấp hoặc confidence dưới 0,80 phải chuyển nhân viên xử lý.

---

## Quick Problem Card #3 — Vinmec Pre-Visit Record Summary

**Bài toán (1 câu):** Tạo bản tóm tắt hồ sơ trước buổi khám để bác sĩ Vinmec đọc nhanh hơn mà không trao quyền chẩn đoán cho AI.

**Công ty thành viên:** Vinmec  
**Actor:** Bác sĩ, điều dưỡng và nhân viên chuẩn bị hồ sơ.

**Workflow thủ công hiện tại (giả định cần xác minh):**

1. Thu thập bệnh án, đơn thuốc và kết quả xét nghiệm được phép sử dụng.
2. Mở và đọc từng tài liệu.
3. Ghi lại tiền sử, dị ứng, thuốc đang dùng và kết quả bất thường.
4. Đối chiếu thiếu sót hoặc mâu thuẫn.
5. Chuẩn bị bản tóm tắt để bác sĩ xem trước buổi khám.

**Bottleneck:** Bước 2–4; baseline giả định **15 phút/hồ sơ**, tăng theo độ dài và số tài liệu.

**AI có thể hỗ trợ:** Trích xuất thông tin có dẫn chiếu tới tài liệu nguồn, đánh dấu dữ liệu thiếu/mâu thuẫn và tạo bản tóm tắt cho bác sĩ duyệt.

**Success metrics:**

- Giảm thời gian chuẩn bị từ baseline giả định 15 phút xuống **dưới 5 phút/hồ sơ**.
- **100%** dị ứng và thuốc được nêu trong bản tóm tắt phải có dẫn chiếu nguồn.
- **0** chẩn đoán hoặc chỉ định điều trị tự động trong bộ test nghiệm thu.
- **100%** bản tóm tắt được nhân viên y tế duyệt trước khi sử dụng.

**Quick Architecture:** **LLM Feature/RAG trong môi trường kiểm soát**, không dùng agent tự hành động.

**Operational boundary:** AI không chẩn đoán, kê đơn, thay đổi hồ sơ hay gửi dữ liệu ra hệ thống không được phê duyệt. Nếu nguồn mâu thuẫn hoặc thiếu, AI phải nêu “không đủ thông tin” và yêu cầu bác sĩ kiểm tra.

---

## Kết luận cá nhân

Tôi chọn **Xanh SM Critical-Battery Support** cho prompt prototype vì bài toán có ranh giới an toàn rõ, có thể tạo adversarial tests cụ thể và cho phép so sánh vai trò của rule cứng với LLM. Kiến trúc phù hợp ở giai đoạn này là LLM tạo đề xuất có cấu trúc, rule kiểm tra điều kiện an toàn và điều phối viên phê duyệt; không trao quyền tự thực thi cho mô hình.
