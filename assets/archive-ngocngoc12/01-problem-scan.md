# 01 — Problem Scan: Xanh SM Battery Support

> **Scope:** Xanh SM (GSM) — hỗ trợ tài xế EV khi pin yếu giữa hành trình.

## 1. Bối cảnh

Tài xế EV của Xanh SM có thể gặp tình huống pin yếu giữa hành trình và cần dispatcher hỗ trợ real-time. Nếu hệ thống chỉ dẫn nhầm đến trạm xa, trạm không phù hợp hoặc đường đi không an toàn, xe có thể cạn pin giữa đường, làm tăng downtime, ảnh hưởng an toàn giao thông và giảm trải nghiệm khách hàng.

## 2. SCAN — Bảng quét cơ hội

| # | Công ty | Lens | Bài toán / bottleneck |
|---|---|---|---|
| 1 | Xanh SM | Tốn thời gian | Dispatcher xử lý thủ công báo cáo pin yếu, tra GPS, tìm trạm sạc và soạn hướng dẫn cho tài xế. |
| 2 | Xanh SM | Lặp lại | Phân loại lý do khách hủy chuyến từ cuộc gọi và ghi chú của tài xế để phát hiện nhóm nguyên nhân chính. |
| 3 | VinFast | Lặp lại | Đối chiếu dữ liệu phiên sạc, trụ sạc và hóa đơn đối tác theo chu kỳ. |
| 4 | Vinhomes | AI-upgrade | Phân loại phản ánh cư dân và chuyển đúng ban quản lý/tòa nhà để giảm thời gian xử lý. |
| 5 | Vinmec | Tốn thời gian | Soạn bản nháp tóm tắt xuất viện từ hồ sơ bệnh án để bác sĩ review. |

## 3. Quick Problem Cards

### Card 1 — Xanh SM: xử lý sự cố pin yếu

- **Bài toán:** Tài xế báo pin yếu hoặc sắp hết pin giữa hành trình nhưng dispatcher phải tra cứu và hướng dẫn thủ công.
- **Actor:** Tài xế EV, dispatcher, đội cứu hộ/mobile charger.
- **Workflow:** Tài xế báo sự cố -> dispatcher lấy vị trí và mức pin -> tra trạm phù hợp -> soạn hướng dẫn -> dispatcher duyệt/gửi hoặc điều cứu hộ.
- **Bottleneck:** Tra cứu trạm và soạn hướng dẫn, khoảng 10 phút trong tổng 15 phút/lượt theo giả định cần được đo lại bằng log thực tế.
- **AI hỗ trợ:** Hiểu mô tả tự nhiên, tạo bản nháp hướng dẫn; rule engine kiểm tra ngưỡng pin và khoảng cách.
- **Metric:** Giảm thời gian xử lý từ baseline cần đo (giả định 15 phút) xuống dưới 3 phút; 100% output tuân thủ boundary trong test suite.
- **Architecture:** Hybrid: Rule-based guardrail + LLM Feature + Human-in-the-loop.

### Card 2 — Vinhomes: phân loại phản ánh cư dân

- **Bài toán:** Phản ánh tự do của cư dân phải được phân loại và chuyển đúng bộ phận.
- **Actor:** Cư dân, nhân viên CSKH, ban quản lý.
- **Workflow:** Cư dân gửi phản ánh -> CSKH đọc và phân loại -> chuyển bộ phận -> theo dõi SLA -> phản hồi.
- **Bottleneck:** Đọc, gắn nhãn và chuyển ticket thủ công.
- **AI hỗ trợ:** Phân loại chủ đề, mức độ khẩn cấp và tạo bản nháp phản hồi.
- **Metric:** 90% ticket được phân loại dưới 30 giây; tỷ lệ chuyển sai dưới 5%; CSKH duyệt mọi phản hồi.
- **Architecture:** Rule-based routing + LLM classification/drafting.

### Card 3 — VinFast: đối chiếu hóa đơn sạc

- **Bài toán:** Nhân viên phải so khớp phiên sạc, mã trụ và hóa đơn từ nhiều nguồn.
- **Actor:** Nhân viên tài chính/vận hành trạm.
- **Workflow:** Nhận file -> chuẩn hóa dữ liệu -> so mã phiên sạc -> tìm lệch -> lập danh sách cần xử lý.
- **Bottleneck:** Chuẩn hóa định dạng và xác minh các dòng lệch.
- **AI hỗ trợ:** Trích xuất trường dữ liệu và giải thích nhóm sai lệch; rule engine quyết định match/non-match.
- **Metric:** 95% dòng được xử lý dưới 1 phút; false match dưới 1%; mọi mismatch được người phụ trách duyệt.
- **Architecture:** Rule-based matching + LLM extraction/explanation.

## 4. Hội tụ nhóm và chọn candidate problem

Theo đúng quy trình scoping, nhóm **chưa viết Problem Statement ở bước scan**. Nhóm trước hết chọn một candidate problem để tiếp tục kiểm chứng.

| Candidate | Giá trị tiềm năng | Mức độ rủi ro | Khả năng kiểm chứng nhanh | Điểm tổng (1-5) |
|---|---:|---:|---:|---:|
| Xanh SM — hỗ trợ pin yếu giữa hành trình | 5 | 4 | 4 | **13/15** |
| Vinhomes — phân loại phản ánh cư dân | 4 | 3 | 4 | 11/15 |
| VinFast — đối chiếu hóa đơn sạc | 4 | 2 | 3 | 9/15 |

**Candidate được chọn để đào sâu:** Xanh SM — hỗ trợ dispatcher xử lý tình huống pin EV yếu giữa hành trình. Lý do là pain có tính thời gian thực, impact an toàn rõ và có thể kiểm tra bằng test boundary; nhóm không chọn vì giải pháp AI “ngầu” hơn.

## 5. Kiểm chứng và research trước khi chốt Problem Statement

### Bằng chứng hiện có

- Desk research từ worksheet/lab guideline: quy trình gồm nhận report, tra GPS, tra trạm, đánh giá phương án và soạn tin.
- Prototype boundary test xác nhận được hai rủi ro kỹ thuật đại diện: pin dưới 5% nhưng trạm cách 8 km, và yêu cầu bỏ `[DRAFT_ONLY]`.
- Chưa có log vận hành Xanh SM, phỏng vấn dispatcher hoặc khảo sát tài xế trong workspace này. Vì vậy các số 15 phút/lượt và target business vẫn là giả định cần xác thực.

### Kế hoạch validate tối thiểu

| Hoạt động | Đối tượng/dữ liệu | Câu hỏi cần kiểm chứng | Tiêu chí đủ tin cậy |
|---|---|---|---|
| Phỏng vấn bán cấu trúc | 2 dispatcher, 3 tài xế | Các bước nào thật sự tốn thời gian? Mức pin nào được coi là critical? | Ít nhất 3/5 người xác nhận cùng bottleneck |
| Khảo sát nhanh | Tài xế/dispatcher pilot | Tần suất sự cố, thời gian xử lý, mức hài lòng | Có timestamp hoặc sample size và định nghĩa rõ |
| Log review | Ticket điều vận 2–4 tuần | Baseline thời gian, ca hết pin, downtime | Có đủ mẫu, ẩn PII và thống nhất cách tính |
| So sánh giải pháp hiện có | Bản đồ/trạm, quy trình cứu hộ, công cụ dispatcher | Cái gì đã có? Khoảng trống nằm ở đâu? | Không trùng chức năng và có owner xác nhận |

**Trạng thái:** Candidate đủ cơ sở để làm prototype và deep-dive, nhưng chưa đủ bằng chứng để khẳng định baseline vận hành hoặc triển khai production.

## 6. Problem Statement

Problem Statement dưới đây được viết **sau bước candidate selection, workflow mapping và xác định kế hoạch validate**. Đây là phiên bản làm việc, sẽ cập nhật khi có interview/log thực tế.

> **Tài xế Xanh SM khi pin xuống dưới ngưỡng nguy hiểm khoảng 5% hiện không có công cụ hỗ trợ real-time để tìm trạm sạc an toàn gần nhất hoặc gọi cứu hộ phù hợp, dẫn đến rủi ro xe hết pin giữa đường, tăng thời gian downtime và làm giảm trải nghiệm khách hàng.**

## 7. Problem Statement theo 5W1H

| Thành phần | Nội dung |
|---|---|
| **Who** | Tài xế EV Xanh SM và dispatcher tại trung tâm điều vận. |
| **What** | Xử lý báo cáo pin yếu, xác định phương án an toàn và soạn hướng dẫn cho tài xế. |
| **When/Where** | Trong chuyến đi, đặc biệt khi pin dưới 5%, tại vị trí bất kỳ trên mạng lưới vận hành. |
| **Why** | Dispatcher cần quyết định nhanh nhưng dữ liệu vị trí, pin và trạm thường phải tra cứu qua nhiều bước. |
| **How** | Hiện xử lý qua cuộc gọi/app, bản đồ, dashboard trạm sạc và tin nhắn thủ công. |
| **Impact** | Có thể dẫn đến xe hết pin, mất chuyến, tăng downtime và rủi ro an toàn nếu chỉ dẫn sai. |

## 8. Metrics: baseline và target

> Các baseline dưới đây là **giả định dùng cho prototype**, không phải số liệu vận hành đã được xác nhận. Trước pilot cần truy xuất log điều vận trong 2–4 tuần để thay bằng baseline thực tế.

### Business metrics

| Metric | Baseline tạm thời | Target pilot | Cách đo |
|---|---:|---:|---|
| Thời gian xử lý sự cố pin yếu | 15 phút/lượt (giả định) | < 3 phút/lượt, giảm ít nhất 80% | Timestamp từ lúc nhận báo cáo đến lúc dispatcher có phương án đã duyệt |
| Ca xe hết pin giữa đường | Chưa có baseline tin cậy | Giảm ít nhất 30% sau 8 tuần | Log sự cố theo tháng, chuẩn hóa định nghĩa “hết pin giữa đường” |
| Downtime do sự cố pin | Chưa có baseline | Giảm 20% trong pilot | Thời gian xe không nhận cuốc do sự cố pin |
| NPS/điểm hài lòng tài xế sau xử lý | Chưa có baseline | Tăng 10 điểm phần trăm so với baseline | Khảo sát sau ticket, cùng câu hỏi và mẫu đo |

### AI/Product metrics

| Metric | Baseline tạm thời | Target | Cách đo |
|---|---:|---:|---|
| Tuân thủ Rule 1, Rule 2 | Chưa đo | 100% trong test suite; không có lỗi nghiêm trọng trong pilot | Bộ test adversarial có expected outcome rõ ràng |
| Prompt injection bị chặn | Chưa đo | >= 95% trên bộ test đã gắn nhãn | Số input injection bị từ chối/ tổng input injection |
| Latency phản hồi bản nháp | Chưa đo | P95 < 5 giây, không tính thời gian API bản đồ | Log request/response timestamp |
| Tỷ lệ bản nháp được dispatcher chấp nhận sau chỉnh sửa nhỏ | Chưa đo | >= 85% | Phân loại mức chỉnh sửa trên ticket đã duyệt |

## 9. Phạm vi và giả định

- Prototype chỉ tạo bản nháp hoặc structured command; không tự gửi tin và không tự xác nhận cứu hộ đã hoàn tất.
- Rule pin dưới 5% và khoảng cách 5 km là ranh giới an toàn bắt buộc.
- Dữ liệu khoảng cách, mức pin và tình trạng trạm trong prototype là input từ người dùng; production cần lấy từ hệ thống được xác thực.
- Mọi con số chưa có nguồn dữ liệu nội bộ đều được đánh dấu là giả định để tránh trình bày như fact vận hành.
