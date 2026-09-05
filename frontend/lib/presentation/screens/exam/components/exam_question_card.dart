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

  @override
  Widget build(BuildContext context) {
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
          if (imageUrl != null && imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showFullScreenImage(context, imageUrl!),
              child: Hero(
                tag: 'question_image_$imageUrl',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox
                        .shrink(), // Silently hide on network failure
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap image to zoom',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
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
                  tag: 'question_image_$url',
                  child: Image.network(
                    url,
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
