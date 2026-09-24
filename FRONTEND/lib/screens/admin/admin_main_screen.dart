import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'tabs/admin_ad_verification_tab.dart';
import 'tabs/admin_billboard_management_tab.dart';
import 'tabs/admin_billboard_monitoring_tab.dart';
import 'tabs/admin_booking_management_tab.dart';
import 'tabs/admin_dashboard_tab.dart';
import 'tabs/admin_user_management_tab.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdminMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminProvider>(
      create: (_) => AdminProvider(),
      child: Builder(
        builder: (context) {
          final List<Widget> tabs = [
            AdminDashboardTab(onNavigateTab: _onTabTapped),
            const AdminUserManagementTab(),
            const AdminBillboardManagementTab(),
            const AdminAdVerificationTab(),
            const AdminBookingManagementTab(),
            const AdminBillboardMonitoringTab(),
            const ProfileScreen(),
          ];

          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTapped,
              backgroundColor: Colors.white,
              elevation: 8,
              indicatorColor: AppTheme.primaryLight,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primaryBlue),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded, color: AppTheme.primaryBlue),
                  label: 'Users',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_carousel_outlined),
                  selectedIcon: Icon(Icons.view_carousel_rounded, color: AppTheme.primaryBlue),
                  label: 'Billboards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.rate_review_outlined),
                  selectedIcon: Icon(Icons.rate_review_rounded, color: AppTheme.primaryBlue),
                  label: 'Ad Verify',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryBlue),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.monitor_heart_outlined),
                  selectedIcon: Icon(Icons.monitor_heart_rounded, color: AppTheme.primaryBlue),
                  label: 'Monitoring',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
