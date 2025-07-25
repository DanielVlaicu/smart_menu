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
  print('📦 URL detectat: ${Uri.base}');
  print('🔍 client: ${Uri.base.queryParameters['client']}');
  print('🔍 uid: ${Uri.base.queryParameters['uid']}');
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
      theme: ThemeData(primarySwatch: Colors.blue),

      // Eliminăm `initialRoute` și `routes`, păstrăm doar `onGenerateRoute`
      onGenerateRoute: (settings) {
        final params = Uri.base.queryParameters;
        final isClient = params['client'] == 'true';
        final uid = params['uid'];

        // 👉 Dacă e acces direct din QR — intră în meniu public
        if (isClient && uid != null) {
          print('🟢 Client QR link detectat, uid = $uid');
          return MaterialPageRoute(builder: (_) => ClientMenuScreen(uid: uid));
        }

        // 👉 Rutează în funcție de numele rutei
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return snapshot.hasData ? DashboardScreen() : const LoginScreen();
                },
              ),
            );
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => DashboardScreen());
          case '/manager_menu_screen':
            return MaterialPageRoute(builder: (_) => ManagerMenuScreen());
          case '/edit_item':
            return MaterialPageRoute(builder: (_) => EditItemScreen());
          case '/analytics':
            return MaterialPageRoute(builder: (_) => AnalyticsScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => SettingsScreen());
          case '/account_settings':
            return MaterialPageRoute(builder: (_) => const AccountSettingsScreen());
          case '/menu_settings':
            return MaterialPageRoute(builder: (_) => const MenuSettingsScreen());
          case '/menu2':
            return MaterialPageRoute(builder: (_) => const ClientMenuScreen2());
          case '/qr':
            final uid = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => QRGeneratorScreen(uid: uid));
          case '/menu':
            final uid = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => ClientMenuScreen(uid: uid));
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - Pagina nu există')),
              ),
            );
        }
      },
    );
  }
}