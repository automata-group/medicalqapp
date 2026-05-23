import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/specialty_provider.dart';
import '../../domain/entities/specialty.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../core/utils/toast_utils.dart';
import 'study_goal_screen.dart';
import '../providers/auth_provider.dart';
import 'subscription/pricing_screen.dart';
import '../../core/utils/specialty_extension.dart';

class SpecialtySelectionScreen extends StatefulWidget {
  const SpecialtySelectionScreen({super.key});

  @override
  State<SpecialtySelectionScreen> createState() =>
      _SpecialtySelectionScreenState();
}

class _SpecialtySelectionScreenState extends State<SpecialtySelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialtyProvider>().loadSpecialties();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _SpecialtySelectionView();
  }
}

class _SpecialtySelectionView extends StatefulWidget {
  const _SpecialtySelectionView();

  @override
  State<_SpecialtySelectionView> createState() => _SpecialtySelectionViewState();
}

class _SpecialtySelectionViewState extends State<_SpecialtySelectionView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<SpecialtyProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final filteredSpecialties = provider.specialties.where((specialty) {
      if (_searchQuery.isEmpty) return true;
      final name = specialty.name.toLowerCase();
      final localizedName = specialty.getLocalizedName(l10n).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || localizedName.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50], // background-light
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectSpecialty, // Add to ARB: "Select Specialty" / "اختر التخصص"
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Color(0xFF1E293B)), // Force dark text color for contrast on white fillColor in both themes
                    decoration: InputDecoration(
                      hintText: l10n.searchSpecialty, // Add to ARB
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredSpecialties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No specialties found',
                                  style: TextStyle(color: Colors.grey.shade400)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: filteredSpecialties.length,
                          itemBuilder: (context, index) {
                            final specialty = filteredSpecialties[index];
                            final isSelected = provider.isSelected(specialty.id);
                            final isLocked = specialty.isPremium &&
                                !(authProvider.user?.isPremium ?? false);
                            // Cycle through the styles
                            final style = _SpecialtyCardStyle
                                .styles[index % _SpecialtyCardStyle.styles.length];

                            return _SpecialtyCard(
                              specialty: specialty,
                              style: style,
                              isSelected: isSelected,
                              isLocked: isLocked,
                              onTap: () {
                                if (isLocked) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const PricingScreen()),
                                  );
                                  return;
                                }
                                provider.toggleSpecialty(specialty.id);
                              },
                            );
                          },
                        ),
            ),

            // Continue Button (Only visible if selection made)
            if (provider.selectedSpecialtyIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await provider.saveInterests();
                      if (context.mounted) {
                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StudyGoalScreen()),
                          );
                        } else {
                          ToastUtils.showError(context,
                              'Failed to save selections. Please try again.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.continueText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  final Specialty specialty;
  final _SpecialtyCardStyle style;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _SpecialtyCard({
    required this.specialty,
    required this.style,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Icons mapping based on name
    IconData iconData = Icons.medical_services;
    final name = specialty.name.toLowerCase();

    if (name.contains('ortho')) {
      iconData = Icons.sentiment_satisfied_alt;
    } else if (name.contains('endo')) {
      iconData = Icons.flash_on;
    } else if (name.contains('prosth')) {
      iconData = Icons.build;
    } else if (name.contains('perio')) {
      iconData = Icons.cleaning_services;
    } else if (name.contains('pediatric')) {
      iconData = Icons.child_care;
    } else if (name.contains('surg')) {
      iconData = Icons.local_hospital;
    } else if (name.contains('restor')) {
      iconData = Icons.handyman;
    } else if (name.contains('oral')) {
      iconData = Icons.face;
    } else if (name.contains('ethics')) {
      iconData = Icons.balance;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: BorderRadius.circular(16), // rounded-xl
          border: Border.all(
            color: isSelected ? AppColors.primary : style.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16), // p-4
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              width: 48, // w-12
              height: 48, // h-12
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12), // rounded-xl
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (specialty.icon != null && specialty.icon.contains('/uploads/'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://healthlicenseprep.com${specialty.icon}',
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(iconData, color: style.iconColor, size: 24),
                      ),
                    )
                  else
                    Icon(iconData, color: style.iconColor, size: 24),
                  if (isLocked)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12), // gap-3

            // Text Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialty.getLocalizedName(l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700, // font-bold
                    fontSize: 14, // text-sm
                    color: Color(0xFF1E293B), // text-slate-800
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // mt-0.5
                Text(
                  l10n.questionsAvailable(specialty.totalQuestions),
                  style: const TextStyle(
                    fontSize: 10, // text-[10px]
                    color: Color(0xFF64748B), // text-slate-500
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyCardStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;

  const _SpecialtyCardStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });

  static const styles = [
    // Card Red
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFFFF1F1), // bg-card-red
      borderColor: Color(0x80FFCDD2), // border-red-100/50 approx
      iconColor: Colors.red,
    ),
    // Card Blue
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFF0F7FF), // bg-card-blue
      borderColor: Color(0x80BBDEFB), // border-blue-100/50 approx
      iconColor: AppColors.primary,
    ),
    // Card Green
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFF0FDF4), // bg-card-green
      borderColor: Color(0x80C8E6C9), // border-green-100/50 approx
      iconColor: Colors.green,
    ),
    // Card Orange
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFFFFAF0), // bg-card-orange
      borderColor: Color(0x80FFE0B2), // border-orange-100/50 approx
      iconColor: Colors.orange,
    ),
    // Card Purple
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFFAF5FF), // bg-card-purple
      borderColor: Color(0x80E1BEE7), // border-purple-100/50 approx
      iconColor: Colors.purple,
    ),
    // Card Teal
    _SpecialtyCardStyle(
      backgroundColor: Color(0xFFF0FDFA), // bg-card-teal
      borderColor: Color(0x80B2DFDB), // border-teal-100/50 approx
      iconColor: Colors.teal,
    ),
  ];
}
