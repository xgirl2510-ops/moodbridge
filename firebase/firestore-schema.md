# MoodBridge - Firestore Schema

## 📊 Database Structure (NoSQL)

Firestore uses collections and documents. Here's the data model:

```
firestore/
├── users/
│   └── {userId}/
│       ├── profile (subcollection)
│       └── stats (subcollection)
├── checkins/
│   └── {checkinId}
├── encouragements/
│   └── {encouragementId}
├── connections/
│   └── {connectionId}
├── chats/
│   └── {chatId}/
│       └── messages (subcollection)
├── templates/
│   └── {templateId}
└── reports/
    └── {reportId}
```

---

## 👤 Users Collection

**Path:** `/users/{userId}`

```javascript
{
  // Basic info
  "uid": "firebase-auth-uid",
  "email": "user@example.com",
  "phone": "+84123456789",
  "displayName": "Nguyen Van A",
  "avatarUrl": "https://storage.firebase.com/...",
  "anonymousId": "User#4521",  // Auto-generated
  
  // Privacy settings
  "isPublic": false,  // true = show real name, false = anonymous
  "receiveEncouragements": true,
  "showMoodNote": false,
  
  // Notification settings
  "pushEnabled": true,
  "checkinReminderEnabled": true,
  "checkinReminderTime": "09:00",
  
  // FCM Token
  "fcmTokens": [
    {
      "token": "fcm-token-string",
      "platform": "android",  // android | ios | web
      "updatedAt": Timestamp
    }
  ],
  
  // Status
  "isActive": true,
  "isBanned": false,
  
  // Timestamps
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  "lastActiveAt": Timestamp
}
```

### User Stats (Subcollection)

**Path:** `/users/{userId}/stats/current`

```javascript
{
  "totalCheckins": 45,
  "happyDays": 30,
  "sadDays": 15,
  
  "totalSent": 28,        // Encouragements sent
  "totalReceived": 12,    // Encouragements received
  "peopleHelped": 18,     // People who reacted 'feeling_better'
  
  "currentStreak": 5,     // Days in a row sending
  "longestStreak": 12,
  "lastSendDate": "2026-02-08",
  
  // Badges earned (array of badge codes)
  "badges": ["first_send", "5_day_streak", "10_helped"],
  
  "updatedAt": Timestamp
}
```

---

## 📅 Checkins Collection

**Path:** `/checkins/{checkinId}`

```javascript
{
  "id": "auto-generated-id",
  "userId": "user-uid",
  
  "mood": "happy",  // "happy" | "sad"
  "note": "Hôm nay được tăng lương!",  // Optional, max 200 chars
  
  // For sad users
  "wantsEncouragement": true,
  "matchedCount": 3,  // How many happy users saw this
  
  // Date info (for querying)
  "date": "2026-02-08",  // YYYY-MM-DD string for easy querying
  "createdAt": Timestamp,
  
  // Denormalized user info (for display without extra reads)
  "userAnonymousId": "User#4521",
  "userDisplayName": "Nguyen Van A",  // Only if isPublic
  "userAvatarUrl": "..."
}
```

**Indexes needed:**
- `mood` + `wantsEncouragement` + `createdAt` (for matching)
- `userId` + `date` (for daily check)
- `userId` + `createdAt` (for history)

---

## 💌 Encouragements Collection

**Path:** `/encouragements/{encouragementId}`

```javascript
{
  "id": "auto-generated-id",
  
  "senderId": "sender-uid",
  "receiverId": "receiver-uid",
  
  // Link to checkins
  "senderCheckinId": "checkin-id",
  "receiverCheckinId": "checkin-id",
  
  // Message content
  "messageType": "text",  // "text" | "template" | "voice" | "sticker"
  "content": "Ngày mai sẽ tốt hơn! 💪",
  "templateId": null,  // If using template
  "mediaUrl": null,    // For voice/sticker
  
  // Status
  "isRead": false,
  "readAt": null,
  
  // Reaction from receiver
  "reaction": null,  // null | "thanks" | "feeling_better" | "want_to_chat"
  "reactionAt": null,
  
  // Timestamps
  "createdAt": Timestamp,
  
  // Denormalized sender info
  "senderAnonymousId": "User#1234",
  "senderDisplayName": null,  // Only if public
  "senderAvatarUrl": "..."
}
```

**Indexes needed:**
- `receiverId` + `createdAt` (inbox)
- `senderId` + `createdAt` (sent history)
- `senderId` + `receiverId` + `date` (prevent spam)

---

## 🤝 Connections Collection

**Path:** `/connections/{connectionId}`

```javascript
{
  "id": "auto-generated-id",
  
  "requesterId": "user-uid",
  "receiverId": "user-uid",
  
  // Array of both user IDs for easy querying
  "participants": ["user1-uid", "user2-uid"],
  
  // Origin
  "encouragementId": "encouragement-id",
  
  "status": "pending",  // "pending" | "accepted" | "rejected" | "blocked"
  
  "createdAt": Timestamp,
  "updatedAt": Timestamp,
  
  // Denormalized info
  "requesterAnonymousId": "User#1234",
  "receiverAnonymousId": "User#5678"
}
```

---

## 💬 Chats Collection

**Path:** `/chats/{chatId}`

```javascript
{
  "id": "auto-generated-id",
  "connectionId": "connection-id",
  
  "participants": ["user1-uid", "user2-uid"],
  
  // Last message preview
  "lastMessage": {
    "content": "Cảm ơn bạn nhiều!",
    "senderId": "user1-uid",
    "createdAt": Timestamp
  },
  
  // Unread counts per user
  "unreadCount": {
    "user1-uid": 0,
    "user2-uid": 2
  },
  
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Messages Subcollection

**Path:** `/chats/{chatId}/messages/{messageId}`

```javascript
{
  "id": "auto-generated-id",
  "senderId": "user-uid",
  
  "messageType": "text",  // "text" | "voice" | "sticker" | "image"
  "content": "Cảm ơn bạn đã lắng nghe!",
  "mediaUrl": null,
  
  "isRead": false,
  "readAt": null,
  
  "createdAt": Timestamp
}
```

---

## 📝 Templates Collection

**Path:** `/templates/{templateId}`

```javascript
{
  "id": "auto-generated-id",
  "emoji": "💪",
  "content": "Bạn làm được! Mình tin bạn!",
  "category": "motivation",  // "motivation" | "hope" | "comfort" | "support"
  
  "usageCount": 1250,
  "isActive": true,
  
  "createdAt": Timestamp
}
```

**Seed data:**
```javascript
[
  { emoji: "💪", content: "Bạn làm được! Mình tin bạn!", category: "motivation" },
  { emoji: "🌈", content: "Ngày mai sẽ tốt hơn! Hãy kiên nhẫn với bản thân nhé.", category: "hope" },
  { emoji: "🤗", content: "Mình ở đây nếu bạn cần nói chuyện. Bạn không cô đơn đâu.", category: "support" },
  { emoji: "☀️", content: "Sau cơn mưa trời lại sáng. Gửi bạn nhiều năng lượng tích cực!", category: "hope" },
  { emoji: "🌸", content: "Hãy cho phép bản thân được buồn, rồi mọi thứ sẽ ổn thôi.", category: "comfort" },
  { emoji: "🎯", content: "Mỗi ngày là một cơ hội mới. Bạn đang làm tốt lắm rồi!", category: "motivation" },
  { emoji: "💕", content: "Gửi bạn một cái ôm ấm áp. Take your time.", category: "comfort" },
  { emoji: "🌟", content: "Bạn mạnh mẽ hơn bạn nghĩ đó!", category: "motivation" }
]
```

---

## 🏆 Badges (App Constants)

Badges are defined in app code, not Firestore:

```dart
const badges = [
  Badge(
    code: 'first_send',
    name: 'Thiên Thần Nhỏ',
    description: 'Gửi lời động viên đầu tiên',
    icon: '🌟',
    requirementType: 'sends',
    requirementValue: 1,
  ),
  Badge(
    code: '5_day_streak',
    name: 'Thiên Thần Kiên Nhẫn',
    description: '5 ngày liên tiếp gửi động viên',
    icon: '😇',
    requirementType: 'streak',
    requirementValue: 5,
  ),
  Badge(
    code: '10_helped',
    name: 'Thiên Thần Lan Tỏa',
    description: 'Giúp 10 người vui hơn',
    icon: '👼',
    requirementType: 'helped',
    requirementValue: 10,
  ),
  Badge(
    code: '30_day_streak',
    name: 'Thiên Thần Thủ Hộ',
    description: '30 ngày liên tiếp',
    icon: '🕊️',
    requirementType: 'streak',
    requirementValue: 30,
  ),
  Badge(
    code: '50_helped',
    name: 'Tổng Thiên Thần',
    description: 'Giúp 50 người vui hơn',
    icon: '👑',
    requirementType: 'helped',
    requirementValue: 50,
  ),
];
```

---

## 🚨 Reports Collection

**Path:** `/reports/{reportId}`

```javascript
{
  "id": "auto-generated-id",
  
  "reporterId": "user-uid",
  "reportedUserId": "user-uid",
  "reportedMessageId": "encouragement-id",  // Optional
  
  "reason": "harassment",  // "spam" | "harassment" | "inappropriate" | "other"
  "details": "Người này gửi tin nhắn xúc phạm...",
  
  "status": "pending",  // "pending" | "reviewed" | "resolved" | "dismissed"
  "reviewedBy": null,
  "reviewedAt": null,
  "resolution": null,
  
  "createdAt": Timestamp
}
```

---

## 🔄 Cloud Functions Triggers

These Cloud Functions should be created:

### 1. onUserCreate
- Generate `anonymousId`
- Initialize user stats

### 2. onCheckinCreate
- Update user stats (totalCheckins, happyDays/sadDays)

### 3. onEncouragementCreate
- Update sender stats (totalSent)
- Update receiver stats (totalReceived)
- Update sender streak
- Check and award badges
- Send push notification to receiver

### 4. onReactionUpdate
- If `feeling_better`: update sender's `peopleHelped`
- Check and award badges

### 5. onConnectionAccepted
- Create chat document

### 6. Daily Scheduled Function
- Reset streaks for users who didn't send yesterday

---

## 📱 Offline Support

Firestore has built-in offline support. Enable persistence:

```dart
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 🔍 Compound Indexes Required

Create these in Firebase Console or `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "checkins",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "mood", "order": "ASCENDING" },
        { "fieldPath": "wantsEncouragement", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "checkins",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "encouragements",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "receiverId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "encouragements",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "senderId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```
