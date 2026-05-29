# 🏆 Unlock It — تطبيق تحديات الفرق

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**تطبيق موبايل للألعاب الجماعية — مستوحى من مسلسل اللعبة**

[📸 Screenshots](#-screenshots) • [✨ Features](#-features) • [🚀 Getting Started](#-getting-started) • [🗄️ Database Structure](#️-database-structure)

</div>

---

## 📖 عن المشروع

**Unlock It** هو تطبيق Flutter لتنظيم ألعاب التحديات الجماعية. الأدمن بيضيف تحديات وكلمات سر، والفرق بتنفذ التحديات على أرض الواقع وبتدخل كلمة السر عشان تتقدم للتحدي الجاي — زي Escape Room بالضبط! 🔐

---

## ✨ Features

### 👥 للفرق
- ✅ تسجيل دخول بسيط باسم الفريق بس
- ✅ عرض التحدي الحالي مع الوصف الكامل
- ✅ إدخال كلمة السر والانتقال للتحدي الجاي
- ✅ Progress bar بيوضح تقدم الفريق
- ✅ شاشة فوز مع أنيميشن لما الفريق يخلص

### 🛡️ للأدمن
- ✅ لوحة تحكم كاملة بـ 3 تبويبات
- ✅ متابعة تقدم كل الفرق **Realtime**
- ✅ إضافة وحذف التحديات بسهولة
- ✅ **Leaderboard** لترتيب الفرق حسب الإنجاز
- ✅ **In-App Notifications** لما أي فريق يخلص كل التحديات
- ✅ باسوورد سرية للأدمن منفصلة عن الفرق

---

## 📸 Screenshots

| Splash | Team Login | Challenge | Admin Dashboard | Winner |
|--------|-----------|-----------|-----------------|--------|
| ![](screenshots/splash.png) | ![](screenshots/login.png) | ![](screenshots/challenge.png) | ![](screenshots/admin.png) | ![](screenshots/winner.png) |

---

## 🚀 Getting Started

### المتطلبات

- [Flutter](https://flutter.dev/docs/get-started/install) >= 3.0.0
- [Firebase Account](https://console.firebase.google.com)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)

### خطوات التثبيت

**1. Clone المشروع**
```bash
git clone https://github.com/your-username/unlock-it.git
cd unlock-it
```

**2. إنشاء Firebase Project**
```bash
# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# ربط المشروع
flutterfire configure
```

**3. تفعيل Firestore**
- روح على [Firebase Console](https://console.firebase.google.com)
- افتح مشروعك → **Firestore Database** → **Create database**
- اختار **Start in test mode**

**4. تثبيت الـ Packages**
```bash
flutter pub get
```

**5. تشغيل الآب**
```bash
flutter run
```

---

## 🗄️ Database Structure

```
Firestore
│
├── challenges/              # التحديات
│   └── {challengeId}/
│       ├── title: String
│       ├── description: String
│       ├── password: String
│       ├── order: Number
│       └── createdAt: Timestamp
│
├── teams/                   # الفرق
│   └── {teamId}/
│       ├── name: String
│       ├── currentChallengeIndex: Number
│       ├── done: Boolean
│       ├── startedAt: Timestamp
│       └── completedAt: Timestamp?
│
└── notifications/           # إشعارات الأدمن
    └── {notifId}/
        ├── title: String
        ├── body: String
        ├── teamName: String
        ├── read: Boolean
        └── createdAt: Timestamp
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── theme/
│   └── app_theme.dart        # Dark theme + colors
├── services/
│   └── challenge_service.dart # كل عمليات Firestore
└── screens/
    ├── splash_screen.dart
    ├── team_login_screen.dart
    ├── admin_login_screen.dart
    ├── admin_dashboard_screen.dart
    ├── challenge_screen.dart
    └── winner_screen.dart
```

---

## 📦 Dependencies

```yaml
dependencies:
  firebase_core: ^2.27.0
  cloud_firestore: ^4.15.0
```

---

## ⚙️ Configuration

### تغيير باسوورد الأدمن

في ملف `admin_login_screen.dart`:
```dart
static const String _adminPassword = 'YOUR_PASSWORD_HERE';
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /challenges/{id} {
      allow read: if true;
      allow write: if false; // الأدمن بس من الآب
    }
    match /teams/{id} {
      allow read, write: if true;
    }
    match /notifications/{id} {
      allow read, write: if true;
    }
  }
}
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

---

## 📄 License

This project is licensed under the MIT License.

---

<div align="center">
Made with ❤️ using Flutter & Firebase
</div>