import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../../core/utils/toast_utils.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: isDesktop ? const Text('Content Management') : null,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Specialties', icon: Icon(Icons.school)),
            Tab(text: 'Subtopics', icon: Icon(Icons.topic)),
            Tab(text: 'Questions', icon: Icon(Icons.question_answer)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSpecialtiesTab(),
          _buildSubtopicsTab(),
          _buildQuestionsTab(),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesTab() {
    return const Center(
        child: Text('Specialties Management: Add, Edit, Delete Specialties'));
  }

  Widget _buildSubtopicsTab() {
    return const Center(
        child:
            Text('Subtopics Management: Organize topics within specialties'));
  }

  Widget _buildQuestionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Question Bank',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _handleBulkUpload(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Bulk Upload (CSV/Excel)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10),
                ],
              ),
              child: const Center(
                child:
                    Text('Question reordering and editing list will go here.'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBulkUpload(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        if (!context.mounted) return;
        ToastUtils.showInfo(context, 'Uploading file... Please wait.');

        final success = await adminProvider.bulkUploadQuestions(filePath);

        if (!context.mounted) return;
        if (success) {
          ToastUtils.showSuccess(context, 'Questions imported successfully!');
        } else {
          ToastUtils.showError(context, 'Failed to import questions. Check logs.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Error: $e');
      }
    }
  }
}
