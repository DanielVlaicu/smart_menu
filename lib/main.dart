import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_menu/screens/client/menu_screen2.dart';
import 'package:smart_menu/screens/manager/account_settings_screen.dart';
import 'package:smart_menu/screens/manager/manager_menu_screen.dart';
import 'package:smart_menu/screens/manager/menu_settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/manager/dashboard_screen.dart';

import 'screens/manager/edit_item_screen.dart';
import 'screens/manager/analytics_screen.dart';
import 'screens/manager/settings_screen.dart';
import 'screens/client/menu_screen.dart';
import 'screens/manager/qr_generator_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('‼️ Firebase init error: $e');
  }

  final params = Uri.base.queryParameters;
  final isClient = params['client'] == 'true';
  final uid = params['uid'];

  runApp(RestaurantMenuApp(isClient: isClient, clientUid: uid));
}

class RestaurantMenuApp extends StatelessWidget {

  final bool isClient;
  final String? clientUid;

  const RestaurantMenuApp({super.key, required this.isClient, this.clientUid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final params = Uri.base.queryParameters;
        final isClient = params['client'] == 'true';
        final uid = params['uid'];
        final user = FirebaseAuth.instance.currentUser;

        if (isClient && uid != null) {
          return MaterialPageRoute(
              builder: (_) => ClientMenuScreen(uid: uid));
        }

        if (user == null) {
          return MaterialPageRoute(
              builder: (_) => const LoginScreen());
        } else {
          return MaterialPageRoute(
              builder: (_) => DashboardScreen());
        }
      },
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/manager_menu_screen': (context) =>ManagerMenuScreen(),
        '/edit_item': (context) => EditItemScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/account_settings': (context) => const AccountSettingsScreen(),
        '/menu_settings': (context) => const MenuSettingsScreen(),
        '/menu2': (context) => const ClientMenuScreen2(), /// meniu cu afisare dif mockup
        '/qr': (context) {
          final uid = ModalRoute.of(context)!.settings.arguments as String;
          return QRGeneratorScreen(uid: uid);
        },
        '/menu': (context) {
          final uid = ModalRoute.of(context)!.settings.arguments as String;
          return ClientMenuScreen(uid: uid);
        },
      },
    );
  }
}

