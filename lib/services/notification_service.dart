import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'chipi_actions',
    'Acciones de Chipi',
    description: 'Avisos al guardar o marcar favoritos',
    importance: Importance.high
  );

  Future<void> init() async{
    const androidInit = AndroidInitializationSettings('@mipmap/ic_notification');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation
      <AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    await android?.requestNotificationsPermission();
  }

  Future<void> show({required String title, required String body}){
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'chipi_actions',
        'Acciones de Chipi',
        channelDescription: 'Avisos al guardar o marcar favoritos',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_notification',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
      ),
    );

    return _plugin.show(0, title, body, details);
  }
}