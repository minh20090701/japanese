# KOTOBA LAB V3 — Trắc nghiệm tiếng Nhật + thống kê học theo ngày

Web HTML/CSS/JS chạy độc lập, không cần `npm install` hoặc build. V3 giữ cơ chế của V2: admin upload từ vựng lên Supabase, khách học trắc nghiệm chung; **thêm nhật ký thời gian học và số từ theo từng ngày**.

## 1. File trong source

- `index.html` — giao diện, 3 chế độ trắc nghiệm, kho bài, trang **Thống kê**, đồng hồ học.
- `config.js` — URL và khóa publishable/anon **công khai** của dự án Supabase.
- `supabase.sql` — bảng bài học và phân quyền admin (giống V2; dùng cho cài đặt mới).
- `mau_tu_vung_nhat.csv`, `mau_tu_vung_nhat.json` — dữ liệu mẫu tải bài.

## 2. Nâng cấp **từ V2 lên V3** (khuyến nghị)

1. Sao lưu bản đang chạy và ghi nhớ nội dung `config.js` của bạn.
2. **Chỉ thay `index.html` bằng bản V3** trong repo/web Netlify hiện tại; **giữ nguyên `config.js` V2** nếu đã kết nối Supabase đúng.
3. Deploy lại Netlify / push commit lên GitHub.
4. F5 hoặc Ctrl+F5, mở tab **Thống kê**, bắt đầu luyện để có dữ liệu ngày.

**Không cần chạy lại `supabase.sql`** nếu hệ thống V2 đang hoạt động. **Không cần upload lại đề**: bài đang nằm trên Supabase cũ và vẫn giữ nguyên. Các thống kê/câu sai V2 trên **cùng tên miền + trình duyệt** vẫn còn; V3 thêm lịch sử theo ngày từ thời điểm nâng cấp, không đoán dữ liệu thời gian học trong quá khứ.

Nếu bạn đưa toàn bộ ZIP V3 lên một site mới, phải cấu hình lại `config.js` theo project của bạn; các file `config.js` trong ZIP là mẫu và **chưa điền khóa**. Thay tên miền sẽ tạo vùng lưu trình duyệt khác; hãy xuất bản sao từ site cũ nếu muốn chuyển tiến độ.

## 3. Cài đặt mới với Supabase

1. Tạo project tại https://supabase.com/dashboard.
2. Vào **SQL Editor**, chạy toàn bộ nội dung `supabase.sql`.
3. Trong **Authentication → Users**, tạo tài khoản admin email/mật khẩu và xác nhận email.
4. Sao chép `User ID` (UUID) của admin đó, vào SQL Editor chạy:

   ```sql
   insert into public.kotoba_admins (user_id)
   values ('UUID_THAT_CUA_ADMIN')
   on conflict (user_id) do nothing;
   ```

5. Lấy **Project URL** và **publishable key** (hoặc legacy anon public key) trong cài đặt API, thay vào `config.js`:

   ```js
   window.KOTOBA_CONFIG = {
     SUPABASE_URL: 'https://your-project.supabase.co',
     SUPABASE_ANON_KEY: 'sb_publishable_your_key'
   };
   ```

   **Không bao giờ điền `service_role`, secret key, mật khẩu cơ sở dữ liệu, hoặc JWT secret trong frontend.**

6. Đưa thư mục chứa cả `index.html` và `config.js` lên Netlify hoặc GitHub → Netlify. Không cần build; publish directory là thư mục này.

## 4. Thống kê V3 — cách tính

**Tab “Thống kê”** có thẻ tổng quan hôm nay, 7 ngày gần nhất, biểu đồ 14 ngày, bảng nhật ký các ngày đã học và nút **Xuất thống kê CSV**.

- **Thời gian học:** cộng trong lúc buổi trắc nghiệm đang mở, trang đang hiển thị, đồng hồ không bị tạm dừng. Tạm dừng bằng nút; hệ thống tự tạm dừng khi không có thao tác trong 5 phút. Không tính khi đã thoát quiz hoặc rời trang/tab. Thời gian đang học được lưu định kỳ (5 giây) và ngay khi chuyển tab, ẩn trang, thoát hoặc hoàn tất.
- **Số từ đã luyện/ngày:** số **từ khác nhau** mà người học đã trả lời ít nhất một câu trong ngày. Luyện lại cùng một từ (kể cả đổi chế độ) vẫn tính **1 từ/ngày**. Cùng từ được học ở ngày tiếp theo vẫn tính là 1 cho ngày đó.
- **Số từ trả lời đúng/ngày:** số từ khác nhau đã có ít nhất một câu đúng trong ngày.
- **Lượt trả lời:** mỗi câu trả lời được tính một lần; số đúng hiển thị riêng.
- **Buổi hoàn thành:** tăng 1 khi người học nhấn xem kết quả sau câu cuối, không tăng nếu thoát giữa chừng.
- **Ngày:** xác định bằng ngày/giờ cục bộ của thiết bị sử dụng website (ví dụ máy đang theo giờ Việt Nam hoặc Singapore). Khi học qua nửa đêm, thời gian được chia sang ngày tương ứng.

Thống kê được ghi ở `localStorage` của **thiết bị + trình duyệt** đang học, có trong bản sao tiến độ JSON và xuất CSV riêng. **V3 chưa đồng bộ nhật ký học cá nhân qua tài khoản Supabase hoặc giữa nhiều máy**. Bạn vẫn có thể học ẩn danh; kho bài học chia sẻ cho mọi người không bị ảnh hưởng. Nếu muốn giữ lịch sử lâu dài, hãy dùng **Kho bài học → Xuất bản sao** (và lưu bản sao an toàn), hoặc **Thống kê → Xuất thống kê CSV**.

## 5. Upload từ vựng và luyện trắc nghiệm

Admin: **Đăng nhập admin → Kho bài học → Chọn file** để đăng/sửa/ẩn/xóa bài. Người học không cần đăng nhập; nhấn **Luyện tập**, chọn bài, chọn 1 trong 3 chế độ:

1. Hiragana → Tiếng Việt
2. Hán tự → Hiragana
3. Hán tự → Tiếng Việt

Mỗi câu luôn có **1 đáp án đúng + 3 đáp án nhiễu khác nhau** lấy từ những từ trong bài đang học. Mỗi chế độ cần ít nhất 4 giá trị đáp án khác nhau. Hệ thống tự đảo thứ tự; không cần nhập A/B/C/D.

**Định dạng CSV** (UTF-8):

```csv
kanji,hira,vi
学校,がっこう,Trường học
先生,せんせい,Giáo viên
学生,がくせい,Học sinh
友達,ともだち,Bạn bè
```

**Định dạng JSON**:

```json
{
  "name": "Từ vựng N5",
  "words": [
    {"kanji":"学校", "hira":"がっこう", "vi":"Trường học"},
    {"kanji":"先生", "hira":"せんせい", "vi":"Giáo viên"},
    {"kanji":"学生", "hira":"がくせい", "vi":"Học sinh"},
    {"kanji":"友達", "hira":"ともだち", "vi":"Bạn bè"}
  ]
}
```

Ngoài ra hỗ trợ `.xlsx`, `.txt` (các cột cách nhau bằng `|`), `.tsv` và CSV. V3 dùng lại bộ đọc file V2.

## 6. Các lưu ý

- **“Chưa kết nối cloud”**: điền đúng `config.js`, kiểm tra đang deploy kèm `config.js` và đã chạy SQL nếu dùng project mới. Web vẫn có bài demo khi chưa bật cloud.
- **Không thấy bài cũ sau nâng cấp**: kiểm tra vẫn dùng cùng project Supabase, cùng site và đúng URL/config; không xóa bảng cũ.
- **Khách không thêm/sửa đề**: phân quyền kiểm tra bằng Supabase RLS, không chỉ dựa trên nút ẩn trong giao diện.
- **Không thấy thống kê V2 theo ngày**: V2 chỉ lưu tổng câu trả lời, không có dữ liệu thời gian hay từng từ/ngày; các số liệu này bắt đầu khi bạn học bằng V3.
- **Xóa dữ liệu trình duyệt hoặc dùng máy khác**: nhật ký cá nhân trên máy cũ sẽ không tự xuất hiện; cần sao lưu/khôi phục JSON (và nhập ở site cùng phiên bản).
- Khi dùng nhiều tab trên cùng một trình duyệt đồng thời, tiến độ localStorage có thể ghi đè giữa các tab; nên luyện trên một tab chính.

## 7. Kiểm thử

Đã thử bằng Chromium + mô phỏng Supabase: chạy/tạm dừng đồng hồ, lưu và đọc lại tiến độ sau khi mở phiên mới, từ không trùng, hoàn thành buổi học, xuất CSV, trang thống kê trên PC/điện thoại, 3 chế độ học, khách không được đăng/sửa, admin đăng/sửa/ẩn/xóa và khách đồng bộ đề. **Chưa kết nối kiểm thử trực tiếp với Supabase của bạn**; các thao tác cloud đã được kiểm bằng mô phỏng API/kiểm tra quyền.
