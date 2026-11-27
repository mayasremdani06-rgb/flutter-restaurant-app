// screens/preferences_page.dart
// ─── Préférences utilisateur : thème, devise, tri ────────────────────────────
import 'package:flutter/material.dart';
import '../helpers/app_colors.dart';
import '../helpers/notifiers.dart';
import '../helpers/preferences_helper.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> { //exemple de pref
  bool _isDark = true;
  String _devise = 'DA';
  String _triPar = 'nom';

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild); // redessine la page si le thème change.
    _isDark = themeNotifier.value == ThemeMode.dark;
    _devise = currencyNotifier.value; //avoir etat sauvgarder sinon sans value je revient vers etat avant
    _triPar = sortNotifier.value;
  }

  @override
  void dispose() {  //supprmier theme
    themeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {}); // informer flutter et reconstruire page

  @override
  Widget build(BuildContext context) { //Récupère les couleurs actuelles selon le thème (clair ou sombre) — utilisées partout dans le build().
    final c = AppColors.current();
    _isDark = themeNotifier.value == ThemeMode.dark;
    _devise = currencyNotifier.value;
    _triPar = sortNotifier.value;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('PRÉFÉRENCES',
            style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 14)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── THÈME ──────────────────────────────────────────────────────────
          _buildSection(c, 'AFFICHAGE', [
            _buildSwitchTile(
              c,
              icon: _isDark ? Icons.dark_mode : Icons.light_mode,
              titre: 'Thème sombre',
              sous: _isDark ? 'Mode nuit activé' : 'Mode jour activé',
              valeur: _isDark,
              onChanged: (val) async {
                await PreferencesHelper.setDarkTheme(val);
                setState(() => _isDark = val);
              },
            ),
          ]),
          const SizedBox(height: 20),

          // ── DEVISE ──────────────────────────────────────────────────────────
          _buildSection(c, 'DEVISE', [
            _buildRadioGroup<String>(
              c,
              valeurSelectionnee: _devise,
              options: const {
                'DA': 'Dinar Algérien (DA)',
                'EUR': 'Euro (€)',
                'USD': 'Dollar US (\$)',
              },
              icones: const {
                'DA': Icons.money,
                'EUR': Icons.euro,
                'USD': Icons.attach_money,
              },
              onChanged: (val) async {
                await PreferencesHelper.setCurrency(val!);
                setState(() => _devise = val);
              },
            ),
          ]),
          const SizedBox(height: 20),

          // ── TRI ─────────────────────────────────────────────────────────────
          _buildSection(c, 'TRI DES PLATS', [
            _buildRadioGroup<String>(
              c,
              valeurSelectionnee: _triPar,
              options: const {
                'nom': 'Par nom (A → Z)',
                'prix': 'Par prix (croissant)',
              },
              icones: const {
                'nom': Icons.sort_by_alpha,
                'prix': Icons.trending_up,
              },
              onChanged: (val) async {
                await PreferencesHelper.setSortBy(val!);
                setState(() => _triPar = val);
              },
            ),
          ]),
          const SizedBox(height: 30),

          // ── Info devise ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Les taux appliqués sont indicatifs :\n1 DA ≈ 0.0068 € ≈ 0.0074 \$',
                    style: TextStyle(
                        color: c.text.withOpacity(0.65),
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers UI ────────────────────────────────────────────────────────────
  Widget _buildSection(AppColors c, String titre, List<Widget> enfants) { //est un helper qui crée une section stylisée avec un titre doré en haut et une carte arrondie contenant les widgets enfants — utilisé pour grouper visuellement les préférences.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(titre,
              style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withOpacity(0.15)),
          ),
          child: Column(children: enfants),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
      AppColors c, {
        required IconData icon,
        required String titre,
        required String sous,
        required bool valeur,
        required ValueChanged<bool> onChanged,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                    style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(sous,
                    style: TextStyle(
                        color: c.text.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: valeur,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup<T>(
      AppColors c, {
        required T valeurSelectionnee,
        required Map<T, String> options,
        required Map<T, IconData> icones,
        required ValueChanged<T?> onChanged,
      }) {
    final entries = options.entries.toList();
    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isLast = i == entries.length - 1;
        final isSelected = entry.key == valeurSelectionnee;
        return Column(
          children: [
            InkWell(
              onTap: () => onChanged(entry.key),
              borderRadius: isLast
                  ? const BorderRadius.vertical(bottom: Radius.circular(16))
                  : BorderRadius.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(icones[entry.key], color: AppColors.accent, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(entry.value,
                          style: TextStyle(
                              color: c.text,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14)),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(
                  height: 1,
                  color: AppColors.accent.withOpacity(0.1),
                  indent: 16,
                  endIndent: 16),
          ],
        );
      }),
    );
  }
}