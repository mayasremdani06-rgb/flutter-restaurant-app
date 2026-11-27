// screens/admin_page.dart
// ─── Écran d'administration : ajouter / supprimer des plats ──────────────────
import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../helpers/app_colors.dart';
import '../helpers/notifiers.dart';
import '../models/plat.dart';

class AdminPage extends StatefulWidget { //on a des donner a ajouter
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState(); //une seule fois à la création du widget pour savoir quel état utiliser.
}

class _AdminPageState extends State<AdminPage> { //Gère l'état (données qui changent)
  List<Plat> _plats = []; //liste plat vide
  bool _chargement = true; //chargemnt
  String? _erreur;//en cas d'erreurs

  // ── Formulaire ──────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>(); // accès au formulaire depuis n'importe où dans le code
  final _nomCtrl = TextEditingController(); //pour le champ nom...
  final _descCtrl = TextEditingController();
  final _ingCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  String _categorieForm = 'Coffee';

  // Images prédéfinies disponibles dans les assets
  static const List<String> _imagesDisponibles = [
    'assets/10.jpg', 'assets/11.jpg', 'assets/12.jpg', 'assets/13.jpg',
    'assets/14.jpg', 'assets/15.jpg', 'assets/16.jpg', 'assets/17.jpg',
    'assets/1.jpg.jpg', 'assets/2.jpg.jpg', 'assets/3.jpg.jpg',
    'assets/4.jpg.jpg', 'assets/5.jpg.jpg', 'assets/7.jpg.jpg',
    'assets/8.jpg.jpg', 'assets/9.jpg.jpg',
  ];
  String _imageSelectionnee = 'assets/10.jpg'; //un exemple d'image

  @override
  void initState() { //appeler une fois aprés creation de widget
    super.initState();  //forcer l'appel
    themeNotifier.addListener(_rebuild); //rebuild apres le changement
    _chargerPlats();
  }

  @override
  void dispose() {  //libérer toutes les ressources pour éviter les fuites mémoire contraire de init

    themeNotifier.removeListener(_rebuild);
    _nomCtrl.dispose();
    _descCtrl.dispose();
    _ingCtrl.dispose();
    _prixCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  // ─── Chargement ────────────────────────────────────────────────────────────
  Future<void> _chargerPlats() async {
    setState(() { _chargement = true; _erreur = null; });
    try {
      final plats = await DatabaseHelper.getPlats();  //lire la BD  stocke temporairement les plats reçus
      setState(() { _plats = plats; _chargement = false; });
    } catch (e) {
      setState(() { _erreur = e.toString(); _chargement = false; }); //op non reussi
    }
  }

  // ─── Suppression ───────────────────────────────────────────────────────────
  Future<void> _supprimerPlat(Plat plat) async { //pour supprimer un plat
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => _buildConfirmDialog(plat),
    );
    if (confirme != true) return;
    try {
      await DatabaseHelper.deletePlat(plat.id!);
      _afficherSnack('✅ "${plat.nom}" supprimé.', couleur: Colors.green.shade700);
      await _chargerPlats();
    } catch (e) {
      _afficherSnack('❌ Erreur : $e', couleur: Colors.redAccent);
    }
  }

  // ─── Ajout ─────────────────────────────────────────────────────────────────
  Future<void> _ajouterPlat() async {
    if (!_formKey.currentState!.validate()) return;
    final nouveau = Plat( //ajouter un plat avec c'est info
      nom: _nomCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      ingredients: _ingCtrl.text.trim(),
      prix: double.parse(_prixCtrl.text.trim()),
      imageUrl: _imageSelectionnee,
      categorie: _categorieForm,
    );
    try {
      await DatabaseHelper.insertPlat(nouveau); //inserer plat dans base de donnees
      _nomCtrl.clear(); _descCtrl.clear(); _ingCtrl.clear(); _prixCtrl.clear();
      if (mounted) Navigator.pop(context); // ferme le bottom sheet
      _afficherSnack('✅ "${nouveau.nom}" ajouté !', couleur: Colors.green.shade700);
      await _chargerPlats(); //faire un affichage cas errurs ou non
    } catch (e) {
      _afficherSnack('❌ Erreur : $e', couleur: Colors.redAccent);
    }
  }

  // ─── Formulaire d'ajout (bottom sheet) pour ajouter plats ─────────────────────────────────────
  void _ouvrirFormulaire() {
    final c = AppColors.current();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    Center(
                      child: Text('NOUVEAU PLAT',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 2)),
                    ),
                    const SizedBox(height: 20),

                    // Nom
                    _champTexte(c, _nomCtrl, 'Nom du plat', Icons.label_outline,
                        validateur: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                    const SizedBox(height: 12),

                    // Description
                    _champTexte(c, _descCtrl, 'Description', Icons.description_outlined,
                        validateur: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                    const SizedBox(height: 12),

                    // Ingrédients
                    _champTexte(c, _ingCtrl, 'Ingrédients', Icons.eco_outlined,
                        validateur: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                    const SizedBox(height: 12),

                    // Prix
                    _champTexte(c, _prixCtrl, 'Prix (DA)', Icons.payments_outlined,
                        clavier: TextInputType.number,
                        validateur: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          if (double.tryParse(v.trim()) == null) return 'Nombre invalide';
                          return null;
                        }),
                    const SizedBox(height: 12),

                    // Catégorie
                    Text('CATÉGORIE', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Coffee', 'Cake'].map((cat) {
                        final sel = _categorieForm == cat;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => _categorieForm = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.accent : c.bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: sel ? Colors.transparent : AppColors.accent.withOpacity(0.4)),
                              ),
                              child: Text(cat,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: sel ? Colors.black : c.text,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Image
                    Text('IMAGE', style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: c.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _imageSelectionnee,
                          dropdownColor: c.card,
                          isExpanded: true,
                          style: TextStyle(color: c.text, fontSize: 13),
                          items: _imagesDisponibles.map((img) {
                            return DropdownMenuItem(
                              value: img,
                              child: Text(img.split('/').last, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => _imageSelectionnee = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bouton valider
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('AJOUTER',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                        onPressed: _ajouterPlat,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── BUILD de interface─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final c = AppColors.current();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('ADMINISTRATION',
            style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 14)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.accent),
            onPressed: _chargerPlats,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(c),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ouvrirFormulaire,
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('AJOUTER',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody(AppColors c) {
    if (_chargement) {
      return Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(_erreur!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.text.withOpacity(0.7), fontSize: 14)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _chargerPlats,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      );
    }
    if (_plats.isEmpty) { //cas de plat vide
      return Center(
        child: Text('Aucun plat dans la base.',
            style: TextStyle(color: c.text.withOpacity(0.5), fontSize: 16)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: _plats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _buildPlatTile(c, _plats[i]),
    );
  }

  Widget _buildPlatTile(AppColors c, Plat plat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Miniature image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.4), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                plat.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.fastfood, color: AppColors.accent, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plat.nom,
                    style: TextStyle(
                        color: c.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(plat.categorie,
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('${plat.prix.toStringAsFixed(0)} DA',
                        style: TextStyle(
                            color: AppColors.accent.withOpacity(0.85),
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Bouton supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _supprimerPlat(plat),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Widget _champTexte(
      AppColors c,
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType? clavier,
        String? Function(String?)? validateur,
      }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: clavier,
      validator: validateur,
      style: TextStyle(color: c.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.accent.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: c.bg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }

  AlertDialog _buildConfirmDialog(Plat plat) { //pour les cas de supp
    final c = AppColors.current();
    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Confirmer la suppression',
          style: TextStyle(color: c.text, fontWeight: FontWeight.bold)),
      content: Text('Supprimer "${plat.nom}" définitivement ?',
          style: TextStyle(color: c.text.withOpacity(0.8))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: c.text.withOpacity(0.6)))),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white))),
      ],
    );
  }

  void _afficherSnack(String message, {Color? couleur}) {//affichage snack
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: couleur,
      behavior: SnackBarBehavior.floating,
    ));
  }
}