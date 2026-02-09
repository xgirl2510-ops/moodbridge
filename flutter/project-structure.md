# MoodBridge - Flutter Project Structure

## 📁 Folder Structure

```
moodbridge/
├── android/                    # Android native code
├── ios/                        # iOS native code
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # App widget & routing
│   │
│   ├── config/
│   │   ├── app_config.dart    # App constants
│   │   ├── theme.dart         # Theme & colors
│   │   ├── routes.dart        # Route definitions
│   │   └── firebase_options.dart  # Firebase config (generated)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── badges.dart    # Badge definitions
│   │   │   ├── templates.dart # Message templates
│   │   │   └── strings.dart   # UI strings (i18n ready)
│   │   ├── errors/
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── extensions.dart
│   │   └── services/
│   │       ├── notification_service.dart
│   │       └── analytics_service.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── checkin_model.dart
│   │   │   ├── encouragement_model.dart
│   │   │   ├── connection_model.dart
│   │   │   ├── chat_model.dart
│   │   │   ├── message_model.dart
│   │   │   └── badge_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   ├── checkin_repository.dart
│   │   │   ├── encouragement_repository.dart
│   │   │   ├── connection_repository.dart
│   │   │   └── chat_repository.dart
│   │   │
│   │   └── datasources/
│   │       ├── firebase_auth_datasource.dart
│   │       └── firestore_datasource.dart
│   │
│   ├── domain/
│   │   ├── entities/          # Clean architecture entities (optional)
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── sign_in.dart
│   │       │   ├── sign_up.dart
│   │       │   └── sign_out.dart
│   │       ├── checkin/
│   │       │   ├── create_checkin.dart
│   │       │   └── get_checkin_history.dart
│   │       ├── encouragement/
│   │       │   ├── get_sad_users.dart
│   │       │   ├── send_encouragement.dart
│   │       │   └── react_to_encouragement.dart
│   │       └── chat/
│   │           ├── get_conversations.dart
│   │           └── send_message.dart
│   │
│   ├── presentation/
│   │   ├── providers/         # Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── user_provider.dart
│   │   │   ├── checkin_provider.dart
│   │   │   ├── encouragement_provider.dart
│   │   │   └── chat_provider.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart       # Check-in screen
│   │   │   ├── happy_flow/
│   │   │   │   ├── match_list_screen.dart
│   │   │   │   └── send_encouragement_screen.dart
│   │   │   ├── sad_flow/
│   │   │   │   ├── privacy_choice_screen.dart
│   │   │   │   └── inbox_screen.dart
│   │   │   ├── stats/
│   │   │   │   └── stats_screen.dart
│   │   │   ├── chat/
│   │   │   │   ├── conversations_screen.dart
│   │   │   │   └── chat_screen.dart
│   │   │   └── profile/
│   │   │       ├── profile_screen.dart
│   │   │       └── settings_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── app_button.dart
│   │       │   ├── app_card.dart
│   │       │   ├── app_text_field.dart
│   │       │   ├── loading_widget.dart
│   │       │   └── error_widget.dart
│   │       ├── mood/
│   │       │   ├── mood_button.dart
│   │       │   └── mood_calendar.dart
│   │       ├── encouragement/
│   │       │   ├── match_card.dart
│   │       │   ├── template_tile.dart
│   │       │   └── message_card.dart
│   │       ├── chat/
│   │       │   ├── chat_bubble.dart
│   │       │   └── chat_input.dart
│   │       └── gamification/
│   │           ├── badge_widget.dart
│   │           ├── streak_card.dart
│   │           └── impact_card.dart
│   │
│   └── firebase_options.dart   # Auto-generated by FlutterFire CLI
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── onboarding_3.png
│   ├── icons/
│   │   └── app_icon.png
│   ├── animations/            # Lottie animations
│   │   ├── happy.json
│   │   ├── sad.json
│   │   └── confetti.json
│   └── fonts/
│       └── BeVietnamPro/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 📦 Dependencies (pubspec.yaml)

```yaml
name: moodbridge
description: Cầu Nối Tâm Trạng - Connect happy people with sad people

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.8.0

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^13.0.0

  # UI
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Forms & Validation
  flutter_form_builder: ^9.2.0
  form_builder_validators: ^9.1.0

  # Utils
  intl: ^0.18.1
  timeago: ^3.6.1
  uuid: ^4.2.2
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Audio (for voice notes)
  record: ^5.0.4
  audioplayers: ^5.2.1

  # Icons
  flutter_svg: ^2.0.9
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
  mockito: ^5.4.4

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/

  fonts:
    - family: BeVietnamPro
      fonts:
        - asset: assets/fonts/BeVietnamPro/BeVietnamPro-Regular.ttf
        - asset: assets/fonts/BeVietnamPro/BeVietnamPro-Medium.ttf
          weight: 500
        - asset: assets/fonts/BeVietnamPro/BeVietnamPro-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BeVietnamPro/BeVietnamPro-Bold.ttf
          weight: 700
```

---

## 🎨 Theme Configuration

```dart
// lib/config/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color happy = Color(0xFFFFD93D);
  static const Color happyDark = Color(0xFFFF9A3D);
  static const Color sad = Color(0xFF74B9FF);
  static const Color sadDark = Color(0xFFA29BFE);
  static const Color pink = Color(0xFFFF6B9D);
  static const Color green = Color(0xFF6BCB77);
  
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Gradients
  static const LinearGradient happyGradient = LinearGradient(
    colors: [happy, happyDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sadGradient = LinearGradient(
    colors: [sad, sadDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'BeVietnamPro',
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: pink,
      surface: surface,
      background: background,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        textStyle: TextStyle(
          fontFamily: 'BeVietnamPro',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
```

---

## 🚀 Main Entry Point

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ProviderScope(
      child: MoodBridgeApp(),
    ),
  );
}
```

```dart
// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class MoodBridgeApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'MoodBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
```

---

## 📱 Key Screens Preview

### Home Screen (Check-in)
```dart
// lib/presentation/screens/home/home_screen.dart

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.menu),
                  Text('🌈 MoodBridge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  NotificationBadge(),
                ],
              ),
              
              Spacer(),
              
              // Greeting
              Text('Chào buổi sáng! ☀️', style: TextStyle(fontSize: 24)),
              SizedBox(height: 8),
              Text('Hôm nay bạn cảm thấy thế nào?', style: TextStyle(color: Colors.grey)),
              
              SizedBox(height: 40),
              
              // Mood buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoodButton(
                    emoji: '😊',
                    label: 'VUI',
                    gradient: AppTheme.happyGradient,
                    onTap: () => _onMoodSelected(context, ref, 'happy'),
                  ),
                  SizedBox(width: 20),
                  MoodButton(
                    emoji: '😢',
                    label: 'BUỒN',
                    gradient: AppTheme.sadGradient,
                    onTap: () => _onMoodSelected(context, ref, 'sad'),
                  ),
                ],
              ),
              
              Spacer(),
              
              // Note input
              TextField(
                decoration: InputDecoration(
                  hintText: 'Hôm nay tôi cảm thấy...',
                ),
              ),
              
              Spacer(flex: 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 0),
    );
  }
}
```

---

## ⚡ Quick Start Commands

```bash
# Create new Flutter project
flutter create moodbridge
cd moodbridge

# Add Firebase
flutterfire configure

# Install dependencies
flutter pub get

# Generate Riverpod code
dart run build_runner build

# Run app
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```
