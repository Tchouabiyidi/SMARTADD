import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/owner_provider.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'tabs/add_billboard_screen.dart';
import 'tabs/my_billboards_tab.dart';
import 'tabs/owner_bookings_tab.dart';
import 'tabs/owner_dashboard_tab.dart';
import 'tabs/owner_schedule_tab.dart';

class OwnerMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const OwnerMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
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
    return ChangeNotifierProvider<OwnerProvider>(
      create: (_) => OwnerProvider(),
      child: Builder(
        builder: (context) {
          final List<Widget> tabs = [
            OwnerDashboardTab(onNavigateTab: _onTabTapped),
            MyBillboardsTab(onNavigateTab: _onTabTapped),
            AddBillboardScreen(onCreated: () => _onTabTapped(1)),
            const OwnerBookingsTab(),
            const OwnerScheduleTab(),
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
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_carousel_outlined),
                  selectedIcon: Icon(Icons.view_carousel_rounded, color: AppTheme.primaryBlue),
                  label: 'Billboards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline_rounded),
                  selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.primaryBlue),
                  label: 'Add New',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryBlue),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue),
                  label: 'Schedule',
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
