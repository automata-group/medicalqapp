import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import '../login_screen.dart';
import '../forgot_password_screen.dart';
import '../specialty_selection_screen.dart';
import '../../providers/sync_provider.dart';
import '../../../core/utils/toast_utils.dart';
import 'edit_profile_screen.dart';
import '../subscription/pricing_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().user;
    final dashboard = context.watch<DashboardProvider>().overview;

    final totalSolved = dashboard?.totalSolved ?? 0;
    final accuracy = dashboard?.accuracy ?? 0;
    final streak = dashboard?.currentStreak ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Collapsible Header with gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF0F5DB5)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar with optional premium star
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          if (user?.isPremium == true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFC107),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'Doctor',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      if (user?.isPremium == true)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '⭐ PRO',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === MASTERY STATS ===
                  _buildMasteryStats(totalSolved, accuracy, streak),
                  const SizedBox(height: 20),

                  // === PRO SUBSCRIPTION BANNER ===
                  _buildSubscriptionCard(context, user),
                  const SizedBox(height: 20),

                  // === INVITE FRIENDS ===
                  if (user?.referralCode != null)
                    _buildInviteFriendsCard(context, user!.referralCode!),
                  const SizedBox(height: 20),

                  // === ACCOUNT SECTION ===
                  _buildSection(
                    title: l10n.account,
                    children: [
                      _buildListTile(
                        icon: Icons.workspace_premium_rounded,
                        iconColor: const Color(0xFFFFB800),
                        title: 'باقات الاشتراك والترقية (PRO)',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (user?.isPremium == true
                                    ? Colors.green
                                    : const Color(0xFFFFB800))
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user?.isPremium == true ? 'نشط PRO' : 'ترقية',
                            style: TextStyle(
                              color: user?.isPremium == true
                                  ? Colors.green
                                  : const Color(0xFFD97706),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PricingScreen(),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.person_outline,
                        iconColor: AppColors.primary,
                        title: l10n.editProfile,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.lock_outline,
                        iconColor: AppColors.primary,
                        title: l10n.changePassword,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen()),
                        ),
                      ),

                      _buildListTile(
                        icon: Icons.school_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        title: 'My Specialties',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpecialtySelectionScreen(),
                            ),
                          );
                        },
                      ),
                      // ------------------------------------
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === APP SETTINGS ===
                  _buildSection(
                    title: l10n.appSettings,
                    children: [
                      Consumer<ReminderProvider>(
                        builder: (ctx, reminder, _) => Column(
                          children: [
                            _buildListTile(
                              icon: Icons.notifications_outlined,
                              iconColor: const Color(0xFFFF9500),
                              title: l10n.notifications,
                              trailing: Switch(
                                value: reminder.enabled,
                                onChanged: (val) =>
                                    reminder.setEnabled(val, ctx),
                                activeThumbColor: AppColors.primary,
                              ),
                            ),
                            if (reminder.enabled)
                              _buildListTile(
                                icon: Icons.access_time_rounded,
                                iconColor: AppColors.primary,
                                title: 'Daily Reminder Time',
                                trailing: Text(
                                  reminder.formattedTime,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary),
                                ),
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: ctx,
                                    initialTime: TimeOfDay(
                                        hour: reminder.hour,
                                        minute: reminder.minute),
                                  );
                                  if (picked != null) {
                                    reminder.setTime(
                                        picked.hour, picked.minute);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === OFFLINE SYNC HUB ===
                  _buildOfflineSyncHub(context),
                  const SizedBox(height: 16),

                  // === LOGOUT ===
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    elevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.logout,
                            color: Colors.red, size: 20),
                      ),
                      title: Text(
                        l10n.logout,
                        style: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                      onTap: () => _handleLogout(context),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, dynamic user) {
    final isPremium = user?.isPremium == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPremium ? Colors.black : const Color(0xFF312E81))
                .withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFFB800),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isPremium ? 'عضوية PRO مميزة' : 'باقات الاشتراك المميزة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.green.withValues(alpha: 0.2)
                      : const Color(0xFFFFB800).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isPremium
                        ? Colors.green
                        : const Color(0xFFFFB800),
                    width: 1,
                  ),
                ),
                child: Text(
                  isPremium ? 'PRO نشط' : 'SDLE PRO',
                  style: TextStyle(
                    color: isPremium
                        ? Colors.greenAccent
                        : const Color(0xFFFFB800),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isPremium
                ? 'لديك وصول كامل لجميع بنوك الأسئلة، امتحانات المحاكاة، ومزايا الذكاء الاصطناعي.'
                : 'افتح جميع التخصصات المغلقة، امتحانات الـ Mock غير المحدودة، وتحليلات الذكاء الاصطناعي.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PricingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFFFB800),
                foregroundColor:
                    isPremium ? Colors.white : const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isPremium ? 'إدارة تفاصيل الاشتراك' : 'استعراض الخطط والاشتراك الآن ✨',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineSyncHub(BuildContext context) {
    final syncProv = context.watch<SyncProvider>();
    final isPending = syncProv.pendingAttempts > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPending
              ? [const Color(0xFF1E3A5F), const Color(0xFF2563EB)]
              : [const Color(0xFF374151), const Color(0xFF4B5563)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPending ? const Color(0xFF2563EB) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Offline Mode',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const Spacer(),
              if (syncProv.isDownloaded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Ready ✓',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isPending
                      ? '${syncProv.pendingAttempts} answers pending sync'
                      : 'All answers synced ✓',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: syncProv.status == SyncStatus.uploading
                    ? null
                    : () async {
                        await syncProv.syncPendingAttempts();
                        if (context.mounted) {
                          if (syncProv.status == SyncStatus.success) {
                            ToastUtils.showSuccess(context, syncProv.message);
                          } else {
                            ToastUtils.showError(context, syncProv.message);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2563EB),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                icon: syncProv.status == SyncStatus.uploading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF2563EB)),
                      )
                    : const Icon(Icons.sync_rounded, size: 16),
                label: const Text('Sync Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryStats(int totalSolved, int accuracy, int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Mastery Progress',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  bgColor: const Color(0xFFEFF6FF),
                  label: 'Questions',
                  value: totalSolved.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.insights,
                  iconColor: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                  label: 'Accuracy',
                  value: '$accuracy%',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  label: 'Streak',
                  value: '${streak}d',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsCard(BuildContext context, String referralCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Invite Friends & Earn Rewards!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Share your referral code with friends. When they register, you both get rewards!',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referralCode,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ToastUtils.showSuccess(context, 'Referral Code Copied!');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.copy,
                        size: 20, color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: iconColor),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5),
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }


  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
