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
import '../../providers/sync_provider.dart';
import '../../../core/utils/toast_utils.dart';
import 'edit_profile_screen.dart';
import '../subscription/pricing_screen.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

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
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === MASTERY STATS ===
                      _buildMasteryStats(context, totalSolved, accuracy, streak, isTablet: isTablet),
                      const SizedBox(height: 20),

                      // === PRO SUBSCRIPTION & INVITE BANNERS ===
                      if (isTablet && user?.referralCode != null)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 11,
                                child: _buildSubscriptionCard(context, user, isTablet: true),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 10,
                                child: _buildInviteFriendsCard(context, user!.referralCode!, isTablet: true),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _buildSubscriptionCard(context, user, isTablet: isTablet),
                        if (user?.referralCode != null) ...[
                          const SizedBox(height: 16),
                          _buildInviteFriendsCard(context, user!.referralCode!, isTablet: isTablet),
                        ],
                      ],
                      const SizedBox(height: 20),

                      // === ACCOUNT SECTION ===
                      _buildSection(
                    title: l10n.account,
                    children: [
                      _buildListTile(
                        icon: Icons.workspace_premium_rounded,
                        iconColor: const Color(0xFFFFB800),
                        title: l10n.subscriptionPlansTitle,
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
                            user?.isPremium == true
                                ? l10n.activePro
                                : l10n.upgrade,
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
                                title: l10n.dailyReminderTime,
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
                      Consumer<LocaleProvider>(
                        builder: (ctx, localeProv, _) => _buildListTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          title: l10n.language,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localeProv.currentLanguageName,
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          onTap: () => _showLanguageDialog(context, localeProv),
                        ),
                      ),
                      Consumer<ThemeProvider>(
                        builder: (ctx, themeProv, _) => _buildListTile(
                          icon: themeProv.themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : (themeProv.themeMode == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded),
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.themeMode,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              themeProv.themeMode == ThemeMode.dark
                                  ? l10n.themeDark
                                  : (themeProv.themeMode == ThemeMode.light
                                      ? l10n.themeLight
                                      : l10n.themeSystem),
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          onTap: () => _showThemeDialog(context, themeProv),
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
                    color: Theme.of(context).cardColor,
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
        ),
      ),
    ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, dynamic user, {bool isTablet = false}) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = user?.isPremium == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 18 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
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
        mainAxisAlignment: isTablet ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
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
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isPremium
                                ? l10n.subscriptionCardActiveTitle
                                : l10n.subscriptionCardTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 15 : 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? Colors.green.withValues(alpha: 0.2)
                          : const Color(0xFFFFB800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPremium ? Colors.green : const Color(0xFFFFB800),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isPremium
                          ? l10n.subscriptionCardActiveBadge
                          : l10n.subscriptionCardBadge,
                      style: TextStyle(
                        color: isPremium ? Colors.greenAccent : const Color(0xFFFFB800),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isPremium
                    ? l10n.subscriptionCardActiveDesc
                    : l10n.subscriptionCardDesc,
                textAlign: TextAlign.start,
                maxLines: isTablet ? 3 : null,
                overflow: isTablet ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: isTablet ? 12 : 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 16),
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
                padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isPremium
                    ? l10n.subscriptionCardActiveBtn
                    : l10n.subscriptionCardBtn,
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
              Text(
                AppLocalizations.of(context)!.offlineMode,
                style: const TextStyle(
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
                  child: Text(AppLocalizations.of(context)!.readyStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isPending
                      ? AppLocalizations.of(context)!.answersPendingSync(syncProv.pendingAttempts)
                      : AppLocalizations.of(context)!.allAnswersSynced,
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
                label: Text(AppLocalizations.of(context)!.syncNow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryStats(BuildContext context, int totalSolved, int accuracy, int streak, {bool isTablet = false}) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isTablet ? 22 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myMasteryProgress,
            style: TextStyle(
                fontSize: isTablet ? 16 : 15,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimaryLight),
          ),
          SizedBox(height: isTablet ? 18 : 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.primary,
                  bgColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                  label: l10n.questionsLabel,
                  value: totalSolved.toString(),
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.insights,
                  iconColor: const Color(0xFF16A34A),
                  bgColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                  label: l10n.accuracy,
                  value: '$accuracy%',
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isTablet ? 14 : 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFD97706),
                  bgColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
                  label: l10n.streakLabel,
                  value: l10n.streakDaysCount(streak),
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInviteFriendsCard(BuildContext context, String referralCode, {bool isTablet = false}) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isTablet ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.inviteFriendsTitle,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.inviteFriendsDesc,
                maxLines: isTablet ? 3 : null,
                overflow: isTablet ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 13,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 16, vertical: isTablet ? 8 : 12),
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
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: referralCode));
                    ToastUtils.showSuccess(context, l10n.referralCodeCopied);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.copy, size: 18, color: Color(0xFF4F46E5)),
                  ),
                ),
              ],
            ),
          ),
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
    bool isTablet = false,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14, horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: isTablet ? 26 : 22),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                value,
                style: TextStyle(
                    fontSize: isTablet ? 20 : 18, fontWeight: FontWeight.bold, color: iconColor),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    letterSpacing: 0.5),
              ),
            ),
            Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
              clipBehavior: Clip.antiAlias,
              child: Column(children: children),
            ),
          ],
        );
      },
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                )
              : null,
          trailing: trailing ??
              Icon(Icons.chevron_right,
                  color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400),
          onTap: onTap,
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProv) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.themeMode,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context,
                  title: l10n.themeLight,
                  subtitle: 'واجهة نهارية عالية التباين وواضحة',
                  icon: Icons.light_mode_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  isSelected: themeProv.themeMode == ThemeMode.light,
                  onTap: () {
                    themeProv.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildThemeOption(
                  context,
                  title: l10n.themeDark,
                  subtitle: 'واجهة ليلية مريحة للعين ومتقنة',
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  isSelected: themeProv.themeMode == ThemeMode.dark,
                  onTap: () {
                    themeProv.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildThemeOption(
                  context,
                  title: l10n.themeSystem,
                  subtitle: 'يتبع الإعداد التلقائي لجهازك',
                  icon: Icons.brightness_auto_rounded,
                  iconColor: AppColors.primary,
                  isSelected: themeProv.themeMode == ThemeMode.system,
                  onTap: () {
                    themeProv.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                  size: 24),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProv) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context,
                  title: 'العربية (Arabic)',
                  subtitle: 'الواجهة باللغة العربية',
                  isSelected: localeProv.isArabic,
                  onTap: () {
                    localeProv.setLanguageCode('ar');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildLanguageOption(
                  context,
                  title: 'English',
                  subtitle: 'English interface',
                  isSelected: !localeProv.isArabic,
                  onTap: () {
                    localeProv.setLanguageCode('en');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF0F172A) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24)
            else
              Icon(Icons.radio_button_unchecked,
                  color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400, size: 24),
          ],
        ),
      ),
    );
  }
}
