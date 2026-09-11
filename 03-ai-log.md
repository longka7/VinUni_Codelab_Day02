# 03 — AI Log & Reflection (Cá nhân: longkhanh)

## Phase 6 — Phản ánh cá nhân về việc dùng AI làm thought-partner

### AI giúp gì?

Tôi dùng Claude (Claude Code) làm trợ lý đồng hành xuyên suốt cả buổi lab, ở 3 việc cụ thể:

1. **Brainstorm SCAN (Phase 1-2):** thay vì tự nghĩ 5 bài toán từ đầu, tôi nhờ AI đề xuất các pain point thực tế theo 4 lens cho từng mảng kinh doanh Vingroup (VinFast, Xanh SM, Vinhomes, Vinmec, Vinpearl). AI đưa ra ý tưởng nhanh và đa dạng hơn nếu tôi tự brainstorm một mình, nhưng tôi vẫn phải tự đánh giá lại xem con số ước tính (ví dụ "15 phút/lượt", "~5.000 feedback/ngày") có hợp lý không — vì đây là số AI ước lượng dựa trên bối cảnh chung, không phải dữ liệu vận hành thật của Vingroup.
2. **Viết SYSTEM_PROMPT ràng buộc an toàn (Phase 4):** AI giúp diễn đạt 2 rule (tag `[DRAFT_ONLY]`, ngưỡng pin <5% → dispatch mobile charger) thành chỉ thị hệ thống rõ ràng, có cấu trúc, khó bị vượt qua. Đây là việc AI làm tốt hơn tôi tự viết vì nó biết cách diễn đạt để chống lại kiểu tấn công "giả vờ khẩn cấp để bỏ qua rule" — một kỹ thuật tôi chưa nghĩ tới trước khi thấy 2 test case mẫu.
3. **Debug lỗi kỹ thuật thực tế:** khi chạy `prompt_prototype.py` lần đầu, gặp lỗi `404 NOT_FOUND` vì model `gemini-2.5-flash` (được viết sẵn trong starter code) đã ngừng hỗ trợ cho key mới. AI đọc thẳng thông báo lỗi từ chính API (Google gợi ý đổi sang `gemini-3.6-flash`) thay vì đoán mò, sửa lại và chạy lại thành công.

### AI trả lời sai/hallucinate ở đâu?

- Không phải "hallucinate" theo nghĩa bịa thông tin, nhưng có một điểm dễ gây hiểu lầm: **thông tin AI biết (model, tên gọi, giá cả...) có thể đã lỗi thời** so với thời điểm thực tế chạy. Model `gemini-2.5-flash` trong code mẫu của giảng viên (viết trước đó) không còn khả dụng — nếu tôi tin tưởng tuyệt đối vào tên model AI gợi ý ban đầu mà không chạy thử thật, tôi sẽ mất thời gian debug sai hướng.
- Ở phần SCAN, các con số như thời gian xử lý, khối lượng feedback/ngày là **ước lượng hợp lý về mặt logic nhưng không phải dữ liệu thật** — nếu tôi copy nguyên những con số này vào báo cáo chính thức mà không gắn nhãn "giả định cần xác thực", đó sẽ là rủi ro trình bày sai lệch thông tin (giống lỗi mà bạn cùng nhóm Ngocngoc12 đã cẩn thận tránh bằng cách note rõ "baseline giả định" trong bài của họ).

### Tôi đã sửa prompt/ranh giới ra sao?

- Với phần kỹ thuật: khi gặp lỗi model, tôi không đoán tên model mới mà **đọc chính xác thông báo lỗi trả về từ API** để lấy tên model thay thế chính xác, tránh đoán mò một tên model không tồn tại.
- Với phần nội dung SCAN/Cards: tôi giữ lại các con số AI đề xuất làm khung tham khảo, nhưng tự đánh giá lại độ hợp lý dựa trên hiểu biết thực tế về vận hành (kinh nghiệm BA của tôi) trước khi đưa vào bài nộp, và ý thức rằng các số liệu này cần được đối chiếu với dữ liệu vận hành thật của Vingroup nếu dự án đi tiếp.
- Với ranh giới an toàn của prompt: tôi không chỉ tin vào SYSTEM_PROMPT được viết sẵn — tôi **chạy thật 2 adversarial test case** để kiểm chứng model có thực sự tuân thủ hay không, thay vì chỉ đọc prompt và cho rằng nó chắc chắn hoạt động đúng.

### Bài học rút ra

AI là một thought-partner tốt để tăng tốc brainstorm và viết prompt kỹ thuật, nhưng vai trò của tôi là **người xác thực** — kiểm tra lại số liệu, chạy thử thật để xác nhận hành vi, và không xem output của AI là "sự thật mặc định" chỉ vì nó được trình bày mạch lạc và tự tin.
