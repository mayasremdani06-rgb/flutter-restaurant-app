// screens/menu_page.dart
// ─── Menu : chargement SQLite, devise, tri, gestion d'erreurs ────────────────
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/plat.dart';
import '../widgets/plat_card_widget.dart';
import '../helpers/database_helper.dart';
import '../helpers/preferences_helper.dart';
import '../helpers/app_colors.dart';
import '../helpers/notifiers.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _categorieActive = 'Coffee';
  List<Plat> _plats = [];
  bool _chargement = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    themeNotifier.addListener(_rebuild);  //les changement preference theme divise..
    currencyNotifier.addListener(_rebuild);
    sortNotifier.addListener(_appliquerTri);
    _chargerTout(); //Lance le chargement initial des données (plats, catégories...) depuis la BD.
  }

  @override
  void dispose() {  //Nettoyage exact de tout ce qui a été ouvert dans initState() — appelé quand la page est détruite.
    themeNotifier.removeListener(_rebuild);
    currencyNotifier.removeListener(_rebuild);
    sortNotifier.removeListener(_appliquerTri);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }//_rebuild() redessine la page via setState() uniquement si le widget existe encore (mounted), pour éviter un crash.

  // ─── Chargement DB + panier ──────────────────────────────────────────────
  Future<void> _chargerTout() async {
    setState(() { _chargement = true; _erreur = null; });
    try {
      final plats = await DatabaseHelper.getPlats();
      await _restaurerPanier(plats);
      setState(() {
        _plats = plats;
        _appliquerTriListe(_plats);
        _chargement = false;
      });
    } catch (e) {
      setState(() {
        _erreur = 'Impossible de charger le menu.\n${e.toString()}';
        _chargement = false;
      });
    }
  }

  // ─── Persistance du panier ────────────────────────────────────────────────
  Future<void> _restaurerPanier(List<Plat> plats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('panier');
      if (data != null) {
        final Map<String, dynamic> panier = jsonDecode(data);
        for (var p in plats) {
          if (panier.containsKey(p.nom)) {
            p.quantite = panier[p.nom] as int;
            p.isSelected = p.quantite > 0;
          }
        }
      }
    } catch (_) {
      // Panier corrompu → on ignore silencieusement
    }
  }

  Future<void> _sauvegarderPanier() async {  //Sauvegarde le panier localement sur l'appareil pour le retrouver même après fermeture de l'app.
    try {
      final prefs = await SharedPreferences.getInstance();
      final panier = { for (var p in _plats) if (p.quantite > 0) p.nom: p.quantite };
      await prefs.setString('panier', jsonEncode(panier));
    } catch (_) {
      _afficherErreur('Impossible de sauvegarder le panier.');
    }
  }

  // ─── Tri ──────────────────────────────────────────────────────────────────
  void _appliquerTri() { if (mounted) setState(() => _appliquerTriListe(_plats)); } //cretere de tri choix

  void _appliquerTriListe(List<Plat> liste) {
    if (sortNotifier.value == 'prix') {
      liste.sort((a, b) => a.prix.compareTo(b.prix)); //par prix
    } else {
      liste.sort((a, b) => a.nom.compareTo(b.nom)); //par nom
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void _ouvrirDetail(Plat plat) async { //Ouvre la page détail d'un plat et récupère le résultat (quantité choisie) quand l'utilisateur revient.
    final result = await Navigator.pushNamed(context, '/detail', arguments: plat);
    if (result != null && result is Map) {
      setState(() {
        final Plat retour = result['plat'] as Plat;
        final int qte = result['quantite'] as int;
        final idx = _plats.indexWhere((p) => p.nom == retour.nom);
        if (idx != -1) { //j'ai un plat
          _plats[idx].quantite = qte;
          _plats[idx].isSelected = qte > 0; //cas de plat selectionner
        }
      });
      await _sauvegarderPanier(); //sharepreference function
    }
  }

  void _ouvrirPanier() { //pour naviger entre screens et share parametre
    Navigator.pushNamed(context, '/cart', arguments: {//passer au pannier
      'cartItems': _plats.where((p) => p.quantite > 0).toList(), //select plat ou quantite est non nul
      'onQuantityChanged': (Plat plat, int nouvelleQte) {
        setState(() {
          plat.quantite = nouvelleQte;
          plat.isSelected = nouvelleQte > 0;
        });
        _sauvegarderPanier();//share prefernce
      },
    }).then((_) => setState(() {}));
  }

  void _afficherErreur(String msg) { //cas erreurs ouvrture panier en rouge
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    });
  }

  // ─── Totaux ───────────────────────────────────────────────────────────────
  double get _totalDA => _plats.fold(0, (s, p) => s + p.prix * p.quantite);

  String get _totalFormate =>
      PreferencesHelper.formaterPrix(_totalDA, currencyNotifier.value);

  // ─── BUILD de interface menu ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = AppColors.current();
    final filtres = _plats.where((p) => p.categorie == _categorieActive).toList();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('NOTRE CARTE',
            style: TextStyle(
                color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings_outlined, color: AppColors.accent),
            onPressed: () => Navigator.pushNamed(context, '/admin')
                .then((_) => _chargerTout()),
            tooltip: 'Administration',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: AppColors.accent),
            onPressed: () => Navigator.pushNamed(context, '/about'),
            tooltip: 'À propos',
          ),
        ],
      ),
      body: _chargement
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _erreur != null
          ? _buildErreur(c)
          : Column(
        children: [
          // ── Filtres catégorie ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _buildFilterButton(c, 'Coffee')),
                const SizedBox(width: 15),
                Expanded(child: _buildFilterButton(c, 'Cake')),
              ],
            ),
          ),
          // ── Tri info ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.sort, color: AppColors.accent.withOpacity(0.6), size: 14),
                const SizedBox(width: 6),
                Text(
                  sortNotifier.value == 'prix' ? 'Trié par prix' : 'Trié par nom',
                  style: TextStyle(
                      color: AppColors.accent.withOpacity(0.6),
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // ── Liste ───────────────────────────────────────────
          Expanded(
            child: filtres.isEmpty
                ? Center(
              child: Text('Aucun plat dans cette catégorie.',
                  style: TextStyle(
                      color: c.text.withOpacity(0.5), fontSize: 15)),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtres.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => PlatCardWidget(
                plat: filtres[i],
                accentColor: AppColors.accent,
                bgColor: c.card,
                textColor: c.text,
                devise: currencyNotifier.value,
                onQuantityChanged: (q) {
                  setState(() {
                    filtres[i].quantite = q;
                    filtres[i].isSelected = q > 0;
                  });
                  _sauvegarderPanier();
                },
                onImageTap: () => _ouvrirDetail(filtres[i]),
              ),
            ),
          ),
        ],
      ),
      // ── Barre panier ──────────────────────────────────────────────────────
      bottomNavigationBar: _totalDA > 0
          ? GestureDetector(
        onTap: _ouvrirPanier,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            border: Border(
                top: BorderSide(color: AppColors.accent.withOpacity(0.3))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.shopping_bag_outlined, color: AppColors.accent),
                const SizedBox(width: 10),
                Text('Voir Panier',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: c.text)),
              ]),
              Text(_totalFormate,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent)),
            ],
          ),
        ),
      )
          : null,
    );
  }

  // ─── Widget : message d'erreur ────────────────────────────────────────────
  Widget _buildErreur(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            Text('Données indisponibles',
                style: TextStyle(
                    color: c.text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_erreur!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: c.text.withOpacity(0.6), fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh, color: Colors.black),
              label: const Text('Réessayer',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: _chargerTout,
            ),
          ],
        ),
      ),
    );
  }
//button de choix
  Widget _buildFilterButton(AppColors c, String titre) {
    final isActive = _categorieActive == titre;
    return GestureDetector(
      onTap: () => setState(() => _categorieActive = titre),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? Colors.transparent : AppColors.accent.withOpacity(0.5)),
        ),
        child: Text(
          titre.toUpperCase(),
          style: TextStyle(
            color: isActive ? Colors.black : c.text,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}