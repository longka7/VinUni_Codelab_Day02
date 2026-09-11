# 02 - Deep-Dive Report

## Bài toán được chọn

**Xanh SM xử lý xe điện gần hết pin giữa ca vận hành.**

Điều phối viên Xanh SM hiện phải xử lý thủ công các tình huống tài xế báo pin thấp trong khi vẫn đang trong ca chạy. Nếu quyết định chậm hoặc sai, xe có thể không đủ pin để tới trạm sạc, khách bị chậm chuyến, tài xế bị gián đoạn ca làm, và đội vận hành phải xử lý sự cố khẩn cấp.

---

## 3.1. Current-State Workflow Mapping

**Tổng thời gian vận hành trung bình = 18 phút/lượt**

| Bước | Người/Bộ phận | Mô tả hiện tại | Thời gian ước tính | Ký hiệu |
|---|---|---|---:|---|
| 1 | Tài xế Xanh SM | Tài xế phát hiện pin thấp, gửi tin nhắn/gọi tổng đài hoặc báo qua app. | 2 phút | 🔄 Handoff: Tài xế -> Điều phối viên |
| 2 | Điều phối viên | Kiểm tra mức pin, vị trí GPS, tình trạng chuyến hiện tại và khoảng cách tới trạm sạc gần nhất. | 6 phút | 🔴 Bottleneck |
| 3 | Điều phối viên | Tự đánh giá phương án: tiếp tục chuyến, chuyển khách, hướng dẫn tới trạm sạc, hoặc gọi đội hỗ trợ. | 4 phút | 🔴 Bottleneck |
| 4 | Điều phối viên -> Tài xế | Gọi/nhắn hướng dẫn tài xế theo phương án đã chọn. | 3 phút | 🔄 Handoff: Điều phối viên -> Tài xế |
| 5 | Đội hỗ trợ vận hành | Nếu pin quá thấp, điều phối viên liên hệ đội sạc/cứu hộ di động. | 3 phút | 🔄 Handoff: Điều phối viên -> Đội hỗ trợ |

### Workflow hiện tại dạng luồng

```text
Tài xế báo pin thấp
  -> 🔄 Điều phối viên nhận thông tin
  -> 🔴 Kiểm tra pin + GPS + trạm sạc + tình trạng chuyến
  -> 🔴 Tự chọn phương án xử lý
  -> 🔄 Nhắn/gọi tài xế
  -> 🔄 Nếu khẩn cấp: chuyển đội sạc/cứu hộ di động
```

### Bottleneck chính

Bottleneck lớn nhất nằm ở bước 2 và bước 3. Điều phối viên phải tổng hợp nhiều dữ liệu trong thời gian ngắn, nhưng quyết định lại có rủi ro an toàn: nếu xe chỉ còn dưới 5% pin mà vẫn bị hướng dẫn tới trạm sạc xa, xe có thể chết pin giữa đường.

---

## 3.2. Problem Statement (6-field) & Metrics

| Field | Nội dung chi tiết |
|---|---|
| **1. Actor / Operator** | Điều phối viên Xanh SM là người xử lý tác vụ hằng ngày. Các bên liên quan gồm tài xế, khách hàng đang chờ/đang đi chuyến, và đội hỗ trợ sạc/cứu hộ di động. |
| **2. Current Workflow** | Tài xế báo pin thấp qua app/tổng đài. Điều phối viên kiểm tra thủ công mức pin, vị trí GPS, trạm sạc gần nhất, trạng thái chuyến và mức độ khẩn cấp. Sau đó điều phối viên tự soạn hướng dẫn cho tài xế hoặc liên hệ đội hỗ trợ. Công cụ hiện tại gồm app vận hành, bản đồ/GPS, dashboard trạm sạc và kênh gọi/nhắn nội bộ. |
| **3. Bottleneck** | Bước kiểm tra dữ liệu và ra quyết định xử lý là chậm nhất, khoảng 10 phút/lượt cho riêng bước 2-3. Đây cũng là điểm dễ lỗi vì điều phối viên có thể bỏ sót mức pin, khoảng cách trạm sạc hoặc yêu cầu an toàn trong tình huống gấp. |
| **4. Business Impact** | Mỗi tình huống mất trung bình 18 phút xử lý. Nếu có 100 tình huống/ngày, đội vận hành mất khoảng 30 giờ công/ngày. Chậm xử lý có thể làm trễ chuyến 10-20 phút, giảm trải nghiệm khách hàng, giảm số chuyến/tài xế/ca và tăng chi phí hỗ trợ khẩn cấp. |
| **5. Success Metric** | Giảm thời gian xử lý từ 18 phút xuống dưới 5 phút/lượt. 95% trường hợp pin dưới 5% được đề xuất dispatch mobile charger. 100% tin nhắn gửi tài xế/khách hàng phải là draft có tag `[DRAFT_ONLY]` và cần điều phối viên duyệt trước khi gửi. |
| **6. Operational Boundary** | AI được phép đọc tình huống, tóm tắt mức độ khẩn cấp, tạo draft hướng dẫn và đề xuất action. AI tuyệt đối không được tự gửi tin nhắn, tự điều xe, tự xác nhận đã dispatch, hoặc gợi ý trạm sạc xa hơn 5km khi pin dưới 5%. Với pin dưới 5%, AI phải đề xuất `dispatch_mobile_charger`. Điều phối viên là người duyệt cuối cùng. |

---

## 3.3. Future-State Flow & AI Fit

### AI-Fit Matrix

Giải pháp phù hợp nhất: **LLM Feature kết hợp Rule / State-Machine**.

Không nên dùng Agentic Loop đầy đủ ở giai đoạn đầu vì bài toán có rủi ro vận hành và an toàn. Phần quyết định cứng như `pin < 5%` nên do rule kiểm soát. LLM phù hợp để đọc mô tả tình huống, tóm tắt, giải thích lý do và soạn draft tin nhắn cho điều phối viên.

| Thành phần | Vai trò |
|---|---|
| Rule / State-Machine | Kiểm tra điều kiện an toàn: pin dưới 5%, khoảng cách trạm sạc, có cần mobile charger hay không. |
| LLM Feature | Tóm tắt tình huống, tạo draft phản hồi, giải thích lý do đề xuất. |
| Human-in-the-loop | Điều phối viên duyệt action và tin nhắn trước khi gửi hoặc dispatch thật. |

### Future-State Flow

```text
Tài xế báo pin thấp qua app/tổng đài
  -> Hệ thống lấy dữ liệu pin, GPS, trạm sạc gần nhất, trạng thái chuyến
  -> 🔵 AI Step: LLM tóm tắt tình huống và tạo draft phản hồi
  -> Rule Safety Check:
       - Nếu pin < 5% và trạm sạc > 5km: bắt buộc đề xuất dispatch_mobile_charger
       - Nếu dữ liệu thiếu hoặc mâu thuẫn: yêu cầu điều phối viên kiểm tra thủ công
  -> 🟢 Human Step: Điều phối viên xem draft, kiểm tra action, duyệt hoặc chỉnh sửa
  -> Gửi hướng dẫn cho tài xế / chuyển đội sạc di động
  -> ↩️ Fallback: Nếu AI lỗi hoặc confidence thấp, chuyển về quy trình thủ công hiện tại
```

### Luồng tương lai chi tiết

| Bước | Loại bước | Mô tả |
|---|---|---|
| 1 | Human/System | Tài xế gửi báo cáo pin thấp; hệ thống tự lấy pin, GPS, chuyến hiện tại và trạm sạc gần nhất. |
| 2 | 🔵 AI Step | LLM đọc dữ liệu và mô tả tình huống bằng ngôn ngữ ngắn gọn cho điều phối viên. |
| 3 | Rule Safety | Rule kiểm tra mức pin và khoảng cách. Nếu pin dưới 5%, không cho phép gợi ý trạm sạc xa hơn 5km. |
| 4 | 🔵 AI Step | LLM tạo draft output bắt đầu bằng `[DRAFT_ONLY]`, gồm action đề xuất và lý do. |
| 5 | 🟢 Human Step | Điều phối viên duyệt action, chỉnh nội dung nếu cần, rồi mới gửi cho tài xế hoặc đội hỗ trợ. |
| 6 | ↩️ Fallback | Nếu thiếu dữ liệu GPS/pin hoặc output AI không đúng format, hệ thống khóa gửi tự động và chuyển sang xử lý thủ công. |

### Ranh giới và fallback

- Mọi phản hồi của AI phải bắt đầu bằng `[DRAFT_ONLY]`.
- AI không được tự gửi tin nhắn cho tài xế hoặc khách hàng.
- AI không được tự xác nhận rằng xe sạc di động đã được dispatch.
- Nếu pin dưới 5%, AI không được đề xuất trạm sạc xa hơn 5km.
- Nếu pin dưới 5% và không có trạm sạc an toàn gần hơn hoặc bằng 5km, action bắt buộc là:

```json
{"action": "dispatch_mobile_charger", "reason": "Battery level is below 5%, so driving to a farther charging station is unsafe."}
```

### Kết luận Phase 3

Quyết định đề xuất: **GO với scope hẹp**.

Lý do: bài toán có bottleneck rõ, metric đo được, ranh giới an toàn có thể kiểm soát bằng rule, và LLM chỉ đóng vai trò hỗ trợ soạn draft/tóm tắt thay vì tự động vận hành. Prototype nên bắt đầu bằng một màn hình nội bộ cho điều phối viên, chưa tự động gửi tin nhắn hoặc dispatch thật.

