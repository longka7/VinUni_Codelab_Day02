# 02 — Deep-Dive Report (Cá nhân: longkhanh)

> Bài toán chọn để đào sâu: **Vinmec — Soạn tóm tắt hồ sơ xuất viện**
> (Card #3 trong `01-problem-scan.md` của longkhanh)

---

## 3.1. Current-State Workflow Mapping

Quy trình soạn tóm tắt xuất viện hiện tại của bác sĩ điều trị tại Vinmec:

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Bước 1       │     │ Bước 2       │     │ Bước 3       │     │ Bước 4       │     │ Bước 5       │
│ Bệnh nhân đủ │     │ Bác sĩ tổng  │     │ Soạn tóm tắt │     │ Ký duyệt     │     │ Bàn giao cho │
│ điều kiện    │ ──→ │ hợp hồ sơ    │ ──→ │ xuất viện    │ ──→ │              │ ──→ │ bệnh nhân/   │
│ xuất viện    │     │ (chẩn đoán,  │     │ bằng tay 🔴  │     │              │     │ khoa khác 🔄 │
│              │     │ thuốc, chỉ   │     │              │     │              │     │              │
│              │     │ định) 🔴     │     │              │     │              │     │              │
│ Ai: Điều     │     │ Ai: Bác sĩ   │     │ Ai: Bác sĩ   │     │ Ai: Bác sĩ   │     │ Ai: Bác sĩ → │
│ dưỡng/BS     │     │ điều trị     │     │ điều trị     │     │ điều trị     │     │ BN/khoa khác │
│ ⏱ 2 phút     │     │ ⏱ 10 phút    │     │ ⏱ 15 phút    │     │ ⏱ 3 phút     │     │ ⏱ 2 phút     │
│ In: Hồ sơ EMR│     │ In: Nhiều    │     │ In: Ghi chú  │     │ In: Bản nháp │     │ In: Bản ký   │
│              │     │ lần khám     │     │ tổng hợp     │     │ tóm tắt      │     │ duyệt        │
│ Out: Danh    │     │ Out: Ghi chú │     │ Out: Bản     │     │ Out: Bản ký  │     │ Out: Hồ sơ   │
│ sách cần     │     │ tổng hợp thô │     │ nháp tóm tắt │     │ duyệt        │     │ bàn giao     │
│ tổng hợp     │     │              │     │              │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘

🔴 Bottleneck: Bước 2-3 (tổng hợp + soạn thảo) — mất 25 phút/25-30 phút tổng, chiếm phần lớn thời gian toàn quy trình.
🔄 Handoff: Bước 5 — điểm chuyển giao thông tin từ bác sĩ sang bệnh nhân/khoa tiếp nhận, dễ thiếu sót nếu bản tóm tắt viết vội.
⏱ Tổng thời gian xử lý thủ công: ~30 phút/ca (giả định dựa trên mô tả bài toán, cần xác thực bằng khảo sát bác sĩ thực tế nếu triển khai).
```

---

## 3.2. Problem Statement (6-field) & Metrics

| Field | Nội dung chi tiết |
|---|---|
| **1. Actor / Operator** | Bác sĩ điều trị tại các khoa nội trú của Vinmec. |
| **2. Current Workflow** | Khi bệnh nhân đủ điều kiện xuất viện, bác sĩ tự tổng hợp toàn bộ hồ sơ (chẩn đoán, thuốc đã dùng, chỉ định, diễn biến điều trị) từ nhiều lần khám trong hệ thống EMR, sau đó tự tay soạn bản tóm tắt xuất viện, ký duyệt, rồi bàn giao cho bệnh nhân hoặc khoa tiếp nhận khác. Toàn bộ 5 bước, phần tổng hợp + soạn thảo hoàn toàn thủ công. |
| **3. Bottleneck** | Bước 2-3 (tổng hợp hồ sơ + soạn tóm tắt bằng tay) — mất khoảng 20-25 phút/bệnh nhân, đặc biệt quá tải vào khung giờ cao điểm xuất viện (thường cuối buổi sáng), khi nhiều bệnh nhân xuất viện cùng lúc. |
| **4. Business Impact** | Giả định trung bình mỗi khoa nội trú xử lý ~15-20 ca xuất viện/ngày → tương đương 5-8 giờ làm việc bác sĩ/ngày/khoa chỉ để soạn tóm tắt. Rủi ro chất lượng: khi bác sĩ vội, tóm tắt có thể bỏ sót chi tiết quan trọng (liều thuốc, dấu hiệu cần tái khám), ảnh hưởng tới an toàn bệnh nhân sau xuất viện. *(Con số thời gian/số ca là ước lượng dựa trên mô tả bài toán, cần xác thực bằng dữ liệu vận hành thật của Vinmec trước khi trình bày như số liệu chính thức.)* |
| **5. Success Metric** | 1. Giảm thời gian soạn tóm tắt từ ~25 phút xuống dưới 5 phút/ca (bác sĩ chỉ review + chỉnh sửa bản nháp AI).<br>2. Tỉ lệ bản nháp được bác sĩ chấp nhận sau chỉnh sửa nhỏ (không viết lại từ đầu) đạt ≥ 85%.<br>3. 0% trường hợp bỏ sót thông tin thuốc/chỉ định quan trọng so với hồ sơ gốc (kiểm tra qua audit mẫu). |
| **6. Operational Boundary** | AI được phép: đọc dữ liệu từ hồ sơ điện tử (EMR) đã được xác thực, soạn **bản nháp** tóm tắt xuất viện theo mẫu chuẩn của Vinmec. **CẤM tuyệt đối:** AI không được tự động ký duyệt hoặc phát hành tóm tắt mà không qua bác sĩ điều trị xác nhận (bắt buộc HITL 100% các ca); không được tự suy diễn hoặc thêm chẩn đoán/chỉ định không có trong hồ sơ gốc; không được xử lý các ca có ghi chú "phức tạp/hội chẩn nhiều khoa" mà không gắn cờ cảnh báo cho bác sĩ review kỹ hơn. |

---

## 3.3. Future-State Flow & AI Fit

**AI Fit:** **LLM Feature** — không cần Agentic Loop vì quy trình có cấu trúc cố định (nguồn dữ liệu là EMR có sẵn, đầu ra là một tài liệu theo mẫu chuẩn); không dùng thuần Rule/State-Machine vì nội dung tóm tắt cần diễn đạt tự nhiên, tổng hợp thông tin phi cấu trúc (ghi chú bác sĩ, diễn biến điều trị) mà rule cứng không xử lý tốt.

```text
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ Bước 1       │     │ Bước 2       │     │ Bước 3       │     │ Bước 4       │
│ Bệnh nhân đủ │     │ 🔵 AI tự     │     │ 🔵 AI draft  │     │ 🟢 Bác sĩ    │
│ điều kiện    │ ──→ │ động tổng    │ ──→ │ bản tóm tắt  │ ──→ │ review, sửa  │
│ xuất viện    │     │ hợp hồ sơ    │     │ xuất viện    │     │ nếu cần, ký  │
│              │     │ từ EMR       │     │ theo mẫu     │     │ duyệt        │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                                                                      │
                                                                      ▼
                                                               ↩️ Fallback:
                                                               Nếu ca được AI
                                                               tự gắn cờ "phức
                                                               tạp/hội chẩn
                                                               nhiều khoa", hoặc
                                                               bác sĩ thấy bản
                                                               nháp thiếu chính
                                                               xác → bác sĩ tự
                                                               soạn lại như quy
                                                               trình cũ, không
                                                               ép dùng AI.
```

- 🔵 **AI Step:** Bước 2-3 — tự động tổng hợp hồ sơ nhiều lần khám và soạn bản nháp tóm tắt theo mẫu chuẩn.
- 🟢 **Human Step (HITL):** Bước 4 — bác sĩ điều trị bắt buộc review, chỉnh sửa (nếu cần) và ký duyệt trước khi tóm tắt được bàn giao. Không có bước nào trong quy trình cho phép bỏ qua bác sĩ.
- ↩️ **Fallback:** Ca phức tạp (hội chẩn nhiều khoa, chẩn đoán chưa thống nhất) được AI tự gắn cờ cảnh báo thay vì cố soạn tóm tắt có thể sai; bác sĩ quay lại quy trình thủ công như cũ cho các ca này.

---

## Phase 5 — EVALUATE

### AI Readiness Checklist

1. [x] Chúng tôi có sẵn dữ liệu mẫu/logs sạch để test? → **Có một phần** — Vinmec đã có hệ thống EMR số hóa, nhưng chưa có bộ dữ liệu mẫu tóm tắt xuất viện đã được gán nhãn "đạt chuẩn" để dùng làm ground-truth đánh giá chất lượng bản nháp AI.
2. [x] Rủi ro khi AI sai có nằm trong tầm kiểm soát (qua HITL hoặc Fallback)? → **Có** — 100% ca đều qua bác sĩ ký duyệt trước khi phát hành, và có cơ chế fallback tự động gắn cờ ca phức tạp.
3. [ ] Stakeholders sẵn sàng thay đổi quy trình làm việc cũ? → **Chưa xác nhận** — cần khảo sát mức độ sẵn sàng của đội ngũ bác sĩ trước khi triển khai pilot, vì đây là thay đổi quy trình lâm sàng nhạy cảm.

### Quyết định cuối cùng: **NOT YET (Cần tích lũy thêm dữ liệu/xác lập baseline)**

**Justification:**
> Bài toán có tiềm năng tác động rõ (giảm thời gian bác sĩ, giảm rủi ro thiếu sót thông tin bàn giao) và ranh giới an toàn có thể thiết kế chặt chẽ (HITL bắt buộc 100%, fallback cho ca phức tạp) — về mặt kỹ thuật, kiến trúc LLM Feature là phù hợp. Tuy nhiên, khác với candidate "Xanh SM pin yếu" mà nhóm đã có prototype thật và log kiểm thử ranh giới an toàn (2/2 rule pass qua Gemini API), bài toán Vinmec này **chưa có bất kỳ bằng chứng thực nghiệm nào** — chưa có dữ liệu mẫu tóm tắt đã gán nhãn để đánh giá chất lượng, và đặc biệt là **chưa xác nhận mức độ sẵn sàng thay đổi quy trình của đội ngũ bác sĩ** — yếu tố con người thường quyết định thành bại của một dự án AI trong môi trường y tế nhiều hơn là yếu tố kỹ thuật thuần túy. Quyết định trung thực ở giai đoạn này là **NOT YET**: cần một vòng khảo sát nhanh với bác sĩ + thu thập 20-30 mẫu tóm tắt đã qua chuẩn hóa trước khi chuyển sang GO xây dựng prototype.
