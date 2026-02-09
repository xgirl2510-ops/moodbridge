# MoodBridge - Cầu Nối Tâm Trạng 🌈

> *"Biến năng lượng tích cực thành hành động yêu thương"*

## 📋 Tổng Quan

**MoodBridge** là ứng dụng cho phép người dùng check-in tâm trạng hàng ngày và kết nối những người đang vui với những người đang buồn, tạo cầu nối để chia sẻ và động viên lẫn nhau.

### Ý Tưởng Gốc (by Bà Chủ Tracy)
- User daily check-in trạng thái: VUI hoặc BUỒN
- Nếu ai check-in VUI → recommend 5 users đang BUỒN
- User vui có thể gửi lời chia sẻ, động viên
- **Mục đích:** Khuyến khích con người quan tâm, san sẻ nhau hơn

---

## 🎯 Core Features (MVP)

### 1. Daily Mood Check-in
- Mỗi ngày 1 lần check-in
- 2 trạng thái cơ bản: 😊 Vui | 😢 Buồn
- Optional: ghi chú ngắn về tâm trạng

### 2. Mood Matching
- Người VUI nhận danh sách 5 người BUỒN (random, ẩn danh)
- Hiển thị: Avatar (blur hoặc emoji) + tên ẩn danh + thời gian check-in

### 3. Send Encouragement
- Gửi tin nhắn động viên (text, sticker, voice note)
- Templates có sẵn: "Mình ở đây nếu bạn cần nói chuyện", "Ngày mai sẽ tốt hơn!"...
- Giới hạn: 1 tin/người để tránh spam

### 4. Receive & React
- Người BUỒN nhận tin ẩn danh
- Có thể react: ❤️ Cảm ơn | 😊 Đã vui hơn | 💬 Muốn nói chuyện

### 5. Privacy Controls
- Người BUỒN có thể chọn: "Nhận tin động viên" hoặc "Chỉ muốn ở một mình"
- **Tùy chọn danh tính:** Ẩn danh (mặc định) HOẶC Công khai tên
- Mọi thứ ẩn danh cho đến khi cả 2 đồng ý kết nối

---

## 👥 User Stories

### Epic 1: Onboarding
```
US-001: Đăng ký tài khoản
- Là người dùng mới
- Tôi muốn đăng ký bằng email/số điện thoại
- Để bắt đầu sử dụng app

US-002: Tạo profile
- Là người dùng mới
- Tôi muốn tạo tên hiển thị và chọn avatar
- Để có danh tính trong app (vẫn ẩn danh với người khác)

US-003: Onboarding tutorial
- Là người dùng mới
- Tôi muốn xem hướng dẫn ngắn về cách app hoạt động
- Để hiểu rõ cách sử dụng
```

### Epic 2: Daily Check-in
```
US-010: Check-in tâm trạng
- Là người dùng
- Tôi muốn check-in tâm trạng mỗi ngày (Vui/Buồn)
- Để chia sẻ trạng thái của mình

US-011: Thêm ghi chú
- Là người dùng
- Tôi muốn thêm ghi chú ngắn khi check-in
- Để ghi lại lý do tâm trạng hôm nay

US-012: Xem lịch sử check-in
- Là người dùng
- Tôi muốn xem lịch sử tâm trạng của mình
- Để theo dõi mood patterns
```

### Epic 3: Gửi Động Viên (Người Vui)
```
US-020: Xem danh sách người cần động viên
- Là người check-in VUI
- Tôi muốn xem 5 người đang BUỒN
- Để chọn ai tôi muốn gửi lời động viên

US-021: Gửi tin nhắn động viên
- Là người check-in VUI
- Tôi muốn gửi tin nhắn/sticker động viên
- Để chia sẻ năng lượng tích cực

US-022: Sử dụng template
- Là người check-in VUI
- Tôi muốn chọn template tin nhắn có sẵn
- Để gửi nhanh khi không biết nói gì

US-023: Gửi voice note
- Là người check-in VUI
- Tôi muốn gửi tin nhắn thoại
- Để động viên chân thành hơn
```

### Epic 4: Nhận Động Viên (Người Buồn)
```
US-030: Chọn nhận/không nhận tin
- Là người check-in BUỒN
- Tôi muốn chọn có nhận tin động viên hay không
- Để kiểm soát quyền riêng tư

US-031: Xem tin động viên
- Là người check-in BUỒN
- Tôi muốn xem các tin động viên nhận được
- Để cảm thấy được quan tâm

US-032: React tin nhắn
- Là người nhận tin
- Tôi muốn react (❤️/😊/💬)
- Để cảm ơn người gửi

US-033: Yêu cầu kết nối
- Là người nhận tin
- Tôi muốn gửi yêu cầu kết nối với người động viên
- Để có thể nói chuyện thêm
```

### Epic 5: Kết Nối & Chat
```
US-040: Chấp nhận kết nối
- Là người gửi tin động viên
- Tôi muốn chấp nhận yêu cầu kết nối
- Để tiếp tục trò chuyện

US-041: Chat 1-1
- Là 2 người đã kết nối
- Chúng tôi muốn chat riêng
- Để nói chuyện sâu hơn
```

### Epic 6: Gamification
```
US-050: Xem streak động viên
- Là người dùng
- Tôi muốn xem streak ngày liên tiếp gửi động viên
- Để có động lực tiếp tục

US-051: Nhận badge
- Là người dùng
- Tôi muốn nhận badge khi đạt milestone
- Để có thành tựu

US-052: Xem impact
- Là người dùng
- Tôi muốn xem số người tôi đã giúp vui hơn
- Để thấy ý nghĩa của việc mình làm
```

---

## 🏗️ Tech Stack (Chính Thức)

### Frontend
- **Flutter** - Cross-platform mobile (iOS + Android)
- **Dart** - Programming language
- **Riverpod** - State management

### Backend (BaaS)
- **Firebase** - Full backend solution
- **Firebase Auth** - Authentication (email, phone, Google)
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage (avatars, voice notes)
- **Firebase Cloud Messaging** - Push notifications
- **Cloud Functions** - Server-side logic

### Additional
- **Firebase Analytics** - User behavior tracking
- **Firebase Crashlytics** - Error tracking

---

## 🔒 Privacy & Safety

### Nguyên tắc
1. **Ẩn danh mặc định** - Không ai biết ai cho đến khi cả 2 đồng ý
2. **Consent-based** - Người buồn chọn có nhận tin hay không
3. **Giới hạn spam** - Mỗi người chỉ gửi được 1 tin/ngày cho mỗi người
4. **Report & Block** - Có thể báo cáo tin nhắn không phù hợp

### Moderation
- AI filter cho tin nhắn tiêu cực/xúc phạm
- Review thủ công cho reports
- Ban user vi phạm

---

## 💰 Monetization (Future)

### Freemium Model
**Free:**
- 1 check-in/ngày
- Gửi 3 tin động viên/ngày
- Basic stickers

**Premium ($2.99/tháng):**
- Unlimited tin động viên
- Premium stickers & animations
- Xem chi tiết mood history
- Priority matching

### Other Revenue
- **Charity partnerships** - Donate khi đạt milestone cộng đồng
- **Corporate wellness** - B2B cho công ty

---

## 🎨 Wireframes

*(Xem file riêng: wireframes.md)*

---

## 📊 Competitor Analysis

### 1. Daylio
- ✅ Mood tracking tốt
- ❌ Không có tính năng social

### 2. 7 Cups
- ✅ Kết nối với listeners
- ❌ Phức tạp, focus therapy

### 3. Happify
- ✅ Gamification hay
- ❌ Không peer-to-peer

### 4. Woebot
- ✅ AI chatbot hỗ trợ
- ❌ Không human connection

### MoodBridge khác biệt:
- **Human-to-human connection** (không phải AI)
- **Đơn giản**: chỉ Vui/Buồn
- **Action-oriented**: Người vui chủ động giúp người buồn
- **Gamification nhẹ nhàng**

---

## 📅 Roadmap

### Phase 1: MVP (4-6 tuần)
- [ ] User auth (email/phone)
- [ ] Daily check-in
- [ ] Basic matching (5 người buồn)
- [ ] Send text message
- [ ] Receive & react

### Phase 2: Enhancement (4 tuần)
- [ ] Push notifications
- [ ] Stickers
- [ ] Chat 1-1
- [ ] Mood history

### Phase 3: Gamification (4 tuần)
- [ ] Streaks
- [ ] Badges
- [ ] Impact dashboard

### Phase 4: Growth (Ongoing)
- [ ] Premium features
- [ ] Corporate partnerships
- [ ] Multi-language

---

## 📝 Notes

- Ý tưởng bởi: **Bà Chủ Tracy (Xuân Trần)**
- Document bởi: **Heo 🐷**
- Ngày tạo: 2026-02-08

---

*"Một tin nhắn nhỏ có thể thay đổi cả ngày của ai đó"* 💕
