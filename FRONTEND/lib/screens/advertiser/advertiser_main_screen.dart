import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/advertiser_provider.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'my_advertisements_screen.dart';
import 'my_bookings_screen.dart';
import 'qr_billboard_screen.dart';
import 'tabs/advertiser_dashboard_tab.dart';
import 'tabs/billboard_list_tab.dart';
import 'tabs/billboard_map_tab.dart';

class AdvertiserMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const AdvertiserMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AdvertiserMainScreen> createState() => _AdvertiserMainScreenState();
}

class _AdvertiserMainScreenState extends State<AdvertiserMainScreen> {
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
    return ChangeNotifierProvider<AdvertiserProvider>(
      create: (_) => AdvertiserProvider(),
      child: Builder(
        builder: (context) {
          final List<Widget> tabs = [
            AdvertiserDashboardTab(onNavigateTab: _onTabTapped),
            const BillboardListTab(),
            const BillboardMapTab(),
            const MyAdvertisementsScreen(),
            const MyBookingsScreen(),
            const ProfileScreen(),
          ];

          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: tabs,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QRBillboardScreen()),
                );
              },
              backgroundColor: AppTheme.primaryBlue,
              tooltip: 'Scan Billboard QR',
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded, color: AppTheme.primaryBlue),
                  label: 'Map',
                ),
                NavigationDestination(
                  icon: Icon(Icons.video_library_outlined),
                  selectedIcon: Icon(Icons.video_library_rounded, color: AppTheme.primaryBlue),
                  label: 'My Ads',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryBlue),
                  label: 'Bookings',
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
