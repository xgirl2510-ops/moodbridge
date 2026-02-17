import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Top-level background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[MoodBridge] Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final notifSettings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('[MoodBridge] FCM permission: ${notifSettings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> saveFcmToken(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': Timestamp.now(),
        });
        print('[MoodBridge] FCM token saved for $userId');
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': newToken,
          'fcmTokenUpdatedAt': Timestamp.now(),
        });
      });
    } catch (e) {
      print('[MoodBridge] FCM token error (simulator?): $e');
    }
  }

  Future<void> removeFcmToken(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _fcm.deleteToken();
    } catch (e) {
      print('[MoodBridge] Remove FCM token error: $e');
    }
  }

  Future<void> scheduleCheckinReminder({
    required bool enabled,
    String time = '09:00',
  }) async {
    await _localNotifications.cancel(id: 0);

    if (!enabled) return;

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'checkin_reminder',
      'Nhắc check-in',
      channelDescription: 'Nhắc bạn check-in tâm trạng mỗi ngày',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.zonedSchedule(
      id: 0,
      title: 'MoodBridge 💙',
      body: 'Hôm nay bạn cảm thấy thế nào? Hãy check-in tâm trạng nhé!',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('[MoodBridge] Check-in reminder scheduled at $hour:${minute.toString().padLeft(2, '0')} daily');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'encouragement',
      'Tin động viên',
      channelDescription: 'Nhận thông báo khi có người gửi động viên',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: data != null ? jsonEncode(data) : null,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('[MoodBridge] Foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'MoodBridge',
        body: message.notification!.body ?? '',
        data: message.data,
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('[MoodBridge] Notification tapped: ${message.data}');
  }
}
