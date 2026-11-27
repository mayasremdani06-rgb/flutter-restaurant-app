// screens/welcome_page.dart
import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../helpers/notifiers.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild); //construire interface avec ce theme ecouter
  }

  @override //detruire la page et refiare ...
  void dispose() {
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.current();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.coffee_maker_outlined, size: 80, color: AppColors.accent),
                const SizedBox(height: 20),
                Text('BIENVENUE',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: c.text,
                        letterSpacing: 4)),
                const SizedBox(height: 10),
                Text(
                  "L'art du café et de la pâtisserie premium.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: c.text.withOpacity(0.6),
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 50),
                // ── Boutons discrets ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/about'),
                      icon: Icon(Icons.info_outline, color: AppColors.accent, size: 16),
                      label: Text('À propos',
                          style: TextStyle(color: AppColors.accent, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/preferences'),
                      icon: Icon(Icons.settings_outlined, color: AppColors.accent, size: 16),
                      label: Text('Préférences',
                          style: TextStyle(color: AppColors.accent, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ── Bouton principal ─────────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/menu'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2)
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('DÉCOUVRIR LE MENU',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1)),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}