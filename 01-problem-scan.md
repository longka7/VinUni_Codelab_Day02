# Lab 02 — Problem Scan & Quick Assessment

## Phase 1 — SCAN

Bảng dưới đây dùng bốn lenses của lab để quét các bottleneck vận hành có tần suất cao, dữ liệu đầu vào có thể thu thập và kết quả đủ rõ để đo lường. Các ước lượng thời gian là giả định scoping, cần được xác nhận bằng dữ liệu vận hành trước pilot.

| # | Subsidiary | Actor | Tên bài toán | Pain point | Bottleneck | Lens | AI opportunity |
|---:|---|---|---|---|---|---|---|
| 1 | **VinFast** | NOC operator, charging operation engineer | Phát hiện sự cố trạm sạc EV | Cảnh báo từ charger, backend và payment system rời rạc; đội trực khó nhận ra incident thật giữa nhiều alert trùng. | Gom nhóm sự kiện, xác định phạm vi ảnh hưởng và ưu tiên severity còn thủ công. | Repetitive; Stakeholder Pain | Rule phát hiện threshold/known error; AI gom alert và chuẩn hóa incident để nhân sự xác nhận. |
| 2 | **VinFast** | Charging operation engineer | Phân tích nguyên nhân gốc sự cố trạm sạc | Kỹ sư phải đọc log, mã lỗi, lịch sử bảo trì và nhiều ticket cũ trước khi có giả thuyết RCA. | Dữ liệu phân tán, thiếu context chuẩn và phụ thuộc kinh nghiệm; khoảng 20–40 phút/incident. | Time-consuming; AI-upgrade | LLM tóm tắt timeline; RAG tìm manual, runbook và incident tương tự kèm dẫn nguồn; kỹ sư duyệt RCA. |
| 3 | **VinFast** | Field technician | Trợ lý kỹ thuật bảo trì trạm sạc | Kỹ thuật viên hiện trường khó tìm đúng tài liệu theo model, firmware và mã lỗi trong thời gian ngắn. | Tìm kiếm tài liệu và xác định checklist phù hợp; chọn sai phiên bản có thể tạo rủi ro an toàn. | Stakeholder Pain; AI-upgrade | RAG cung cấp checklist và trích dẫn đúng phiên bản; kỹ thuật viên xác nhận trước mọi thao tác điện, reset hoặc thay linh kiện. |
| 4 | **VinFast** | Chủ xe/tài xế, CSKH | Tìm trạm sạc phù hợp | Người dùng phải tự so sánh mức pin, đầu sạc, trạng thái trạm, giờ hoạt động và độ lệch tuyến. | Dữ liệu thay đổi nhanh và nhiều điều kiện bắt buộc; mất khoảng 8–15 phút/lượt tìm kiếm. | Time-consuming; AI-upgrade | Rule/API lọc điều kiện an toàn và dữ liệu thời gian thực; LLM hiểu nhu cầu; RAG giải thích chính sách có nguồn. |
| 5 | **Xanh SM** | Điều phối viên đội xe | Điều phối xe theo cung–cầu và trạng thái pin | Điều phối viên phải cân bằng vị trí, nhu cầu, mức pin, ca làm và điểm sạc; dễ tăng quãng đường rỗng. | So sánh nhiều ràng buộc liên tục trong giờ cao điểm. | Repetitive; Time-consuming | Dự báo nhu cầu kết hợp tối ưu hóa/rule để xếp hạng phương án; điều phối viên duyệt ngoại lệ. |
| 6 | **Xanh SM** | Tài xế, tổng đài viên, điều phối cứu hộ | Phân tích sự cố xe điện và điều phối cứu hộ | Báo cáo qua gọi/chat thường thiếu cấu trúc; tổng đài phải hỏi lại và mở nhiều hệ thống. | Phân loại severity, đối chiếu telemetry/SOP và chọn đội cứu hộ phù hợp; khoảng 10–20 phút triage. | Stakeholder Pain; Time-consuming | LLM trích xuất triệu chứng; rule bảo vệ tình huống khẩn cấp; RAG tìm SOP; dispatcher phê duyệt cứu hộ. |
| 7 | **Vinhomes** | Nhân viên CSKH, ban quản lý tòa nhà | Phân loại phản ánh cư dân | Phản ánh tự do dễ bị gắn sai nhóm và chuyển vòng giữa an ninh, kỹ thuật, vệ sinh. | Hiểu ý định, mức khẩn cấp, vị trí và định tuyến đúng SLA. | Repetitive; AI-upgrade | LLM phân loại nội dung; rule ánh xạ đội xử lý/SLA; case nhạy cảm hoặc confidence thấp chuyển nhân viên. |

**Coverage của 4 lenses:** Repetitive (#1, #5, #7), Time-consuming (#2, #4, #5, #6), AI-upgrade (#2, #3, #4, #7), Stakeholder Pain (#1, #3, #6).

## Phase 2 — QUICK-ASSESS

Ba bài toán được ưu tiên vì liên quan trực tiếp đến EV operations, có dữ liệu vận hành, metric đo được và có thể kiểm thử boundary bằng prototype.

## Quick Problem Card 1 — VinFast: AI Incident Intelligence cho trạm sạc EV

### Bài toán

Giúp đội Charge Operations phát hiện, hợp nhất và triage sớm sự cố trạm sạc từ cảnh báo, log và lịch sử vận hành để giảm downtime.

### Subsidiary và Actor

- **Subsidiary:** VinFast
- **Actor:** NOC operator, charging operation engineer, field technician; khách hàng là stakeholder chịu ảnh hưởng.

### Current workflow

Nhận cảnh báo từ charger/backend/payment system<br>
↓<br>
Đối chiếu log, error code và trạng thái session<br>
↓<br>
Tìm manual, runbook, lịch sử bảo trì và incident tương tự<br>
↓<br>
Đánh giá severity, tạo ticket và giao kỹ thuật xử lý<br>
↓<br>
Kỹ sư xác nhận RCA, action và kết quả

### Bottleneck

- **Bước chậm nhất:** Đối chiếu dữ liệu đa nguồn và tìm incident tương tự, khoảng **20–40 phút**.
- **Lỗi thường gặp:** Alert trùng, thiếu timeline, sai severity, dùng nhầm runbook hoặc thiếu bằng chứng trong ticket.
- **Tổng thời gian ước lượng:** **45–120 phút/incident** để có chẩn đoán và phương án ban đầu, chưa gồm di chuyển/sửa chữa.

### AI opportunity và architecture

- **Rule:** Threshold, known error, deduplication và guardrail an toàn.
- **LLM:** Chuẩn hóa log/ticket thành summary và timeline.
- **RAG:** Truy xuất manual/runbook/incident tương tự đúng phiên bản, có citation.
- **HITL:** NOC xác nhận severity; engineer duyệt RCA/action. AI không tự reset, đổi config, dispatch hoặc đóng incident nghiêm trọng.
- **Quick Architecture:** **LLM + RAG**, kết hợp Rule Engine.

### Success metrics

- Median time-to-triage: **30 phút → dưới 10 phút**.
- Downtime nhóm lỗi đã có runbook: giảm **20–30%**.
- Gợi ý incident severity cao: **precision ≥ 90%, recall ≥ 95%**.
- Action có rủi ro được human approval: **100%**.

---

## Quick Problem Card 2 — Xanh SM: AI hỗ trợ sự cố xe điện và điều phối cứu hộ

### Bài toán

Giúp tổng đài xác định nhanh mức độ sự cố và đề xuất phương án cứu hộ dựa trên mô tả tài xế, vị trí, telemetry và SOP.

### Subsidiary và Actor

- **Subsidiary:** Xanh SM (GSM)
- **Actor:** Tài xế, tổng đài viên, điều phối viên cứu hộ và đội kỹ thuật.

### Current workflow

Tài xế gọi/chat báo triệu chứng và vị trí<br>
↓<br>
Tổng đài hỏi lại và mở telemetry<br>
↓<br>
Tra SOP, phân loại severity<br>
↓<br>
Chọn đội cứu hộ và xe thay thế nếu cần<br>
↓<br>
Theo dõi đến khi người và xe an toàn

### Bottleneck

- **Bước chậm nhất:** Thu thập đủ thông tin và đối chiếu telemetry/SOP, khoảng **10–20 phút**.
- **Lỗi thường gặp:** Bỏ sót tín hiệu an toàn, hiểu sai mô tả, phân loại sai severity hoặc chọn sai năng lực cứu hộ.
- **Tổng thời gian ước lượng:** **20–45 phút/case** để xác nhận phương án, chưa gồm thời gian đội cứu hộ di chuyển.

### AI opportunity và architecture

- **Rule:** Ưu tiên va chạm, khói/cháy, nhiệt độ pin bất thường và lỗi điện cao áp.
- **LLM:** Trích xuất triệu chứng và sinh câu hỏi làm rõ.
- **RAG:** Truy xuất SOP theo model xe/mã lỗi.
- **Agent:** Chỉ có giá trị nếu cần gọi tuần tự telemetry, bản đồ và roster cứu hộ; agent chỉ xếp hạng đề xuất.
- **HITL:** Dispatcher duyệt mọi dispatch; tình huống nguy hiểm chuyển ngay quy trình khẩn cấp.
- **Quick Architecture:** **Agent có kiểm soát** cho orchestration đa công cụ, với Rule + LLM + RAG và approval bắt buộc.

### Success metrics

- Thời gian xác định phương án: **15 phút → dưới 5 phút** cho case thông thường.
- Nhận diện case cần emergency escalation: **recall ≥ 95%**.
- Giảm **20%** lượt điều nhầm đội/phương tiện và **15%** thời gian chờ hỗ trợ.

---

## Quick Problem Card 3 — VinFast: AI trợ lý tìm trạm sạc phù hợp

### Bài toán

Giúp khách hàng tìm và so sánh trạm sạc phù hợp với xe, mức pin, tuyến đường và nhu cầu hiện tại bằng dữ liệu có timestamp.

### Subsidiary và Actor

- **Subsidiary:** VinFast
- **Actor:** Chủ xe/tài xế VinFast và nhân viên CSKH.

### Current workflow

Mở bản đồ hoặc liên hệ CSKH<br>
↓<br>
Kiểm tra tương thích, giờ hoạt động và availability<br>
↓<br>
So sánh độ lệch tuyến, mức pin dự kiến và tiện ích<br>
↓<br>
Chọn trạm và đổi phương án nếu trạm đầy/ngừng hoạt động

### Bottleneck

- **Bước chậm nhất:** Tổng hợp nhiều điều kiện giữa các trạm, khoảng **5–12 phút**.
- **Lỗi thường gặp:** Chọn trạm không tương thích, dùng trạng thái cũ hoặc thiếu biên an toàn về pin.
- **Tổng thời gian ước lượng:** **8–15 phút/lượt tìm kiếm**.

### AI opportunity và architecture

- **Rule/API:** Lọc chuẩn đầu sạc, trạng thái, giờ mở cửa, phạm vi pin và ngưỡng an toàn.
- **LLM:** Hiểu yêu cầu tự nhiên và giải thích trade-off.
- **RAG:** Truy xuất chính sách/hướng dẫn; availability và ETA luôn lấy từ API thời gian thực.
- **HITL:** Khách hàng chọn trạm và xác nhận điều hướng; hệ thống cảnh báo khi pin thấp hoặc dữ liệu cũ.
- **Quick Architecture:** **LLM + RAG**, kết hợp Rule/API.

### Success metrics

- Thời gian tìm trạm: **8 phút → dưới 2 phút**.
- Gợi ý vượt qua điều kiện tương thích và phạm vi pin: **≥ 95%**.
- Giảm **20%** lượt đổi trạm do thông tin không phù hợp; mọi trạng thái hiển thị timestamp.

## Quyết định chọn bài toán Deep-Dive

Chọn **Card 1 — AI Incident Intelligence cho trạm sạc EV VinFast** vì workflow và ownership rõ, dữ liệu telemetry/log/ticket có thể audit, giá trị gắn trực tiếp với downtime/SLA, đồng thời có ranh giới hợp lý giữa Rule, LLM + RAG và quyết định của kỹ sư.
