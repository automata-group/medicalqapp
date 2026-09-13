import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import '../../../domain/entities/specialty.dart';
import '../../providers/specialty_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'bookmarks_screen.dart';

import 'specialty_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/specialty_extension.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const bool isLibraryTemporarilyClosed = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = context.read<SpecialtyProvider>();
      if (sp.specialties.isEmpty) {
        sp.loadSpecialties();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToSpecialtyDetail(BuildContext context, Specialty specialty) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpecialtyDetailScreen(specialty: specialty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final specialtyProvider = context.watch<SpecialtyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final isLargeTablet = width >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.library,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 16.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isLibraryTemporarilyClosed
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Section: Bookmarks (Open and functional)
                      _buildBookmarksCard(context, l10n, isDark, isTablet),
                      const SizedBox(height: 24),

                      // Bottom Section: Temporarily Closed Notice
                      _buildTemporarilyClosedCard(context, isDark, isTablet),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.searchSpecialty,
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Quick Actions (Bookmarks)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isTablet ? 360 : double.infinity),
                        child: _buildActionCard(
                          context,
                          title: l10n.bookmarks,
                          icon: Icons.bookmark_rounded,
                          color: AppColors.primary,
                          isTablet: isTablet,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarksScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Specialties Header
                      Row(
                        children: [
                          Text(
                            l10n.medicalSpecialties,
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (specialtyProvider.specialties.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${specialtyProvider.specialties.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (specialtyProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (specialtyProvider.specialties.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              l10n.fieldRequired,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        )
                      else
                        Builder(
                          builder: (context) {
                            // Requirement 4: All specialties appear automatically without filtering!
                            final baseSpecialties = specialtyProvider.specialties;

                            final filteredSpecialties = _searchController.text.isEmpty
                                ? baseSpecialties
                                : baseSpecialties.where((s) {
                                    final query = _searchController.text.toLowerCase();
                                    final nameMatches = s.name.toLowerCase().contains(query);
                                    final localizedMatches = SpecialtyLocalization(s)
                                        .getLocalizedName(l10n)
                                        .toLowerCase()
                                        .contains(query);
                                    return nameMatches || localizedMatches;
                                  }).toList();

                            if (filteredSpecialties.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No results found',
                                        style: TextStyle(
                                          color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLargeTablet ? 4 : (isTablet ? 3 : 2),
                                childAspectRatio: isTablet ? 1.25 : 1.1,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredSpecialties.length,
                              itemBuilder: (context, index) {
                                final category = filteredSpecialties[index];
                                return _buildSpecialtyCard(
                                  context,
                                  category,
                                  isTablet: isTablet,
                                  onTap: () => _navigateToSpecialtyDetail(context, category),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    bool isTablet,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isTablet ? 360 : double.infinity),
      child: _buildActionCard(
        context,
        title: l10n.bookmarks,
        icon: Icons.bookmark_rounded,
        color: AppColors.primary,
        isTablet: isTablet,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookmarksScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemporarilyClosedCard(
    BuildContext context,
    bool isDark,
    bool isTablet,
  ) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 36 : 24,
        vertical: isTablet ? 40 : 32,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_clock_rounded,
              size: isTablet ? 40 : 34,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'المكتبة مغلقة مؤقتاً' : 'Library Temporarily Closed',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(
              isAr
                  ? 'نقوم حالياً بتطوير وتحديث محتوى التخصصات الطبية والأسئلة لتقديم تجربة دراسية أفضل. بإمكانك الوصول إلى أسئلتك المحفوظة أعلاه في أي وقت.'
                  : 'We are currently updating our medical specialties and question bank. You can still access your saved bookmarks above.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isTablet ? 14 : 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 9 : 11),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isTablet ? 22 : 26,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 14 : 15,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(
    BuildContext context,
    dynamic category, {
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double iconDimension = isTablet ? 36.0 : 44.0;
    final double fallbackIconSize = isTablet ? 26.0 : 32.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            category.icon != null && category.icon.contains('/uploads/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://healthlicenseprep.com${category.icon}',
                      width: iconDimension,
                      height: iconDimension,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.medical_services_outlined,
                        size: fallbackIconSize,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Container(
                    padding: EdgeInsets.all(isTablet ? 8 : 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      size: fallbackIconSize,
                      color: AppColors.primary,
                    ),
                  ),
            SizedBox(height: isTablet ? 8 : 12),
            Text(
              SpecialtyLocalization(category).getLocalizedName(l10n),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 13 : 14,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.watch<DashboardProvider>().showQuestionCount
                  ? '${category.totalQuestions ?? 0} Qs'
                  : 'Practice',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: isTablet ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
