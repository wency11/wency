import 'package:flutter/material.dart';

import '../models/app_notification.dart';

class NotificationService {
  List<AppNotification> build() {
    final now = DateTime.now();
    return [
      AppNotification(
        type: NotificationType.weather,
        icon: Icons.thunderstorm_rounded,
        time: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        type: NotificationType.market,
        icon: Icons.trending_up_rounded,
        time: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        type: NotificationType.planting,
        icon: Icons.calendar_month_rounded,
        time: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        type: NotificationType.pest,
        icon: Icons.pest_control_rounded,
        time: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        type: NotificationType.subsidy,
        icon: Icons.card_giftcard_rounded,
        time: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}