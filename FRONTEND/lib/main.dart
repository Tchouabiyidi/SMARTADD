import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/advertiser/advertiser_main_screen.dart';
import 'screens/owner/owner_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartBillboardApp());
}

class SmartBillboardApp extends StatelessWidget {
  const SmartBillboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'SMARTADD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthRouter(),
      ),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Splash screen while reading stored session
        if (authProvider.isInitializing) {
          return const Scaffold(
            backgroundColor: AppTheme.lightBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'SMARTADD',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Unauthenticated -> Show Login Screen
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Role-Based Navigation
        final userRole = authProvider.userRole;
        switch (userRole) {
          case UserRole.advertiser:
            return const AdvertiserMainScreen();
          case UserRole.billboardOwner:
            return const OwnerMainScreen();
          case UserRole.admin:
            return const AdminMainScreen();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}
