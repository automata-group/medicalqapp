import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/toast_utils.dart';
import '../../../providers/question_provider.dart';

class ExamReportSheet extends StatefulWidget {
  final int questionId;

  const ExamReportSheet({
    super.key,
    required this.questionId,
  });

  static Future<void> show(BuildContext context, {required int questionId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => ExamReportSheet(questionId: questionId),
    );
  }

  @override
  State<ExamReportSheet> createState() => _ExamReportSheetState();
}

class _ExamReportSheetState extends State<ExamReportSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedReason = 'scientific_error';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<QuestionProvider>();
    final l10n = AppLocalizations.of(context);
    final desc = _descriptionController.text.trim();

    try {
      final success = await provider.submitReport(_selectedReason, desc);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ToastUtils.showSuccess(
          context,
          l10n?.reportSuccessMessage ?? 'تم إرسال البلاغ بنجاح، شكراً لمساهمتك!',
        );
      } else {
        setState(() {
          _isSubmitting = false;
        });
        ToastUtils.showError(
          context,
          provider.errorMessage ??
              (l10n?.reportFailedMessage ?? 'تعذر إرسال البلاغ، يرجى المحاولة مرة أخرى.'),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ToastUtils.showError(
        context,
        l10n?.reportFailedMessage ?? 'تعذر إرسال البلاغ، يرجى المحاولة مرة أخرى.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final reasons = [
      _ReportReasonItem(
        key: 'scientific_error',
        title: l10n?.reportReasonScientific ?? 'خطأ علمي أو طبي',
        description: l10n?.reportReasonScientificDesc ??
            'خطأ في المعلومة الطبية، الحالة، أو التفسير',
        icon: Icons.biotech_outlined,
        color: const Color(0xFF0284C7),
      ),
      _ReportReasonItem(
        key: 'wrong_answer',
        title: l10n?.reportReasonWrongAnswer ?? 'الإجابة الصحيحة غير دقيقة',
        description: l10n?.reportReasonWrongAnswerDesc ??
            'مفتاح الحل المعلم كصحيح غير مطابق للصواب',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFFDC2626),
      ),
      _ReportReasonItem(
        key: 'typo',
        title: l10n?.reportReasonTypo ?? 'خطأ لغوي أو إملائي',
        description: l10n?.reportReasonTypoDesc ??
            'أخطاء في الصياغة، الترجمة أو التنسيق',
        icon: Icons.spellcheck_rounded,
        color: const Color(0xFFD97706),
      ),
      _ReportReasonItem(
        key: 'confusing',
        title: l10n?.reportReasonConfusing ?? 'سؤال غامض أو غير مكتمل',
        description: l10n?.reportReasonConfusingDesc ??
            'السؤال غير واضح، ناقص خيارات أو غير مفهوم',
        icon: Icons.help_outline_rounded,
        color: const Color(0xFF7C3AED),
      ),
      _ReportReasonItem(
        key: 'other',
        title: l10n?.reportReasonOther ?? 'سبب آخر',
        description: l10n?.reportReasonOtherDesc ?? 'أي ملاحظة أخرى تود إضافتها',
        icon: Icons.more_horiz_rounded,
        color: const Color(0xFF64748B),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Drag Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // 2. Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD97706),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.reportQuestionTitle ?? 'الإبلاغ عن مشكلة في السؤال',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.reportQuestionSubtitle ??
                                  'ساعدنا في الحفاظ على دقة بنك الأسئلة ومراجعتها من قبل المختصين',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // 3. Reason Selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    l10n?.reportReasonLabel ?? 'نوع المشكلة',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: reasons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = reasons[index];
                    final isSelected = _selectedReason == item.key;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedReason = item.key;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(item.icon, color: item.color, size: 19),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 4. Description Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.reportDescriptionLabel ?? 'تفاصيل إضافية (اختياري)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n?.reportDescriptionHint ??
                              'وضح تفاصيل الخطأ أو الملاحظة لمساعدة المدققين...',
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(14),
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
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 5. Submit Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded, size: 17),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n?.reportSubmitButton ?? 'إرسال البلاغ',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            l10n?.cancel ?? 'إلغاء',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportReasonItem {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _ReportReasonItem({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
