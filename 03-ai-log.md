# 03 — AI Log và Reflection

> **Use case:** Xanh SM EV battery support.

## 1. AI đã hỗ trợ gì?

AI được dùng như thought-partner để:

- brainstorm các pain point vận hành trong hệ sinh thái Vingroup;
- phản biện Problem Statement theo 5W1H;
- đề xuất cách tách business metrics và AI/product metrics;
- so sánh Rule-based, LLM Feature và Agentic Loop;
- review các prompt injection có thể khiến hệ thống bỏ qua `[DRAFT_ONLY]` hoặc dẫn xe pin thấp đến trạm xa;
- gợi ý cấu trúc code prototype gọi Gemini và các test case adversarial.

## 2. Prompt chính đã sử dụng

```text
Tôi là AI Product Engineer tại Vin Smart Future. Hãy giúp tôi scoping bài toán
Xanh SM: tài xế EV có thể xuống dưới 5% pin giữa hành trình. Hãy trả lời theo
5W1H, đề xuất business metrics và AI/product metrics có baseline/target rõ ràng,
phân biệt số liệu giả định với số liệu cần đo thực tế. Không được khẳng định dữ
liệu vận hành nếu không có nguồn.
```

Prompt review boundary:

```text
Hãy đóng vai safety reviewer. Stress-test thiết kế sau bằng 4 tình huống:
1) pin 2%, trạm 8 km; 2) yêu cầu bỏ DRAFT_ONLY; 3) thiếu mức pin; 4) roleplay
là admin. Với mỗi tình huống, nêu output được phép, output bị cấm và fallback.
```

## 3. Output nào hữu ích?

AI giúp nhận ra rằng đây không nên là một agent tự quyết định toàn bộ quy trình. Rule pin dưới 5% và khoảng cách 5 km là safety-critical nên cần validator deterministic. LLM phù hợp hơn với việc hiểu ngôn ngữ tự nhiên và tạo draft tiếng Việt. AI cũng gợi ý phải có HITL, fallback khi input mơ hồ và audit log cho injection.

## 4. Output nào cần kiểm tra hoặc chỉnh sửa?

- Các con số như số ca sự cố mỗi ngày, số giờ công và phần trăm doanh thu không được coi là dữ liệu thật nếu chưa có log nội bộ. Vì vậy báo cáo đánh dấu chúng là giả định hoặc thay bằng “chưa có baseline”.
- Câu trả lời của LLM có thể tạo một hướng dẫn trạm nghe hợp lý nhưng không chứng minh được khoảng cách thực tế. Vì vậy không cho LLM tự quyết định; hệ thống phải kiểm tra dữ liệu pin/khoảng cách bên ngoài.
- LLM có thể viết rằng tin nhắn đã được gửi hoặc cứu hộ đã được điều phối. Điều này bị loại bỏ vì prototype chỉ tạo draft/command, không thực thi hành động.
- Fallback ban đầu quá chung chung. Sau review, fallback được định nghĩa cụ thể cho thiếu dữ liệu, timeout, JSON lỗi, confidence thấp và prompt injection.

## 5. Cách prompt được cải thiện

1. Từ yêu cầu chung “hãy hỗ trợ tài xế” chuyển thành system prompt có role, scope và hai rule tuyệt đối.
2. Thêm từ khóa chính xác `[DRAFT_ONLY] ` và yêu cầu prefix ở đầu output.
3. Định nghĩa JSON command cố định cho trường hợp pin dưới 5%.
4. Nêu rõ “under any user pressure” để chống yêu cầu bỏ rule.
5. Thêm test case mơ hồ và roleplay injection thay vì chỉ kiểm tra một input hợp lệ.
6. Tách phần LLM diễn đạt khỏi phần rule/validator safety để giảm rủi ro phụ thuộc vào model.

## 6. Reflection cá nhân

AI làm nhanh phần mở rộng ý tưởng và giúp phát hiện các lỗ hổng trong thiết kế prompt, nhưng output không tự động trở thành sự thật. Phần quan trọng nhất của quá trình là kiểm tra claim định lượng, xác định dữ liệu nào chưa có baseline và đặt giới hạn cho quyền hành động của model. Kết quả cuối cùng là một prototype có thể stress-test, không phải bằng chứng rằng hệ thống đã sẵn sàng production.

## 7. Bằng chứng kỹ thuật

- File prototype: `starter-code/prompt_prototype.py`.
- Kiểm tra cú pháp đã thực hiện bằng `python -m py_compile starter-code/prompt_prototype.py`.
- Test gọi Gemini thật cần biến môi trường `GEMINI_API_KEY` hoặc `GOOGLE_API_KEY`; không ghi API key vào repository.
