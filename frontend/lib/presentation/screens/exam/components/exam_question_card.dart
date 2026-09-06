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
    final resolvedImageUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? _resolveUrl(imageUrl!)
        : null;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 20, // text-xl
              height: 1.6, // leading-relaxed
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // text-slate-800
              fontFamily: 'IBM Plex Sans Arabic', // Specific font from design
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
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Icon(Icons.zoom_in_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'انقر لتكبير الصورة • Tap image to zoom',
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
