import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/document_model.dart';

class NotificationRepository {
  final ApiClient _api;

  NotificationRepository(this._api);

  Future<NotificationListResult> getNotifications() async {
    final data = await _api.get(ApiEndpoints.notificationsList);
    final list = data['notifications'] as List? ?? [];
    final notifications = list.map((n) => _mapToNotificationModel(n)).toList();
    return NotificationListResult(
      notifications: notifications,
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Future<void> markAsRead(String id) async {
    await _api.post(ApiEndpoints.notificationMarkRead(id));
  }

  Future<void> markAllAsRead() async {
    await _api.post(ApiEndpoints.notificationsMarkAllRead);
  }

  NotificationModel _mapToNotificationModel(Map<String, dynamic> n) {
    return NotificationModel(
      id: n['id'] ?? '',
      title: n['title'] ?? '',
      message: n['message'] ?? '',
      type: _mapNotificationType(n['type']),
      date: DateTime.tryParse(n['date'] ?? '') ?? DateTime.now(),
      isRead: n['isRead'] ?? false,
      priority: _mapPriority(n['priority']),
      actionUrl: n['actionUrl'],
    );
  }

  NotificationType _mapNotificationType(String? type) {
    switch (type) {
      case 'document':
        return NotificationType.document;
      case 'versement':
        return NotificationType.payment;
      case 'performance':
        return NotificationType.performance;
      case 'alerte':
        return NotificationType.alert;
      case 'rappel':
        return NotificationType.reminder;
      case 'info':
        return NotificationType.info;
      default:
        return NotificationType.info;
    }
  }

  NotificationPriority _mapPriority(int? priority) {
    switch (priority) {
      case 1:
        return NotificationPriority.urgent;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.normal;
      case 4:
        return NotificationPriority.low;
      default:
        return NotificationPriority.normal;
    }
  }
}

class NotificationListResult {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationListResult({
    required this.notifications,
    required this.unreadCount,
  });
}
