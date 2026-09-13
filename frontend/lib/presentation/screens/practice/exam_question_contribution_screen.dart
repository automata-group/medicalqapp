import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/contribution_provider.dart';
import '../../providers/specialty_provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';

class ExamQuestionContributionScreen extends StatefulWidget {
  const ExamQuestionContributionScreen({super.key});

  @override
  State<ExamQuestionContributionScreen> createState() =>
      _ExamQuestionContributionScreenState();
}

class _ExamQuestionContributionScreenState
    extends State<ExamQuestionContributionScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedSpecialtyId;
  final TextEditingController _questionTextController = TextEditingController();
  final TextEditingController _optAController = TextEditingController();
  final TextEditingController _optBController = TextEditingController();
  final TextEditingController _optCController = TextEditingController();
  final TextEditingController _optDController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedAnswer = 'unsure'; // 'A', 'B', 'C', 'D', 'unsure'
  String _confidenceLevel = 'high'; // 'high', 'medium', 'low'
  DateTime? _examDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final specProvider = context.read<SpecialtyProvider>();
      if (specProvider.specialties.isEmpty) {
        specProvider.loadUserSpecialties();
      } else {
        setState(() {
          _selectedSpecialtyId = specProvider.specialties.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  Future<void> _selectDate() async {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E293B),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Theme.of(context).primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _examDate = picked;
      });
    }
  }

  void _resetForm() {
    _questionTextController.clear();
    _optAController.clear();
    _optBController.clear();
    _optCController.clear();
    _optDController.clear();
    _notesController.clear();
    setState(() {
      _selectedAnswer = 'unsure';
      _confidenceLevel = 'high';
      _examDate = null;
    });
  }

  void _showSuccessDialog(AppLocalizations? l10n, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              l10n?.contributionReceivedTitle ?? 'تم استلام مساهمتك',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          l10n?.contributionReceivedMessage ??
              'شكرًا لمساعدتك في تطوير بنك الأسئلة.\nسيقوم فريقنا بمراجعة السؤال والتحقق منه قبل إضافته.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: Text(l10n?.contributeAnotherQuestion ?? 'مساهمة بسؤال آخر'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // back to previous screen
            },
            child: Text(l10n?.backToHome ?? 'العودة للرئيسية'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(AppLocalizations? l10n) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecialtyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.pleaseSelectSpecialty ?? 'يرجى اختيار التخصص')),
      );
      return;
    }

    final List<Map<String, String>> options = [];
    if (_optAController.text.trim().isNotEmpty) {
      options.add({'key': 'A', 'text': _optAController.text.trim()});
    }
    if (_optBController.text.trim().isNotEmpty) {
      options.add({'key': 'B', 'text': _optBController.text.trim()});
    }
    if (_optCController.text.trim().isNotEmpty) {
      options.add({'key': 'C', 'text': _optCController.text.trim()});
    }
    if (_optDController.text.trim().isNotEmpty) {
      options.add({'key': 'D', 'text': _optDController.text.trim()});
    }

    final provider = context.read<ContributionProvider>();
    final success = await provider.submitContribution(
      specialtyId: _selectedSpecialtyId!,
      questionText: _questionTextController.text.trim(),
      options: options.isNotEmpty ? options : null,
      userAnswer: _selectedAnswer != 'unsure' ? _selectedAnswer : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      examDate: _examDate,
      confidenceLevel: _confidenceLevel,
    );

    if (success && mounted) {
      _showSuccessDialog(l10n, provider.successMessage ?? '');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? (l10n?.submissionError ?? 'حدث خطأ أثناء الإرسال')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final specialtyProvider = context.watch<SpecialtyProvider>();
    final contributionProvider = context.watch<ContributionProvider>();
    final specialties = specialtyProvider.specialties;

    // Set initial specialty if null
    if (_selectedSpecialtyId == null && specialties.isNotEmpty) {
      _selectedSpecialtyId = specialties.first.id;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.examContributionTitle ?? 'شارك بسؤال من اختبارك',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: isDark ? Theme.of(context).cardColor : Colors.white,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Motivational Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('📝', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.examRecallTitle ?? 'تذكّر سؤالاً جاءك في الاختبار؟',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.examContributionSubtitle ??
                                  'ساهم بالسؤال وساعد زملاءك في الاستعداد لاختبار الهيئة. سيتم تدقيقه واعتماده رسمياً.',
                              style: const TextStyle(
                                color: Color(0xFFE0E7FF),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Specialty Dropdown
                _buildSectionTitle(l10n?.specialtyRequired ?? 'التخصص *', isDark),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      value: _selectedSpecialtyId,
                      hint: Text(
                        l10n?.selectSpecialtyHint ?? 'اختر التخصص',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      items: specialties.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            s.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSpecialtyId = val;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Question Text
                _buildSectionTitle(l10n?.questionTextLabel ?? 'ما الذي تتذكره من السؤال؟ *', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questionTextController,
                  maxLines: 5,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n?.questionTextHint ??
                        'اكتب نص السؤال أو الحالة السريرية أو الأعراض كما تذكرتها...',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return l10n?.questionTextValidation ?? 'يرجى كتابة ما تتذكره من السؤال';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 3. Options (A, B, C, D)
                _buildSectionTitle(l10n?.optionsOptional ?? 'الخيارات إن كنت تتذكرها (اختياري)', isDark),
                const SizedBox(height: 12),
                _buildOptionField('A', _optAController, l10n, isDark),
                const SizedBox(height: 10),
                _buildOptionField('B', _optBController, l10n, isDark),
                const SizedBox(height: 10),
                _buildOptionField('C', _optCController, l10n, isDark),
                const SizedBox(height: 10),
                _buildOptionField('D', _optDController, l10n, isDark),
                const SizedBox(height: 24),

                // 4. Perceived Correct Answer
                _buildSectionTitle(l10n?.perceivedCorrectAnswer ?? 'ما الإجابة التي تعتقد أنها صحيحة؟', isDark),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildAnswerChip('A', l10n, isDark),
                    _buildAnswerChip('B', l10n, isDark),
                    _buildAnswerChip('C', l10n, isDark),
                    _buildAnswerChip('D', l10n, isDark),
                    _buildAnswerChip('unsure', l10n, isDark, customLabel: l10n?.unsureAnswer ?? 'غير متأكد'),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Confidence Level
                _buildSectionTitle(l10n?.confidenceLevelQuestion ?? 'مدى ثقتك بتذكرك للسؤال؟ *', isDark),
                const SizedBox(height: 10),
                _buildConfidenceTile(
                  key: 'high',
                  emoji: '🟢',
                  title: l10n?.confidenceHighTitle ?? 'أتذكره بشكل جيد',
                  subtitle: l10n?.confidenceHighSubtitle ?? 'حرفياً أو شبه مطابق لما ورد في الاختبار',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildConfidenceTile(
                  key: 'medium',
                  emoji: '🟡',
                  title: l10n?.confidenceMediumTitle ?? 'أتذكر معظمه',
                  subtitle: l10n?.confidenceMediumSubtitle ?? 'قريب جداً من النص الأصلي مع نسيان بعض التفاصيل',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildConfidenceTile(
                  key: 'low',
                  emoji: '🔴',
                  title: l10n?.confidenceLowTitle ?? 'أتذكر الفكرة فقط',
                  subtitle: l10n?.confidenceLowSubtitle ?? 'أتذكر فكرة الحالة السريرية والموضوع العام',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // 6. Exam Date
                _buildSectionTitle(l10n?.examDateOptional ?? 'متى اختبرت؟ (اختياري)', isDark),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _examDate != null
                              ? DateFormat('yyyy-MM-dd').format(_examDate!)
                              : (l10n?.selectExamDateHint ?? 'اختر تاريخ الاختبار إن كنت تتذكره'),
                          style: TextStyle(
                            color: _examDate != null
                                ? (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B))
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (_examDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _examDate = null),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Note / Explanation
                _buildSectionTitle(l10n?.notesOptional ?? 'شرح أو ملاحظة (اختياري)', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n?.notesHint ??
                        'أضف أي ملاحظة حول سبب اختيارك أو تفاصيل إضافية عن السؤال...',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: contributionProvider.isSubmitting
                        ? null
                        : () => _submitForm(l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: contributionProvider.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            l10n?.submitForReview ?? 'إرسال للمراجعة',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildOptionField(String key, TextEditingController controller, AppLocalizations? l10n, bool isDark) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE),
            ),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: l10n?.optionTextHint(key) ?? 'نص الخيار ($key)',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 13,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerChip(String key, AppLocalizations? l10n, bool isDark, {String? customLabel}) {
    final isSelected = _selectedAnswer == key;
    final text = customLabel ?? (l10n?.optionLabel(key) ?? 'الخيار $key');
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      selectedColor: isDark ? const Color(0xFF059669) : const Color(0xFF10B981),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF10B981)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedAnswer = key);
      },
    );
  }

  Widget _buildConfidenceTile({
    required String key,
    required String emoji,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final isSelected = _confidenceLevel == key;
    return InkWell(
      onTap: () => setState(() => _confidenceLevel = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.35) : const Color(0xFFF0FDF4))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D))
                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
          ],
        ),
      ),
    );
  }
}
