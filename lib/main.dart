// main.dart
import 'package:flutter/material.dart';
import 'models/plat.dart';
import 'helpers/notifiers.dart';
import 'helpers/preferences_helper.dart';
import 'screens/welcome_page.dart';
import 'screens/menu_page.dart';
import 'screens/detail_plat_page.dart';
import 'screens/cart_page.dart';
import 'screens/about_page.dart';
import 'screens/admin_page.dart';
import 'screens/preferences_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ── Chargement des préférences avant l'affichage de l'UI ──────────────────
  await PreferencesHelper.charger();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // ── Thème sombre ────────────────────────────────────────────────────────────
  static final ThemeData _themeSombre = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF14100E),
    fontFamily: 'Serif',
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFFC6A165),
      surface: const Color(0xFF221A16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF14100E),
      elevation: 0,
    ),
  );

  // ── Thème clair ─────────────────────────────────────────────────────────────
  static final ThemeData _themeClair = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5EFE6),
    fontFamily: 'Serif',
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFC6A165),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5EFE6),
      elevation: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Café Premium',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: _themeClair,
        darkTheme: _themeSombre,

        // ── Routes simples ────────────────────────────────────────────────────
        initialRoute: '/',
        routes: {
          '/':            (_) => const WelcomePage(),
          '/menu':        (_) => const MenuPage(),
          '/about':       (_) => const AboutPage(),
          '/admin':       (_) => const AdminPage(),
          '/preferences': (_) => const PreferencesPage(),
        },

        // ── Routes avec arguments ─────────────────────────────────────────────
        onGenerateRoute: (settings) {
          if (settings.name == '/detail') {
            final plat = settings.arguments as Plat;
            return MaterialPageRoute(
              builder: (_) => DetailPlatPage(plat: plat),
            );
          }
          if (settings.name == '/cart') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => CartPage(
                cartItems: args['cartItems'] as List<Plat>,
                onQuantityChanged:
                args['onQuantityChanged'] as Function(Plat, int),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}