import 'dart:async';
import 'package:flutter/material.dart';

class UserNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isBroadcast;
  bool isRead;

  UserNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    this.isBroadcast = false,
    this.isRead = false,
  });
}

class NotificationService extends ChangeNotifier {
  final List<UserNotification> _notifications = [
    UserNotification(
      title: 'System Alert',
      body: 'Welcome to JalNirnay AI Infrastructure Monitoring.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  final StreamController<List<UserNotification>> _controller = StreamController<List<UserNotification>>.broadcast();

  NotificationService() {
    _controller.add(_notifications);
  }

  Stream<List<UserNotification>> get notificationStream => _controller.stream;
  List<UserNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void sendBroadcast(String title, String body) {
    if (body.isEmpty) return;
    
    final notification = UserNotification(
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isBroadcast: true,
    );
    _notifications.insert(0, notification);
    _controller.add(_notifications);
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _controller.add(_notifications);
    notifyListeners();
  }
}
