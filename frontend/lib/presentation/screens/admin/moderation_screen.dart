import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../../core/utils/toast_utils.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? AppBar(
              title: const Text('Moderation & Reports'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildReportsTable(),
          ),
          Expanded(
            flex: 1,
            child: _buildNotificationComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTable() {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reports.isEmpty) {
          return const Center(child: Text('No reports to display.'));
        }

        return Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
              columns: const [
                DataColumn(label: Text('Question ID')),
                DataColumn(label: Text('User ID')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Details')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: provider.reports.map<DataRow>((report) {
                final id = (report['id'] ?? report['_id']).toString();
                final status = report['status'] ?? 'pending';

                return DataRow(
                  cells: [
                    DataCell(Text(report['questionId']?.toString() ?? 'N/A')),
                    DataCell(Text(report['userId']?.toString() ?? 'anon')),
                    DataCell(Text(report['reason'] ?? '')),
                    DataCell(SizedBox(
                        width: 150,
                        child: Text(report['details'] ?? '',
                            overflow: TextOverflow.ellipsis))),
                    DataCell(
                      Chip(
                        label: Text(status),
                        backgroundColor: status == 'resolved'
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                            color: status == 'resolved'
                                ? Colors.green
                                : Colors.orange),
                      ),
                    ),
                    DataCell(
                      status == 'pending'
                          ? TextButton(
                              onPressed: () async {
                                final success = await provider
                                    .updateReportStatus(id, 'resolved');
                                if (success && context.mounted) {
                                  ToastUtils.showSuccess(context, 'Report resolved');
                                }
                              },
                              child: const Text('Mark Resolved',
                                  style: TextStyle(color: AppColors.primary)),
                            )
                          : const Text('Done',
                              style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Widget _buildNotificationComposer() {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Broadcast Notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Message Body', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_titleController.text.isEmpty ||
                    _bodyController.text.isEmpty) {
                  ToastUtils.showError(context, 'Please enter Title and Body');
                  return;
                }
                _showPreviewDialog();
              },
              icon: const Icon(Icons.send),
              label: const Text('Preview & Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Notification Preview'),
              content: Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Dr. Hekma',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const Spacer(),
                        Text('Now',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_titleController.text,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_bodyController.text),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ToastUtils.showInfo(context, 'Firebase Cloud Messaging required to send.');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  child: const Text('Broadcast to All'),
                )
              ],
            ));
  }
}
