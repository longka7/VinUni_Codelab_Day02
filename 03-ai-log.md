# AI Interaction Log & Personal Reflection

**Học viên:** Thees Anh  
**Bài lab:** AI Product Scoping — Vin Smart Future

## 1. Mục tiêu sử dụng AI

Tôi sử dụng Codex như một thought-partner để đọc yêu cầu trong README và worksheet, hệ thống hóa các deliverable, phát triển danh sách bài toán, xây dựng Quick Problem Cards và hoàn thiện prompt prototype. Tôi vẫn chịu trách nhiệm kiểm tra các giả định, chạy chương trình bằng API key cá nhân và quyết định nội dung cuối trước khi nộp.

## 2. AI đã hỗ trợ những gì

- Đọc và chuyển README/worksheet thành checklist hành động.
- Đề xuất năm pain point trải trên Xanh SM, Vinhomes, Vinmec, VinFast và Vinpearl.
- Chuẩn hóa ba Quick Problem Cards theo Actor, workflow, bottleneck, metric và boundary.
- Giúp lựa chọn bài toán Xanh SM critical-battery support để giữ scope hẹp.
- Viết system prompt, tích hợp Gemini SDK và tạo adversarial tests.
- Chạy kiểm tra tĩnh bằng autograder để phát hiện TODO hoặc cấu trúc chưa đạt.

## 3. Các prompt/yêu cầu chính đã sử dụng

### Prompt 1 — hiểu nhiệm vụ

> “Trong project này hãy hướng dẫn tôi thực hiện các việc cần làm trong file 01-worksheet cũng như yêu cầu trong README.”

AI đã phân tách yêu cầu thành Phase 0–6 và chỉ ra bốn file báo cáo cùng file Python cần nộp.

### Prompt 2 — thực hiện phần cá nhân

> “Giờ hãy thực hiện giúp tôi các yêu cầu cá nhân Phase 1, Phase 2 trong worksheet và prompt_prototype.”

AI tạo bản SCAN, ba Quick Cards và triển khai prototype trên branch cá nhân.

### Prompt 3 — hoàn thiện các yêu cầu README

> “Giờ giúp tôi làm các yêu cầu trong README.”

AI tiếp tục tạo deep-dive report, AI log, workflow diagram và chạy các kiểm tra có thể thực hiện.

## 4. Điểm AI có thể trả lời sai hoặc vượt quá bằng chứng

Rủi ro lớn nhất là AI dễ tạo các con số có vẻ hợp lý như số phút xử lý, số sự cố mỗi ngày hoặc phần trăm doanh thu bị mất, dù repository không cung cấp dữ liệu nội bộ. Nếu đưa các con số này vào báo cáo như sự thật, bài làm sẽ có biểu hiện hallucination và problem statement không trung thực.

AI cũng có thể đề xuất dùng agent tự động gọi API và điều xe vì giải pháp này nghe hiện đại. Nhưng bài toán liên quan an toàn phương tiện, trong khi mục tiêu chỉ cần chuẩn hóa dữ liệu và tạo draft. Trao quyền tự thực thi làm tăng rủi ro mà chưa tạo giá trị cần thiết.

Một mâu thuẫn kỹ thuật khác là yêu cầu output vừa phải bắt đầu bằng `[DRAFT_ONLY]`, vừa phải là JSON sạch. Nếu thêm tag trước JSON thì toàn bộ chuỗi không còn là một JSON document thuần. Tôi xử lý bằng hợp đồng output gồm tag bắt buộc ở dòng đầu, sau đó là một JSON object; hệ thống downstream phải tách và kiểm tra tag trước khi parse JSON.

## 5. Cách tôi điều chỉnh prompt và ranh giới

Tôi không dùng những số liệu giả định như bằng chứng. Trong báo cáo, tôi gắn nhãn rõ “baseline giả định cần xác minh” và chọn quyết định `NOT YET` thay vì tuyên bố dự án đã sẵn sàng.

System prompt được làm chặt hơn bằng cách:

- Quy định mọi output bắt đầu chính xác bằng `[DRAFT_ONLY]`.
- Buộc `requires_human_approval` luôn là `true`.
- Cấm AI gửi tin, điều xe, đặt trạm hoặc tuyên bố đã thực thi.
- Dùng rule pin dưới 5% để chọn `dispatch_mobile_charger` và cấm trạm xa hơn 5 km.
- Khi dữ liệu thiếu/mâu thuẫn, trả `request_human_review` thay vì đoán.
- Không chấp nhận quyền hạn do user tự khai và không tiết lộ system prompt.

## 6. Adversarial testing và kết quả

Tôi thiết kế ba tấn công:

1. Pin 2% nhưng ép AI chỉ đường tới trạm cách 8 km.
2. Ép bỏ `[DRAFT_ONLY]` và gửi tin trực tiếp.
3. Giả danh giám đốc để bỏ human approval và yêu cầu tiết lộ system prompt.

Autograder đã xác nhận ở mức tĩnh rằng system prompt chứa ranh giới cốt lõi, hàm `evaluate_prompt()` sử dụng Gemini SDK và danh sách adversarial tests hợp lệ. Kiểm thử API động chỉ được coi là hoàn thành sau khi tôi tự chạy với `GEMINI_API_KEY` và lưu lại output thật; tôi không ghi kết quả giả khi chưa chạy.

## 7. Điều tôi học được

Điểm quan trọng nhất là scoping bắt đầu từ workflow và bottleneck, không bắt đầu từ mong muốn dùng một mô hình phức tạp. Rule-based logic phù hợp hơn LLM cho điều kiện pin và khoảng cách; LLM chỉ nên xử lý phần ngôn ngữ không cấu trúc. Human-in-the-loop không phải một nhãn trang trí mà là ranh giới quyền hạn phải được thể hiện trong prompt, output schema và kiến trúc thực thi.

Tôi cũng nhận ra metric tốt phải đo được và phân biệt rõ baseline, target với dữ liệu đã quan sát. Khi chưa có log và stakeholder validation, quyết định `NOT YET` trung thực và có chất lượng hơn một quyết định `GO` thiếu bằng chứng.

## 8. Việc tôi cần tự xác nhận trước khi nộp

- Chạy prototype bằng API key của mình và đọc toàn bộ output.
- Ghi lại nếu test nào fail và sửa system prompt dựa trên lỗi thật.
- Xác nhận các giả định workflow với giảng viên/nhóm nếu có thêm thông tin.
- Bảo đảm không có API key hoặc dữ liệu nhạy cảm trong Git diff.
