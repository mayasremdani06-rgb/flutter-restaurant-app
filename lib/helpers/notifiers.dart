// helpers/notifiers.dart
// ─── Notifiers globaux partagés entre toutes les pages ───────────────────────
import 'package:flutter/material.dart';

/// Thème actif (sombre / clair)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

/// Devise d'affichage : 'DA' | 'EUR' | 'USD'
final ValueNotifier<String> currencyNotifier = ValueNotifier('DA');

/// Tri des plats : 'nom' | 'prix'
final ValueNotifier<String> sortNotifier = ValueNotifier('nom');