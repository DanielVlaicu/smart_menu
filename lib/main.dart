import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/manager/dashboard_screen.dart';
import 'screens/manager/create_menu_screen.dart';
import 'screens/manager/edit_item_screen.dart';
import 'screens/manager/analytics_screen.dart';
import 'screens/manager/settings_screen.dart';
import 'screens/client/menu_screen.dart';
import 'screens/client/product_detail_screen.dart';

void main() {
  runApp(RestaurantMenuApp());
}

class RestaurantMenuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/menu',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/create_menu': (context) => CreateMenuScreen(),
        '/edit_item': (context) => EditItemScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/menu': (context) => ClientMenuScreen(),

      },
    );
  }
}
