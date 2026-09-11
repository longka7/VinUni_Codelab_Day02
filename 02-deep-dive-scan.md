# 02 - Deep Dive Report (Phase 2)

## 🃏 Phase 2 — QUICK-ASSESS (Extracted)

Chọn **top 3 bài toán** từ danh sách Phase 1 và hoàn thiện **3 Quick Problem Cards** (10 phút/card).

### QUICK PROBLEM CARD TEMPLATE

```
QUICK PROBLEM CARD #___

Bài toán (1 câu): ________________________________________
Công ty thành viên: [ ] VinFast  [ ] Xanh SM  [ ] Vinhomes
                    [ ] Vinmec   [ ] Khác (Ghi rõ)________

Ai đang đau (Actor)? ______________________________________

Workflow thủ công hiện tại (3-5 bước):
 1. ___ ──> 2. ___ ──> 3. ___ ──> 4. ___

Bước nào tốn thời gian/lỗi nhất? ___ (⏱ ___ phút/lượt)
AI có thể nhảy vào hỗ trợ ở bước nào? _____________________

Đo thành công bằng gì (Metric có số)? ______________________
VD: "Giảm thời gian soạn phản hồi từ 10 min ──> under 2 min"

Quick Architecture: [ ] No AI  [ ] Rule  [ ] LLM  [ ] Agent
```

---

### QUICK PROBLEM CARD #1 (Bài toán #5: Dynamic Real-Range Predictor)

**Bài toán (1 câu):** Dự báo quãng đường đi thực tế (Real-Range) theo vi khí hậu & tải giao thông cho xe điện Xanh SM.

**Công ty thành viên:** VinFast, Xanh SM

**Actor:** Tài xế (Range Anxiety), Điều phối viên

**Workflow thủ công hiện tại (4 bước):**
1. Xe báo pin yếu (<20%)
2. Tài xế nhẩm tính Range
3. Tắt app dừng ca sớm do sợ cạn pin giữa đường kẹt
4. Tổng đài gọi hỗ trợ cứu hộ nếu cạn pin thực địa.

**Bước tốn thời gian/lỗi nhất:** Bước 2 & 3 (⏱ 30 phút/lượt)

**AI có thể nhảy vào:** Bước 2 & 3 (Tính toán quãng đường thực tế & gợi ý lộ trình sạc)

**Metrics:** Giảm 50% số ca cạn pin thực địa & tăng 1.5h chạy ca/tài xế

**Quick Architecture:** Rule / Physics preferred

**Cautions (CFO & Ops):**
- LLM có rủi ro hallucination khi xử lý telemetry; rule/physics model có thể chính xác hơn.
- Chi phí API cho xử lý telemetry lớn có thể làm ROI âm.

---

### QUICK PROBLEM CARD #2 (Bài toán #3: Vinhomes Resident Complaint Agent)

**Bài toán (1 câu):** Phân loại tự động, đánh giá độ khẩn cấp & dự thảo phản hồi khiếu nại cư dân trên App Vinhomes.

**Actor:** Chuyên viên Ban Quản lý / CSKH Cư dân

**Workflow:**
1. Tiếp nhận ticket trên App
2. Đọc & gán nhãn thủ công
3. Chuyển tiếp phòng ban (Kỹ thuật/Vệ sinh/An ninh)
4. Soạn thư phản hồi thủ công gửi cư dân.

**Bước tốn thời gian/lỗi nhất:** Bước 2 & 4 (⏱ 12 phút/vé)

**AI có thể nhảy vào:** Bước 2, 3 & 4 (Phân loại ý định, trích xuất mức khẩn cấp & draft trả lời)

**Metrics:** Rút ngắn thời gian phản hồi từ 12 min ──> under 2 min; đạt 95% SLA xử lý phản hồi dưới 5 phút.

**Quick Architecture:** LLM with Rule-based pre-filter

**Cautions:**
- Use Rule-based FAQ filter before LLM to avoid API cost on static queries.
- No Auto-Send: human must review drafts before sending.

---

### QUICK PROBLEM CARD #3 (Bài toán #4: Vinmec Medical Discharge Summarizer)

**Bài toán (1 câu):** Tự động tổng hợp dữ liệu xét nghiệm & dự thảo tóm tắt hồ sơ y lệnh xuất viện cho bác sĩ Vinmec.

**Actor:** Bác sĩ điều trị / Y sĩ hành chính

**Workflow:**
1. Đọc lại toàn bộ hồ sơ xét nghiệm & sinh hiệu bệnh nhân
2. Soạn thủ công bản tóm tắt y lệnh xuất viện
3. Đối chiếu thủ công mã chẩn đoán ICD-10
4. In ấn và ký duyệt giấy tờ xuất viện.

**Bước tốn thời gian/lỗi nhất:** Bước 1 & 2 (⏱ 25 phút/ca)

**AI có thể nhảy vào:** Bước 1 & 2 (Trích xuất dữ liệu lâm sàng chính & soạn thảo văn bản nháp)

**Metrics:** Giảm thời gian soạn hồ sơ từ 25 min ──> under 5 min; bác sĩ tiết kiệm 1.5 giờ/ngày.

**Quick Architecture:** LLM with strict Human-in-the-loop and medical validation

---

Kết thúc Phase 2: Chuẩn bị Phase 3 Deep-Dive bằng cách chọn 1 bài toán để phân tích sâu.
