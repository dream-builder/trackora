import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize notification settings (call once in main.dart)
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS (Darwin) settings
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    //MAC OS
    //const MacOSInitializationSettings macInitSettings = MacOSInitializationSettings();

    // Combine settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosInitSettings,
      //macOS: macInitSettings,
    );

    // const InitializationSettings initializationSettings =
    // InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Reusable function to show a custom notification
  static Future<void> showStatusBarMessage(String title, String message) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'status_bar_channel', // channel id
      'Status Bar Notifications', // channel name
      channelDescription: 'Used to show messages in status bar',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // notification ID
      title,
      message,
      platformDetails,
    );
  }
}
