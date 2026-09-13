import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/utils/specialty_extension.dart';
import '../../providers/specialty_provider.dart';
import '../../screens/exam/exam_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/specialty.dart';

class SpecialtiesCarousel extends StatefulWidget {
  const SpecialtiesCarousel({super.key});

  @override
  State<SpecialtiesCarousel> createState() => _SpecialtiesCarouselState();
}

class _SpecialtiesCarouselState extends State<SpecialtiesCarousel> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      final progress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
      if ((progress - _scrollProgress).abs() > 0.005) {
        setState(() {
          _scrollProgress = progress;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Consumer<SpecialtyProvider>(
      builder: (context, provider, child) {
        final specialties = provider.specialties;

        if (provider.isLoading && specialties.isEmpty) {
          return SizedBox(
            height: isTablet ? 160 : 120,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (specialties.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 24,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.specialties,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    ),
                  ),
                  if (isTablet)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          onPressed: () {
                            if (_scrollController.hasClients) {
                              final newOffset = _scrollController.offset - (isTablet ? 220 : 160);
                              _scrollController.animateTo(
                                newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          onPressed: () {
                            if (_scrollController.hasClients) {
                              final newOffset = _scrollController.offset + (isTablet ? 220 : 160);
                              _scrollController.animateTo(
                                newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              height: isTablet ? 188 : 156,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    return _buildSpecialtyCard(context, l10n, specialty, isTablet);
                  },
                ),
              ),
            ),
            if (specialties.length > 2)
              _buildScrollIndicator(isDark, isTablet, isRtl),
          ],
        );
      },
    );
  }

  Widget _buildScrollIndicator(bool isDark, bool isTablet, bool isRtl) {
    final trackWidth = isTablet ? 96.0 : 68.0;
    final thumbWidth = isTablet ? 34.0 : 24.0;
    final availableTravel = trackWidth - thumbWidth;
    final leftOffset = isRtl
        ? (1.0 - _scrollProgress) * availableTravel
        : _scrollProgress * availableTravel;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        width: trackWidth,
        height: 5,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              left: leftOffset,
              top: 0,
              bottom: 0,
              child: Container(
                width: thumbWidth,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
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

  Widget _buildSpecialtyCard(
    BuildContext context,
    AppLocalizations l10n,
    Specialty specialty,
    bool isTablet,
  ) {
    final localizedName = specialty.getLocalizedName(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardWidth = isTablet ? 155.0 : 124.0;
    final iconCircleSize = isTablet ? 60.0 : 46.0;
    final iconSize = isTablet ? 32.0 : 24.0;
    final titleFontSize = isTablet ? 14.0 : 12.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamScreen(
              specialtyId: specialty.id.toString(),
              shuffle: false,
              autoResume: true,
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 10,
          vertical: isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 22 : 20),
          border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: specialty.icon.isNotEmpty && specialty.icon.contains('/uploads/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(iconCircleSize / 2),
                    child: Image.network(
                      'https://healthlicenseprep.com${specialty.icon}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.medical_services_rounded, color: AppColors.primary, size: iconSize),
                    ),
                  )
                : Icon(Icons.medical_services_rounded, 
                    color: AppColors.primary, size: iconSize),
            ),
            SizedBox(height: isTablet ? 10 : 8),
            Expanded(
              child: Center(
                child: Text(
                  localizedName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    height: 1.25,
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
