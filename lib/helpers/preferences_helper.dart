// helpers/preferences_helper.dart
// ─── Persistance des préférences utilisateur (SharedPreferences) ─────────────
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'notifiers.dart';

class PreferencesHelper {
  // ── Clés ──────────────────────────────────────────────────────────────────
  static const _keyDarkTheme = 'darkTheme';
  static const _keyCurrency = 'currency';
  static const _keySortBy = 'sortBy';

  // ── Taux de conversion (1 DZD ≈) ─────────────────────────────────────────
  static const double _rateEUR = 0.0068;
  static const double _rateUSD = 0.0074;

  // ─────────────────────────── CHARGEMENT INITIAL ───────────────────────────
  /// Charge toutes les préférences et met à jour les notifiers globaux.
  /// À appeler au démarrage de l'application (avant runApp).
  static Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_keyDarkTheme) ?? true;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    currencyNotifier.value = prefs.getString(_keyCurrency) ?? 'DA';
    sortNotifier.value = prefs.getString(_keySortBy) ?? 'nom';
  }

  // ─────────────────────────── THÈME ────────────────────────────────────────
  static Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkTheme, value);
    themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  // ─────────────────────────── DEVISE ───────────────────────────────────────
  static Future<void> setCurrency(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, value);
    currencyNotifier.value = value;
  }

  // ─────────────────────────── TRI ──────────────────────────────────────────
  static Future<void> setSortBy(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySortBy, value);
    sortNotifier.value = value;
  }

  // ─────────────────────────── FORMATAGE PRIX ───────────────────────────────
  static double convertirPrix(double prixDA, String devise) {
    switch (devise) {
      case 'EUR':
        return prixDA * _rateEUR;
      case 'USD':
        return prixDA * _rateUSD;
      default:
        return prixDA;
    }
  }

  static String formaterPrix(double prixDA, String devise) {
    final valeur = convertirPrix(prixDA, devise);
    switch (devise) {
      case 'EUR':
        return '${valeur.toStringAsFixed(2)} €';
      case 'USD':
        return '\$${valeur.toStringAsFixed(2)}';
      default:
        return '${prixDA.toStringAsFixed(0)} DA';
    }
  }
}