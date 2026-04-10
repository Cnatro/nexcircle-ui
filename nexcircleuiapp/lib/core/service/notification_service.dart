import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// ================= INIT =================
  static Future<void> init() async {
    print("NotificationService INIT START");

    await _requestPermission();
    await _initLocal();
    await _setupListeners();

    print("NotificationService INIT DONE");
  }

  /// ================= PERMISSION =================
  static Future<void> _requestPermission() async {
    print("Requesting permission...");

    final result = await _fcm.requestPermission();

    print("Permission result:");
    print("  alert: ${result.alert}");
    print("  badge: ${result.badge}");
    print("  sound: ${result.sound}");
    print("  status: ${result.authorizationStatus}");
  }

  /// ================= LOCAL NOTIFICATION =================
  static Future<void> _initLocal() async {
    print("Init local notification...");

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("LOCAL NOTI CLICKED");
        print("payload: ${response.payload}");

        _handleClick(response.payload);
      },
    );

    const channel = AndroidNotificationChannel(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print("Local notification channel created");
  }

  /// ================= TOKEN =================
  static Future<String?> getToken() async {
    final token = await _fcm.getToken();
    print("GET TOKEN CALLED");
    print("TOKEN = $token");
    return token;
  }

  /// ================= LISTENER =================
  static Future<void> _setupListeners() async {
    print("Setup listeners...");

    /// Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("ON MESSAGE (FOREGROUND)");

      print("RAW MESSAGE:");
      print("notification: ${message.notification}");
      print("data: ${message.data}");

      _showLocalNotification(message);
    });

    /// Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("ON MESSAGE OPENED APP");

      print("DATA:");
      print(message.data);

      _handleData(message.data);
    });

    /// Killed state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      print("INITIAL MESSAGE (KILLED)");

      print("DATA:");
      print(initialMessage.data);

      _handleData(initialMessage.data);
    } else {
      print("ℹNo initial message (app not opened from push)");
    }
  }

  /// ================= SHOW =================
  static void _showLocalNotification(RemoteMessage message) {
    print("SHOW LOCAL NOTIFICATION");

    print("title: ${message.notification?.title}");
    print("body: ${message.notification?.body}");
    print("data: ${message.data}");

    _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: message.notification?.title ?? "Notification",
      body: message.notification?.body ?? "",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// ================= CLICK LOCAL =================
  static void _handleClick(String? payload) {
    print("HANDLE CLICK LOCAL NOTI");

    if (payload == null) {
      print("payload NULL");
      return;
    }

    print("payload raw = $payload");

    final data = jsonDecode(payload);
    print("parsed data = $data");

    _handleData(data);
  }

  /// ================= HANDLE DATA =================
  static void _handleData(Map<String, dynamic> data) {
    print("HANDLE DATA CALLED");
    print("DATA = $data");

    final type = data["type"];
    print("TYPE = $type");

    if (type == "CHAT") {
      final conversationId = data["conversationId"];
      print("Open chat: $conversationId");
    }

    if (type == "FRIEND_REQUEST") {
      print("Open friend request");
    }

    if (type == "UNFRIENDED") {
      print("Bạn bị hủy kết bạn");
    }

    if (type == "BLOCKED") {
      print("Bạn bị chặn");
    }
  }
}
