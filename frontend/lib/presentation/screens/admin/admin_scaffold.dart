import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'content_management_screen.dart';
import 'users_revenue_screen.dart';
import 'promos_referrals_screen.dart';
import 'moderation_screen.dart';
import 'activity_logs_screen.dart';

class AdminScaffold extends StatefulWidget {
  const AdminScaffold({super.key});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ContentManagementScreen(),
    const UsersRevenueScreen(),
    const PromosReferralsScreen(),
    const ModerationScreen(),
    const ActivityLogsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (MediaQuery.of(context).size.width < 800) {
      Navigator.pop(context); // Close drawer on mobile after selection
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.user == null || authProvider.user!.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: const Center(
          child: Text(
              'Unauthorized access. This area is for administrators only.',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    final drawer = Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(0, Icons.library_books, 'Content Management'),
          _buildDrawerItem(1, Icons.people, 'Users & Revenue'),
          _buildDrawerItem(2, Icons.local_offer, 'Promos & Referrals'),
          _buildDrawerItem(3, Icons.gavel, 'Moderation'),
          _buildDrawerItem(4, Icons.history, 'Activity Logs'),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Exit Admin Mode',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
      drawer: isDesktop ? null : drawer,
      body: Row(
        children: [
          if (isDesktop) drawer,
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey.shade600,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _onItemTapped(index),
      ),
    );
  }
}
