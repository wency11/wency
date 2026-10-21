import 'package:flutter/material.dart';

enum NotificationType { weather, market, planting, pest, subsidy }

class AppNotification {
  final NotificationType type;
  final IconData icon;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.type,
    required this.icon,
    required this.time,
    this.isRead = false,
  });

  /// Ginagamit ng provider sa markNotificationRead(id).
  String get id => type.name;
}