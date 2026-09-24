import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';

class AdminDashboardTab extends StatelessWidget {
  final Function(int) onNavigateTab;

  const AdminDashboardTab({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final currencyFormatter = NumberFormat.currency(symbol: 'FCFA ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primaryLight,
                      child: Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primaryBlue, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.currentUser?.fullName ?? 'System Administrator',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authProvider.currentUser?.email ?? 'admin@smartadd.com',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // System Statistics 2x4 Grid
              const Text('System Performance & Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Users',
                      value: '${adminProvider.totalUsers}',
                      icon: Icons.people_outline_rounded,
                      color: AppTheme.primaryBlue,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Advertisers',
                      value: '${adminProvider.advertisersCount}',
                      icon: Icons.person_search_rounded,
                      color: Colors.purple,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Billboard Owners',
                      value: '${adminProvider.ownersCount}',
                      icon: Icons.store_rounded,
                      color: Colors.teal,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Total Billboards',
                      value: '${adminProvider.totalBillboards}',
                      icon: Icons.view_carousel_rounded,
                      color: AppTheme.primaryDark,
                      onTap: () => onNavigateTab(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Pending Ads',
                      value: '${adminProvider.pendingAdsCount}',
                      icon: Icons.rate_review_outlined,
                      color: Colors.orange,
                      onTap: () => onNavigateTab(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Active Bookings',
                      value: '${adminProvider.activeBookingsCount}',
                      icon: Icons.bookmark_added_rounded,
                      color: AppTheme.successGreen,
                      onTap: () => onNavigateTab(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Platform Revenue Stats Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_rounded, color: Colors.white70, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Platform Revenue Generated',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currencyFormatter.format(adminProvider.totalRevenue),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${adminProvider.completedBookingsCount} completed campaign playbacks',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Action Bar
              const Text('Management Shortcuts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildShortcutButton(
                      label: 'User Directory',
                      icon: Icons.manage_accounts_rounded,
                      onTap: () => onNavigateTab(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildShortcutButton(
                      label: 'Verify Ads',
                      icon: Icons.rule_rounded,
                      onTap: () => onNavigateTab(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildShortcutButton(
                      label: 'Live Monitor',
                      icon: Icons.monitor_heart_rounded,
                      onTap: () => onNavigateTab(5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
