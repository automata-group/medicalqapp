import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/ai_feedback_provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AIFeedbackScreen extends StatefulWidget {
  const AIFeedbackScreen({super.key});

  @override
  State<AIFeedbackScreen> createState() => _AIFeedbackScreenState();
}

class _AIFeedbackScreenState extends State<AIFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIFeedbackProvider>().loadLatestFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiCoach,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AIFeedbackProvider>().generateNewFeedback(),
            tooltip: l10n.refreshAnalysis,
          ),
        ],
      ),
      body: Consumer<AIFeedbackProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.latestFeedback == null) {
            final isNotEnough = provider.error!.contains('1') || provider.error!.contains('أخطاء') || provider.error!.contains('خطأ');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isNotEnough ? Icons.quiz_outlined : Icons.error_outline,
                    size: 64,
                    color: isNotEnough ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isNotEnough
                        ? 'تحتاج إلى خطأ واحد على الأقل\nلإنشاء تحليل ذكي'
                        : provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isNotEnough ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isNotEnough) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'أجب على بعض الأسئلة أولاً\nوسيقوم النظام بتحليل أخطائك تلقائياً',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                  if (!isNotEnough) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.generateNewFeedback(),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ],
              ),
            );
          }

          final feedback = provider.latestFeedback;

          if (feedback == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    Text(
                      l10n.letAiAnalyze,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.aiAnalyzeDescription,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => provider.generateNewFeedback(),
                        child: Text(l10n.startAnalysis),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.analysisValidPeriod,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.smartPerformanceAnalysis,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.createdAt(
                      '${feedback.createdAt.day}/${feedback.createdAt.month}/${feedback.createdAt.year}'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Divider(height: 32),
                MarkdownBody(
                  data: feedback.content,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                    h1: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    h2: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    h3: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    listBullet: const TextStyle(fontSize: 16, color: AppColors.primary),
                    tableBorder: TableBorder.all(color: Colors.grey.shade300, width: 1),
                    tableHead: const TextStyle(fontWeight: FontWeight.bold),
                    tableCellsPadding: const EdgeInsets.all(12),
                    blockquote: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    blockquoteDecoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
