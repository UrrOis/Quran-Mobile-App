import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'database_helper.dart';
import 'package:permission_handler/permission_handler.dart';

// Mengatur notifikasi untuk pengingat waktu sholat
class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Inisialisasi notifikasi
  Future<void> initNotifications() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Tambahkan request permission notifikasi
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      final iosInfo =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();
      await iosInfo?.requestPermissions(alert: true, badge: true, sound: true);
    }
    _initialized = true;
  }

  // Jadwalkan notifikasi waktu sholat
  Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime dateTime,
  ) async {
    await initNotifications();
    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Jadwal Sholat',
      channelDescription: 'Notifikasi pengingat waktu sholat',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final notificationDetails = NotificationDetails(android: androidDetails);
    // Penjadwalan dengan timezone
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerName.hashCode, // unique id
      'Waktu Sholat $prayerName',
      'Sudah masuk waktu sholat $prayerName',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // agar berulang setiap hari
    );
  }

  Future<void> scheduleAllPrayerNotifications(int userId) async {
    await initNotifications();
    final prayerTimes = await DatabaseHelper.instance.getAllPrayerTimes(userId);
    final now = DateTime.now();
    for (final entry in prayerTimes.entries) {
      final name = entry.key;
      final timeStr = entry.value;
      final timeParts = timeStr.split(":");
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduled.isBefore(now)) {
          scheduled = scheduled.add(Duration(days: 1));
        }
        await schedulePrayerNotification(name, scheduled);
      }
    }
  }
}
