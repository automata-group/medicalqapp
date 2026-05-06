import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../../core/utils/toast_utils.dart';

class UsersRevenueScreen extends StatefulWidget {
  const UsersRevenueScreen({super.key});

  @override
  State<UsersRevenueScreen> createState() => _UsersRevenueScreenState();
}

class _UsersRevenueScreenState extends State<UsersRevenueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.fetchUsers();
      adminProvider.fetchRevenueStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? AppBar(
              title: const Text('Users & Revenue'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            )
          : null,
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  ElevatedButton(
                    onPressed: () => provider.fetchUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRevenueCards(provider.revenueStats),
                const SizedBox(height: 24),
                const Text(
                  'User Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildUsersTable(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRevenueCards(Map<String, dynamic> stats) {
    // Expected stub: { totalRevenue: 25000, thisMonth: 4500, today: 1299 }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Revenue', '${stats['totalRevenue'] ?? 0} SAR',
            Icons.attach_money, Colors.green),
        _buildStatCard('This Month', '${stats['thisMonth'] ?? 0} SAR',
            Icons.auto_graph, Colors.blue),
        _buildStatCard(
            'Today', '${stats['today'] ?? 0} SAR', Icons.today, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(BuildContext context, AdminProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: provider.users.map<DataRow>((user) {
            final isPremium = user['isPremium'] ?? false;
            final userId = (user['id'] ?? user['_id']).toString();

            return DataRow(
              cells: [
                DataCell(Text(user['fullName'] ?? user['name'] ?? 'N/A')),
                DataCell(Text(user['email'] ?? 'N/A')),
                DataCell(Text(user['role'] ?? 'user')),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPremium ? 'PRO' : 'FREE',
                      style: TextStyle(
                        color: isPremium ? Colors.green : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  TextButton.icon(
                    onPressed: () {
                      _showOverrideDialog(
                          context, provider, userId, user['email'], isPremium);
                    },
                    icon: Icon(
                        isPremium
                            ? Icons.remove_circle_outline
                            : Icons.star_outline,
                        size: 16),
                    label: Text(isPremium ? 'Revoke PRO' : 'Grant PRO'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isPremium ? Colors.red : AppColors.primary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOverrideDialog(BuildContext context, AdminProvider provider,
      String userId, String email, bool isPremium) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPremium ? 'Revoke PRO Access' : 'Grant PRO Access'),
        content: Text(
            'Are you sure you want to ${isPremium ? 'revoke PRO access from' : 'grant PRO access to'} $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await provider.toggleProStatus(userId, !isPremium);
              if (context.mounted) {
                if (success) {
                  ToastUtils.showSuccess(context, 'Status updated successfully');
                } else {
                  ToastUtils.showError(context, 'Failed to update status');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? Colors.red : AppColors.primary,
            ),
            child: Text(isPremium ? 'Revoke' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}
