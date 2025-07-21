import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_menu/screens/manager/account_settings_screen.dart';
import 'package:smart_menu/screens/manager/menu_settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/manager/dashboard_screen.dart';
import 'screens/manager/create_menu_screen.dart';
import 'screens/manager/edit_item_screen.dart';
import 'screens/manager/analytics_screen.dart';
import 'screens/manager/settings_screen.dart';
import 'screens/client/menu_screen.dart';
import 'screens/manager/qr_generator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RestaurantMenuApp());
}

class RestaurantMenuApp extends StatelessWidget {
  const RestaurantMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/' : '/dashboard',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/create_menu': (context) => CreateMenuScreen(),
        '/edit_item': (context) => EditItemScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/account_settings': (context) => const AccountSettingsScreen(),
        '/menu_settings': (context) => const MenuSettingsScreen(),
        '/menu': (context) => const ClientMenuScreen(),
        '/menu2': (context) => const ClientMenuScreen(),
        '/qr': (context) => QRGeneratorScreen(),
      },
    );
  }
}