import 'package:flutter/material.dart';
import '../../../data/models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlocked = achievement.isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? (isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                  : const Color(0xFFFDE68A))
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUnlocked ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.amber.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isUnlocked
                          ? Colors.amber.withValues(alpha: 0.5)
                          : (isDark
                              ? const Color(0xFF334155)
                              : Colors.grey.shade300),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 26,
                        color: isUnlocked
                            ? null
                            : Colors.grey.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isUnlocked
                        ? (isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF1E293B))
                        : (isDark
                            ? const Color(0xFF64748B)
                            : Colors.grey.shade500),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (achievement.xpReward > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12)
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? (isDark
                                ? const Color(0xFFFBBF24)
                                : Colors.amber.shade800)
                            : (isDark
                                ? const Color(0xFF64748B)
                                : Colors.grey.shade500),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Status Badge in corner (Checkmark if unlocked, Lock if locked)
          PositionedDirectional(
            top: 8,
            end: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFF10B981)
                    : (isDark
                        ? const Color(0xFF334155)
                        : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnlocked ? Icons.check : Icons.lock,
                size: 11,
                color: isUnlocked
                    ? Colors.white
                    : (isDark
                        ? const Color(0xFF94A3B8)
                        : Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
