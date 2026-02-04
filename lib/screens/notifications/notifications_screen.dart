import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Écran des notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'document',
      'icon': Icons.description_outlined,
      'title': 'Nouveau document disponible',
      'description': 'Votre relevé annuel 2025 est disponible',
      'date': '2h',
      'read': false,
      'category': 'documents',
    },
    {
      'id': '2',
      'type': 'performance',
      'icon': Icons.trending_up,
      'title': 'Performance mensuelle',
      'description': 'Votre épargne a progressé de +1,2% ce mois-ci',
      'date': '1j',
      'read': false,
      'category': 'performance',
    },
    {
      'id': '3',
      'type': 'alert',
      'icon': Icons.warning_amber_rounded,
      'title': 'Action recommandée',
      'description': 'Pensez à mettre à jour vos bénéficiaires',
      'date': '2j',
      'read': false,
      'category': 'alerts',
    },
    {
      'id': '4',
      'type': 'success',
      'icon': Icons.check_circle_outline,
      'title': 'Versement validé',
      'description': 'Votre versement de 200€ a été validé',
      'date': '3j',
      'read': true,
      'category': 'payments',
    },
    {
      'id': '5',
      'type': 'document',
      'icon': Icons.description_outlined,
      'title': 'Attestation fiscale 2025',
      'description': 'Votre IFU 2025 est maintenant disponible',
      'date': '1 sem',
      'read': true,
      'category': 'documents',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n['read']).length;

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'document':
        return AppColors.primary;
      case 'performance':
        return AppColors.success;
      case 'alert':
        return AppColors.warning;
      case 'success':
        return AppColors.success;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadNotifications = _notifications.where((n) => !n['read']).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tout marquer comme lu'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              '$_unreadCount non lue${_unreadCount > 1 ? 's' : ''}',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          AppSpacing.verticalGapMd,

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              labelStyle: AppTypography.labelMedium,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Toutes (${_notifications.length})'),
                Tab(text: 'Non lues ($_unreadCount)'),
              ],
            ),
          ),
          AppSpacing.verticalGapMd,

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All notifications
                _buildNotificationsList(_notifications),
                // Unread notifications
                _buildNotificationsList(unreadNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            AppSpacing.verticalGapMd,
            Text(
              'Aucune notification',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: notifications.length,
      separatorBuilder: (context, index) => AppSpacing.verticalGapSm,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          id: notification['id'] as String,
          icon: notification['icon'] as IconData,
          title: notification['title'] as String,
          description: notification['description'] as String,
          date: notification['date'] as String,
          isRead: notification['read'] as bool,
          color: _getNotificationColor(notification['type'] as String),
          onTap: () {
            _markAsRead(notification['id'] as String);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification marquée comme lue'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final String date;
  final bool isRead;
  final Color color;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.isRead,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            // Left border for unread
            if (!isRead)
              Container(
                width: 4,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isRead ? AppSpacing.md : AppSpacing.sm,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    AppSpacing.horizontalGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isRead
                                        ? (isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight)
                                        : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight),
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                date,
                                style: AppTypography.caption.copyWith(
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalGapXxs,
                          Text(
                            description,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (!isRead) ...[
                            AppSpacing.verticalGapSm,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppSpacing.borderRadiusFull,
                              ),
                              child: Text(
                                'Nouveau',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
