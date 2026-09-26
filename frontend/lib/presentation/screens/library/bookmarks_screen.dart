import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/question_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/question_model.dart';
import '../exam/exam_screen.dart';
import '../../../core/utils/toast_utils.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'all';
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionProvider>().fetchBookmarks();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuestionModel> _filterQuestions(List<QuestionModel> questions) {
    return questions.where((q) {
      // Specialty filter
      if (_selectedSpecialty != 'all' && (q.specialty ?? '') != _selectedSpecialty) {
        return false;
      }
      // Difficulty filter
      if (_selectedDifficulty != 'all' && q.difficulty.toLowerCase() != _selectedDifficulty.toLowerCase()) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final inText = q.text.toLowerCase().contains(_searchQuery);
        final inSpecialty = (q.specialty ?? '').toLowerCase().contains(_searchQuery);
        final inExplanation = (q.explanation ?? '').toLowerCase().contains(_searchQuery);
        final inReferences = (q.references ?? '').toLowerCase().contains(_searchQuery);
        if (!inText && !inSpecialty && !inExplanation && !inReferences) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Set<String> _extractSpecialties(List<QuestionModel> questions) {
    final set = <String>{};
    for (final q in questions) {
      if (q.specialty != null && q.specialty!.trim().isNotEmpty) {
        set.add(q.specialty!.trim());
      }
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 700;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isArabic ? 'المحفوظات والأسئلة المفضلة' : l10n.bookmarks,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingBookmarks) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (provider.errorMessage != null && provider.bookmarkedQuestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchBookmarks(),
                      child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allBookmarked = provider.bookmarkedQuestions;

          if (allBookmarked.isEmpty) {
            return _buildEmptyState(isDark, isArabic);
          }

          final filteredQuestions = _filterQuestions(allBookmarked);
          final specialties = _extractSpecialties(allBookmarked);

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 940 : double.infinity),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 28 : 16,
                  vertical: isTablet ? 24 : 16,
                ),
                children: [
                  // iPad Executive Hero Banner
                  if (isTablet)
                    _buildHeroBanner(context, isDark, isArabic, allBookmarked.length, specialties.length),

                  // Search Bar
                  _buildSearchBar(isDark, isArabic),
                  const SizedBox(height: 12),

                  // Specialty & Difficulty Filter Chips
                  _buildFilterSection(isDark, isArabic, specialties, allBookmarked.length),
                  const SizedBox(height: 16),

                  // Results count indicator
                  if (_searchQuery.isNotEmpty || _selectedSpecialty != 'all' || _selectedDifficulty != 'all')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0, left: 4, right: 4),
                      child: Row(
                        children: [
                          Text(
                            isArabic
                                ? 'نتائج التصفية: ${filteredQuestions.length} من أصل ${allBookmarked.length} سؤال'
                                : 'Showing ${filteredQuestions.length} of ${allBookmarked.length} questions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedSpecialty = 'all';
                                _selectedDifficulty = 'all';
                              });
                            },
                            child: Text(isArabic ? 'إعادة ضبط' : 'Reset'),
                          ),
                        ],
                      ),
                    ),

                  // List of Bookmark Cards
                  if (filteredQuestions.isEmpty)
                    _buildNoFilterResults(isDark, isArabic)
                  else
                    for (int i = 0; i < filteredQuestions.length; i++) ...[
                      _BookmarkCard(
                        question: filteredQuestions[i],
                        index: i + 1,
                        isDark: isDark,
                        isTablet: isTablet,
                        isArabic: isArabic,
                        onRemove: () async {
                          await provider.removeBookmark(filteredQuestions[i].id);
                          if (context.mounted) {
                            ToastUtils.showInfo(
                              context,
                              isArabic ? 'تمت إزالة السؤال من المحفوظات' : 'Bookmark Removed',
                            );
                          }
                        },
                      ),
                      if (i < filteredQuestions.length - 1)
                        const SizedBox(height: 16),
                    ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    bool isDark,
    bool isArabic,
    int totalCount,
    int specialtiesCount,
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
                  Icons.bookmark_added_rounded,
                  color: Color(0xFFFBBF24), // Gold bookmark
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'بنك المحفوظات والأسئلة المفضلة' : 'Bookmarked Questions Hub',
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
                          ? 'مراجعة دقيقة ومكثفة لكافة الأسئلة التي قمت بحفظها مع الشروحات التوليدية ومبررات الإجابات'
                          : 'Comprehensive revision of your saved questions with clinical rationales and citations',
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

          // Overview Stats & Practice CTA Row
          Row(
            children: [
              _buildStatChip(
                icon: Icons.star_rounded,
                label: isArabic ? 'الأسئلة المحفوظة' : 'Saved Questions',
                value: '$totalCount',
                isGold: true,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: Icons.category_rounded,
                label: isArabic ? 'التخصصات' : 'Specialties',
                value: '$specialtiesCount',
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExamScreen(
                        filter: 'bookmarked',
                        shuffle: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_filled_rounded, size: 20),
                label: Text(
                  isArabic ? 'تدريب على المحفوظات' : 'Practice Bookmarks',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald CTA
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
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
    bool isGold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isGold
            ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGold
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
            color: isGold ? const Color(0xFFFBBF24) : Colors.white70,
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
              color: isGold ? const Color(0xFFF59E0B) : Colors.white24,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isGold ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: isArabic
              ? 'ابحث في نص السؤال، الشرح، أو المراجع...'
              : 'Search question text, rationale, or references...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[400],
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    bool isDark,
    bool isArabic,
    Set<String> specialties,
    int totalCount,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All Filter
          _buildFilterChip(
            label: isArabic ? 'جميع المحفوظات ($totalCount)' : 'All ($totalCount)',
            isSelected: _selectedSpecialty == 'all' && _selectedDifficulty == 'all',
            onTap: () {
              setState(() {
                _selectedSpecialty = 'all';
                _selectedDifficulty = 'all';
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // Difficulties
          _buildFilterChip(
            label: isArabic ? 'سهل (Easy)' : 'Easy',
            isSelected: _selectedDifficulty == 'easy',
            icon: Icons.circle,
            iconColor: const Color(0xFF10B981),
            onTap: () {
              setState(() {
                _selectedDifficulty = _selectedDifficulty == 'easy' ? 'all' : 'easy';
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: isArabic ? 'متوسط (Medium)' : 'Medium',
            isSelected: _selectedDifficulty == 'medium',
            icon: Icons.circle,
            iconColor: const Color(0xFFF59E0B),
            onTap: () {
              setState(() {
                _selectedDifficulty = _selectedDifficulty == 'medium' ? 'all' : 'medium';
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: isArabic ? 'صعب (Hard)' : 'Hard',
            isSelected: _selectedDifficulty == 'hard',
            icon: Icons.circle,
            iconColor: const Color(0xFFEF4444),
            onTap: () {
              setState(() {
                _selectedDifficulty = _selectedDifficulty == 'hard' ? 'all' : 'hard';
              });
            },
            isDark: isDark,
          ),

          // Dynamic Specialties
          for (final spec in specialties) ...[
            const SizedBox(width: 8),
            _buildFilterChip(
              label: spec,
              isSelected: _selectedSpecialty == spec,
              onTap: () {
                setState(() {
                  _selectedSpecialty = _selectedSpecialty == spec ? 'all' : spec;
                });
              },
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    IconData? icon,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A8A) : AppColors.primary)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(18),
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
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 8, color: iconColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults(bool isDark, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              isArabic ? 'لا توجد نتائج مطابقة لبحثك' : 'No matching questions found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isArabic ? 'جرب البحث بكلمات أخرى أو قم بإلغاء التصفية' : 'Try different keywords or clear active filters',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                      : const Color(0xFFBFDBFE),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isArabic ? 'لا توجد أسئلة محفوظة بعد' : 'No Bookmarked Questions Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                isArabic
                    ? 'أثناء حل الأسئلة في بنك الأسئلة أو الاختبارات التجريبية، اضغط على زر النجمة ⭐ لحفظ السؤال هنا ومراجعته مع شروحاته في أي وقت'
                    : 'While practicing questions, tap the star icon ⭐ to save challenging questions here for quick revision anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(isArabic ? 'العودة لبنك الأسئلة' : 'Back to Practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final QuestionModel question;
  final int index;
  final bool isDark;
  final bool isTablet;
  final bool isArabic;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.question,
    required this.index,
    required this.isDark,
    required this.isTablet,
    required this.isArabic,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final diffLower = question.difficulty.toLowerCase();
    final Color diffColor = diffLower == 'easy'
        ? const Color(0xFF10B981)
        : (diffLower == 'medium' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isTablet && index <= 3, // Auto-expand first few on iPad
          iconColor: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
          collapsedIconColor: isDark ? const Color(0xFF94A3B8) : Colors.grey[500],
          tilePadding: EdgeInsets.all(isTablet ? 20 : 16),
          childrenPadding: EdgeInsets.fromLTRB(
            isTablet ? 20 : 16,
            0,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Specialty Chip, Difficulty Pill, Index, Bookmark Action
              Row(
                children: [
                  // Specialty Badge
                  if (question.specialty != null && question.specialty!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 13,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            question.specialty!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Difficulty Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: diffColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      question.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: diffColor,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Bookmark active star (Click to remove)
                  Tooltip(
                    message: isArabic ? 'إزالة من المحفوظات' : 'Remove Bookmark',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Question Stem
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  question.text,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                    height: 1.45,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          children: [
            const SizedBox(height: 6),
            Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 16),

            // Options Section Header
            Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  isArabic ? 'الخيارات والإجابة المعتمدة:' : 'Options & Verified Answer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Options List
            ...question.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;
              final isCorrect = option.isCorrect;
              final optionLetter = String.fromCharCode(65 + idx);

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? (isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                          : const Color(0xFFF0FDF4))
                      : (isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF10B981)
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                    width: isCorrect ? 1.5 : 1.0,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Letter badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect
                              ? const Color(0xFF10B981)
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                        alignment: Alignment.center,
                        child: isCorrect
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : Text(
                                optionLetter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.text,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isCorrect ? FontWeight.bold : FontWeight.w500,
                                color: isCorrect
                                    ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                                    : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B)),
                                height: 1.35,
                              ),
                            ),
                            if (isCorrect) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isArabic ? '✓ الإجابة الصحيحة المعتمدة' : '✓ Verified Correct Answer',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
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
              );
            }),

            const SizedBox(height: 12),

            // AI Explanation Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF1E1B4B).withValues(alpha: 0.5),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          const Color(0xFFEEF2FF),
                          const Color(0xFFF8FAFC),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                      : const Color(0xFFC7D2FE),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF6366F1),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'الشرح والتعليل الطبي (Clinical Rationale)' : 'Clinical Rationale & AI Insight',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      (question.explanation != null && question.explanation!.isNotEmpty)
                          ? question.explanation!
                          : (isArabic
                              ? 'لا يوجد شرح مدخل مسبقاً لهذا السؤال، يمكنك الاطلاع على الشرح المباشر أثناء حل الأسئلة.'
                              : 'No pre-saved explanation. Complete the question in practice mode for instant AI rationales.'),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                        height: 1.55,
                      ),
                    ),
                  ),

                  // Why others wrong if available
                  if (question.whyWrong != null) ...[
                    const SizedBox(height: 12),
                    Divider(color: isDark ? Colors.white12 : Colors.black12, height: 16),
                    Text(
                      isArabic ? 'لماذا الخيارات الأخرى غير صحيحة؟' : 'Why other options are incorrect:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: question.whyWrong is Map
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: (question.whyWrong as Map).entries.map((w) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '• Option (${w.key}): ${w.value}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      height: 1.35,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : Text(
                              question.whyWrong.toString(),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ],

                  // References if available
                  if (question.references != null && question.references!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF6366F1)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              'References: ${question.references}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card Action Buttons Footer
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.bookmark_remove_rounded, size: 17),
                    label: Text(
                      isArabic ? 'إزالة من المحفوظات' : 'Remove',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExamScreen(
                            filter: 'bookmarked',
                            shuffle: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      isArabic ? 'بدء الحل في الاختبار' : 'Practice in Exam',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
