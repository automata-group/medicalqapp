import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../../../data/models/notification_model.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'all'; // 'all', 'unread', 'questions', 'system'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> all) {
    switch (_activeFilter) {
      case 'unread':
        return all.where((n) => !n.isRead).toList();
      case 'questions':
        return all.where((n) => n.type == 'new_questions').toList();
      case 'system':
        return all.where((n) => n.type != 'new_questions').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 700;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isArabic ? 'الإشعارات والتنبيهات' : 'Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (ctx, prov, _) {
              final hasUnread = prov.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton.icon(
                onPressed: () async {
                  await prov.markAllAsRead();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isArabic
                            ? 'تم تعيين جميع الإشعارات كمقروءة'
                            : 'All notifications marked as read'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text(
                  isArabic ? 'قراءة الكل' : 'Mark All Read',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (ctx, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'تعذر تحميل الإشعارات' : 'Failed to load notifications',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً' : 'Please check your connection and try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: prov.loadNotifications,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allNotifications = prov.notifications;
          final unreadCount = allNotifications.where((n) => !n.isRead).length;
          final filteredList = _getFilteredNotifications(allNotifications);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 820 : double.infinity),
              child: RefreshIndicator(
                onRefresh: prov.loadNotifications,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 28 : 16,
                    vertical: isTablet ? 24 : 16,
                  ),
                  children: [
                    // iPad Executive Hero Banner
                    if (isTablet)
                      _buildTabletHeroBanner(context, isDark, isArabic, allNotifications.length, unreadCount, prov),

                    // Filter Chips Bar
                    _buildFilterChips(isDark, isArabic, allNotifications.length, unreadCount),
                    const SizedBox(height: 16),

                    // Notifications List or Empty State
                    if (filteredList.isEmpty)
                      _buildEmptyState(isDark, isArabic, prov)
                    else
                      for (int i = 0; i < filteredList.length; i++) ...[
                        _NotificationCard(
                          notification: filteredList[i],
                          isArabic: isArabic,
                          isTablet: isTablet,
                        ),
                        if (i < filteredList.length - 1)
                          const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabletHeroBanner(
    BuildContext context,
    bool isDark,
    bool isArabic,
    int totalCount,
    int unreadCount,
    NotificationProvider prov,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // Deep Slate
            Color(0xFF1E3A8A), // Royal Navy
            Color(0xFF0284C7), // Electric Sapphire Blue
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'مركز الإشعارات والتنبيهات' : 'Notifications Hub',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? 'تابع آخر تحديثات بنك الأسئلة والمحاكاة الرسمية وملاحظات المدرب الذكي'
                          : 'Stay updated with SDLE question bank additions and simulation alerts',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 16),

          // Stat Chips Row
          Row(
            children: [
              _buildStatChip(
                icon: Icons.mark_email_read_rounded,
                label: isArabic ? 'إجمالي الإشعارات' : 'Total',
                value: '$totalCount',
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.fiber_new_rounded,
                label: isArabic ? 'غير مقروءة' : 'Unread',
                value: '$unreadCount',
                isHighlighted: unreadCount > 0,
              ),
              const Spacer(),
              if (unreadCount > 0)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: prov.markAllAsRead,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.done_all_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isArabic ? 'قراءة الكل' : 'Mark all read',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? const Color(0xFFFBBF24) : Colors.white70,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFF59E0B) : Colors.white24,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark, bool isArabic, int total, int unread) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChipItem(
            id: 'all',
            label: isArabic ? 'الكل' : 'All',
            count: total,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChipItem(
            id: 'unread',
            label: isArabic ? 'غير المقروءة' : 'Unread',
            count: unread,
            isDark: isDark,
            highlightCount: unread > 0,
          ),
          const SizedBox(width: 8),
          _buildFilterChipItem(
            id: 'questions',
            label: isArabic ? 'بنك الأسئلة' : 'Questions',
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChipItem(
            id: 'system',
            label: isArabic ? 'النظام والتحديثات' : 'System',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipItem({
    required String id,
    required String label,
    int? count,
    required bool isDark,
    bool highlightCount = false,
  }) {
    final isSelected = _activeFilter == id;

    return InkWell(
      onTap: () => setState(() => _activeFilter = id),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A) : AppColors.primary)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF3B82F6) : AppColors.primary)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (highlightCount
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : Colors.grey[100])),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (highlightCount
                            ? const Color(0xFFEF4444)
                            : (isDark ? Colors.grey[400] : Colors.grey[600])),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isArabic, NotificationProvider prov) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: isDark ? const Color(0xFF64748B) : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isArabic ? 'لا توجد إشعارات حالياً' : 'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'سنقوم بإشعارك فور إضافة أسئلة جديدة أو تحديثات على خطة دراستك'
                  : 'We will notify you about new questions, simulation updates, and study goals',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: prov.loadNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isArabic ? 'تحديث الإشعارات' : 'Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                side: BorderSide(
                  color: isDark ? const Color(0xFF3B82F6) : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isArabic;
  final bool isTablet;

  const _NotificationCard({
    required this.notification,
    required this.isArabic,
    required this.isTablet,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_questions':
        return Icons.quiz_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      case 'guideline':
        return Icons.verified_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'new_questions':
        return const Color(0xFF2563EB); // Royal Sapphire
      case 'achievement':
        return const Color(0xFFD97706); // Amber Gold
      case 'streak':
        return const Color(0xFFEA580C); // Warm Orange
      case 'guideline':
        return const Color(0xFF0D9488); // Medical Teal
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  String _timeAgo(DateTime dt, bool isArabic) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return isArabic ? 'الآن' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      return isArabic ? 'منذ ${diff.inMinutes} دقيقة' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return isArabic ? 'منذ ${diff.inHours} ساعة' : '${diff.inHours}h ago';
    }
    return isArabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorForType(notification.type);

    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      onDismissed: (_) => context
          .read<NotificationProvider>()
          .deleteNotification(notification.id),
      child: GestureDetector(
        onTap: notification.isRead
            ? null
            : () => context
                .read<NotificationProvider>()
                .markAsRead(notification.id),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 18 : 16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                : (isDark
                    ? color.withValues(alpha: 0.12)
                    : const Color(0xFFF0FDF4).withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                  : color.withValues(alpha: 0.35),
              width: notification.isRead ? 1.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Type Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _iconForType(notification.type),
                    color: color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Message, and Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              isArabic ? 'جديد' : 'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFF64748B) : Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeAgo(notification.createdAt, isArabic),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => context
                              .read<NotificationProvider>()
                              .deleteNotification(notification.id),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
