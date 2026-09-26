import 'package:flutter/material.dart';

class ExamQuestionCard extends StatelessWidget {
  final String specialtyName;
  final String questionText;
  final String? imageUrl;

  const ExamQuestionCard({
    super.key,
    required this.specialtyName,
    required this.questionText,
    this.imageUrl,
  });

  String _resolveUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return 'https://healthlicenseprep.com$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedImageUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? _resolveUrl(imageUrl!)
        : null;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Specialty Badge + Question Type Indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    const SizedBox(width: 6),
                    Text(
                      specialtyName.isNotEmpty ? specialtyName : 'General Medical',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Single Best Answer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Question Text
          Text(
            questionText,
            style: TextStyle(
              fontSize: 18, // text-lg high legibility
              height: 1.6, // leading-relaxed
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
              fontFamily: 'IBM Plex Sans Arabic',
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          ),

          // Clinical Image (If available)
          if (resolvedImageUrl != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showFullScreenImage(context, resolvedImageUrl),
              child: Hero(
                tag: 'question_image_$resolvedImageUrl',
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(
                    maxHeight: 240,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    resolvedImageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_in_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'انقر لتكبير الصورة • Tap image to zoom',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    final resolvedUrl = _resolveUrl(url);

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'question_image_$resolvedUrl',
                  child: Image.network(
                    resolvedUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
