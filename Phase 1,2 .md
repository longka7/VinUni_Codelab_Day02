# 01 - Problem Scan

## Phase 1 - SCAN

| # | Subsidiary (VinFast/Xanh SM...) | Lens | Mo ta ngan bai toan |
|---|----------------------------------|------|---------------------|
| 1 | Xanh SM | Ton thoi gian | Dieu phoi vien mat nhieu thoi gian xu ly xe gan het pin giua ca va chon phuong an sac phu hop. |
| 2 | Xanh SM | Lap lai | Bo phan CSKH phai doc va phan loai thu cong hang tram phan anh cua khach hang sau chuyen di. |
| 3 | VinFast | Lap lai | Nhan vien phai doi soat thu cong hoa don sac dien giua tram sac, ung dung va he thong thanh toan. |
| 4 | Vinhomes | AI co the tot hon | Ban quan ly phan hoi cu dan cham vi phai doc, phan loai va soan tra loi tung phan anh rieng le. |
| 5 | Vinmec | Ton thoi gian | Nhan vien y te mat nhieu thoi gian tom tat ho so benh an truoc khi bac si kham. |

## Phase 2 - QUICK-ASSESS

### Quick Problem Card #1

| Truong | Noi dung |
|---|---|
| Bai toan (1 cau) | Dieu phoi vien Xanh SM mat nhieu thoi gian xu ly xe dien gan het pin giua ca va chon phuong an sac an toan. |
| Cong ty thanh vien | Xanh SM |
| Ai dang dau (Actor)? | Dieu phoi vien, tai xe Xanh SM, khach hang dang cho xe. |
| Workflow thu cong hien tai | 1. Tai xe bao pin thap qua app/tong dai --> 2. Dieu phoi vien kiem tra vi tri xe, pin, tram sac gan nhat --> 3. Dieu phoi vien goi/nhan tai xe de huong dan --> 4. Neu khong an toan thi lien he doi ho tro sac di dong. |
| Buoc ton thoi gian/loi nhat | Buoc 2 va 3, vi dieu phoi vien phai tu tong hop nhieu thong tin va ra quyet dinh nhanh. Uoc tinh 5-8 phut/luot. |
| AI ho tro o buoc nao? | AI ho tro doc tinh huong, tom tat muc do khan cap, de xuat draft phuong an dieu phoi va canh bao ranh gioi an toan. |
| Metric co so | Giam thoi gian xu ly tinh huong pin thap tu 8 phut xuong duoi 2 phut/luot; 95% case pin < 5% duoc chuyen sang mobile charger thay vi goi y tram xa. |
| Quick Architecture | LLM Feature ket hop rule safety. |

### Quick Problem Card #2

| Truong | Noi dung |
|---|---|
| Bai toan (1 cau) | Bo phan CSKH Xanh SM mat nhieu thoi gian doc va phan loai phan anh khach hang sau chuyen di. |
| Cong ty thanh vien | Xanh SM |
| Ai dang dau (Actor)? | Nhan vien CSKH, truong ca van hanh, khach hang gui phan anh. |
| Workflow thu cong hien tai | 1. Khach hang gui phan anh sau chuyen di --> 2. CSKH doc noi dung va lich su chuyen --> 3. CSKH gan nhan loi: tai xe, app, thanh toan, thai do, an toan --> 4. Chuyen ticket cho bo phan phu trach. |
| Buoc ton thoi gian/loi nhat | Buoc 2 va 3, vi noi dung phan anh tu do, nhieu cach dien dat va de gan sai nhan. Uoc tinh 3-5 phut/ticket. |
| AI ho tro o buoc nao? | AI phan loai ticket, tom tat noi dung chinh, de xuat muc do uu tien va bo phan xu ly. |
| Metric co so | 80% ticket duoc phan loai trong duoi 30 giay; giam thoi gian xu ly tu 5 phut xuong duoi 1 phut/ticket; do chinh xac phan loai dat toi thieu 85%. |
| Quick Architecture | LLM Feature. |

### Quick Problem Card #3

| Truong | Noi dung |
|---|---|
| Bai toan (1 cau) | Ban quan ly Vinhomes phan hoi cu dan cham vi phai doc, phan loai va soan tra loi tung phan anh thu cong. |
| Cong ty thanh vien | Vinhomes |
| Ai dang dau (Actor)? | Nhan vien ban quan ly, cu dan, bo phan ky thuat/bao ve/ve sinh. |
| Workflow thu cong hien tai | 1. Cu dan gui phan anh qua app/nhom chat --> 2. Nhan vien doc va xac dinh loai su co --> 3. Soan phan hoi tam thoi cho cu dan --> 4. Chuyen yeu cau cho bo phan phu trach va theo doi ket qua. |
| Buoc ton thoi gian/loi nhat | Buoc 2 va 3, vi phan anh nhieu loai va can giu giong van chuyen nghiep. Uoc tinh 5-7 phut/phan anh. |
| AI ho tro o buoc nao? | AI tom tat phan anh, phan loai phong ban, soan draft phan hoi lich su de nhan vien duyet. |
| Metric co so | Giam thoi gian soan phan hoi tu 7 phut xuong duoi 2 phut/phan anh; 90% phan hoi co draft trong 60 giay; 100% draft can nhan vien duyet truoc khi gui. |
| Quick Architecture | LLM Feature voi human-in-the-loop. |

## CFO va Operations Stress-Test

1. Diem yeu ve logic: Mot so bai toan co the da duoc giai quyet bang quy tac ro rang, dac biet la bai toan pin thap cua Xanh SM. Neu dieu kien chi la pin < 5%, khoang cach tram sac > 5km, va trang thai xe, thi rule-based code co the on dinh hon LLM.

2. Diem yeu ve metric: Cac con so hien la uoc tinh, chua co log van hanh thuc te de chung minh baseline. Truoc khi dau tu AI, can lay du lieu that ve so ticket/ngay, thoi gian xu ly trung binh, ty le gan nhan sai, va chi phi cham tre.

3. Diem yeu ve ranh gioi van hanh: AI khong duoc tu dong gui tin nhan, dieu xe, hoac dua ra khuyen nghi co rui ro an toan. Moi output nen la draft, co tag [DRAFT_ONLY], va can co human-in-the-loop cho case khan cap.

Rule-based code co the tot hon AI neu quy trinh co dieu kien ro rang, it can hieu ngon ngu tu do, va yeu cau ket qua quyet dinh 100% on dinh. Vi du: neu pin < 5% thi dispatch mobile charger; neu tram sac xa hon 5km thi khong goi y; neu pin >= 20% thi goi y tram gan nhat. Truong hop nay nen ket hop rule safety voi LLM de LLM chi soan draft va giai thich, con quyet dinh an toan cot loi do rule kiem soat.
