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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild to filter the grid
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          l10n.library,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFF1E293B)), // Force dark text color for contrast on white fillColor in both themes
              decoration: InputDecoration(
                hintText: l10n.searchSpecialty,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            _buildActionCard(
              context,
              title: l10n.bookmarks,
              icon: Icons.bookmark,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarksScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Specialties Grid
            Text(
              l10n.medicalSpecialties,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (specialtyProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (specialtyProvider.specialties.isEmpty)
              Center(child: Text(l10n.fieldRequired)) // Fallback text
            else
              Builder(
                builder: (context) {
                  final baseSpecialties = specialtyProvider
                          .selectedSpecialtyIds.isNotEmpty
                      ? specialtyProvider.specialties
                          .where((s) => specialtyProvider.selectedSpecialtyIds
                              .contains(s.id))
                          .toList()
                      : specialtyProvider.specialties;

                  final filteredSpecialties = _searchController.text.isEmpty
                      ? baseSpecialties
                      : baseSpecialties
                          .where((s) => s.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                              SpecialtyLocalization(s).getLocalizedName(l10n).toLowerCase().contains(_searchController.text.toLowerCase()))
                          .toList();

                  if (filteredSpecialties.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No results found', // Fallback for l10n
                                style: TextStyle(color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredSpecialties.length,
                    itemBuilder: (context, index) {
                      final category = filteredSpecialties[index];
                      return _buildSpecialtyCard(
                          context,
                          category,
                          () => _navigateToSpecialtyDetail(context, category));
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard(
      BuildContext context, dynamic category, VoidCallback onTap) {
    final l10n = AppLocalizations.of(context)!;
    // Assuming category is Specialty entity/model
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            category.icon != null && category.icon.contains('/uploads/')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://healthlicenseprep.com${category.icon}',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.medical_services_outlined, size: 32, color: AppColors.primary),
                    ),
                  )
                : Icon(Icons.medical_services_outlined,
                    size: 32, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              SpecialtyLocalization(category).getLocalizedName(l10n),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.watch<DashboardProvider>().showQuestionCount
                  ? '${category.totalQuestions ?? 0} Qs'
                  : 'Practice',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
