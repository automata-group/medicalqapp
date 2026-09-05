import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../providers/contribution_provider.dart';
import '../../providers/specialty_provider.dart';

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
  String? _selectedImagePath;

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

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImagePath = result.files.single.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اختيار الصورة: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      _selectedImagePath = null;
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: const [
            Text('🎉', style: TextStyle(fontSize: 44)),
            SizedBox(height: 8),
            Text(
              'تم استلام مساهمتك',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'شكرًا لمساعدتك في تطوير SDLE.\nسيقوم فريقنا بمراجعة السؤال والتحقق منه قبل إضافته إلى بنك الأسئلة.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: const Text('مساهمة بسؤال آخر'),
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
            child: const Text('العودة للرئيسية'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecialtyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التخصص')),
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
      imagePath: _selectedImagePath,
    );

    if (success && mounted) {
      _showSuccessDialog(provider.successMessage ?? '');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'حدث خطأ أثناء الإرسال'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialtyProvider = context.watch<SpecialtyProvider>();
    final contributionProvider = context.watch<ContributionProvider>();
    final specialties = specialtyProvider.specialties;

    // Set initial specialty if null
    if (_selectedSpecialtyId == null && specialties.isNotEmpty) {
      _selectedSpecialtyId = specialties.first.id;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'شارك بسؤال من اختبارك',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
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
                          children: const [
                            Text(
                              'تذكّر سؤالاً جاءك في الاختبار؟',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ساهم بالسؤال وساعد زملاءك في الاستعداد لاختبار الهيئة. سيتم تدقيقه واعتماده رسمياً.',
                              style: TextStyle(
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
                _buildSectionTitle('التخصص *'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedSpecialtyId,
                      hint: const Text('اختر التخصص'),
                      items: specialties.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
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
                _buildSectionTitle('ما الذي تتذكره من السؤال؟ *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questionTextController,
                  maxLines: 5,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'اكتب نص السؤال أو الحالة السريرية أو الأعراض كما تذكرتها...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 5) {
                      return 'يرجى كتابة ما تتذكره من السؤال';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 3. Options (A, B, C, D)
                _buildSectionTitle('الخيارات إن كنت تتذكرها (اختياري)'),
                const SizedBox(height: 12),
                _buildOptionField('A', _optAController),
                const SizedBox(height: 10),
                _buildOptionField('B', _optBController),
                const SizedBox(height: 10),
                _buildOptionField('C', _optCController),
                const SizedBox(height: 10),
                _buildOptionField('D', _optDController),
                const SizedBox(height: 24),

                // 4. Perceived Correct Answer
                _buildSectionTitle('ما الإجابة التي تعتقد أنها صحيحة؟'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildAnswerChip('A'),
                    _buildAnswerChip('B'),
                    _buildAnswerChip('C'),
                    _buildAnswerChip('D'),
                    _buildAnswerChip('unsure', label: 'غير متأكد'),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Confidence Level
                _buildSectionTitle('مدى ثقتك بتذكرك للسؤال؟ *'),
                const SizedBox(height: 10),
                _buildConfidenceTile(
                  key: 'high',
                  emoji: '🟢',
                  title: 'أتذكره بشكل جيد',
                  subtitle: 'حرفياً أو شبه مطابق لما ورد في الاختبار',
                ),
                const SizedBox(height: 8),
                _buildConfidenceTile(
                  key: 'medium',
                  emoji: '🟡',
                  title: 'أتذكر معظمه',
                  subtitle: 'قريب جداً من النص الأصلي مع نسيان بعض التفاصيل',
                ),
                const SizedBox(height: 8),
                _buildConfidenceTile(
                  key: 'low',
                  emoji: '🔴',
                  title: 'أتذكر الفكرة فقط',
                  subtitle: 'أتذكر فكرة الحالة السريرية والموضوع العام',
                ),
                const SizedBox(height: 24),

                // 6. Exam Date
                _buildSectionTitle('متى اختبرت؟ (اختياري)'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF64748B), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _examDate != null
                              ? DateFormat('yyyy-MM-dd').format(_examDate!)
                              : 'اختر تاريخ الاختبار إن كنت تتذكره',
                          style: TextStyle(
                            color: _examDate != null
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        if (_examDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _examDate = null),
                            child: const Icon(Icons.close, size: 18, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Note / Explanation
                _buildSectionTitle('شرح أو ملاحظة (اختياري)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'أضف أي ملاحظة حول سبب اختيارك أو تفاصيل إضافية عن السؤال...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 8. Image Attachment
                _buildSectionTitle('إرفاق صورة (اختياري)'),
                const SizedBox(height: 8),
                if (_selectedImagePath == null)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('اختيار صورة من الجهاز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF93C5FD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImagePath!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedImagePath!.split(RegExp(r'[/\\]')).last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => setState(() => _selectedImagePath = null),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تنبيه: يرجى عدم رفع أي صور تحتوي على بيانات شخصية أو مواد محظورة.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: contributionProvider.isSubmitting ? null : _submitForm,
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
                        : const Text(
                            'إرسال للمراجعة',
                            style: TextStyle(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildOptionField(String key, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Text(
            key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D4ED8),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'نص الخيار ($key)',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerChip(String key, {String? label}) {
    final isSelected = _selectedAnswer == key;
    return ChoiceChip(
      label: Text(label ?? 'الخيار $key'),
      selected: isSelected,
      selectedColor: const Color(0xFF10B981),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF334155),
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
  }) {
    final isSelected = _confidenceLevel == key;
    return InkWell(
      onTap: () => setState(() => _confidenceLevel = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
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
                      color: isSelected ? const Color(0xFF15803D) : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
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
