import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import 'achievement_card.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isAchievementsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.achievements.isEmpty) {
          return Center(child: Text(l10n.noAchievements));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: provider.achievements.length,
          itemBuilder: (context, index) {
            return AchievementCard(achievement: provider.achievements[index]);
          },
        );
      },
    );
  }
}
