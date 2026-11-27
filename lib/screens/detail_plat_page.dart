// screens/detail_plat_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/plat.dart';

class DetailPlatPage extends StatefulWidget { //dynamqiue chnage
  final Plat plat; //on a des plats
  const DetailPlatPage({Key? key, required this.plat}) : super(key: key);

  @override
  _DetailPlatPageState createState() => _DetailPlatPageState();
}

class _DetailPlatPageState extends State<DetailPlatPage> {
  int _quantite = 0;

  // ─── COULEURS ────────────────────────────────────────────
  static const Color bgDark     = Color(0xFF14100E);
  static const Color cardDark   = Color(0xFF221A16);
  static const Color accentGold = Color(0xFFC6A165);
  static const Color textLight  = Color(0xFFEFEBE9);

  // ─── CONSTANTES RESTAURANT ───────────────────────────────
  static const String _phoneNumber  = "+213555123456";
  static const String _emailAddress = "contact@cafepremium.dz";
  static const String _restaurantAddress = "Café Premium, Tizi-Ouzou, Algérie";
  static const double _lat = 36.7169;
  static const double _lng = 4.0497;

  // ─── INTENTIONS  faire appel au res──────────────────────────────────────────

  Future<void> _appelerRestaurant() async {
    final uri = Uri(scheme: 'tel', path: _phoneNumber); //url vers phone
    if (await canLaunchUrl(uri)) { //attendre le lancement
      await launchUrl(uri);
    } else {
      _showError("Impossible d'ouvrir l'application téléphone."); //erreurs de lancement app
    }
  }
//pour envoi de email
  Future<void> _envoyerEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      queryParameters: {
        'subject': 'Commande – ${widget.plat.nom}',   //predesc
        'body':
            'Bonjour,\n\nJe souhaite commander : ${widget.plat.nom} (${widget.plat.prix} DA).\n\nMerci.',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Aucun client email disponible.");
    }
  }

  Future<void> _voirSurCarte() async {  //voir map
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showError("Impossible d'ouvrir Google Maps.");
    }
  }

  void _partagerPlat() {  //partage de plats
    Share.share(
      '🍽️ ${widget.plat.nom}\n'
      '${widget.plat.description}\n'
      '💰 ${widget.plat.prix} DA\n\n'
      'Découvrez notre menu sur Café Premium !',
      subject: 'Je vous recommande ${widget.plat.nom}',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── AJOUTER AU PANIER ───────────────────────────────────
  void _ajouterAuPanier() { //fonction pour ajouter au panier
    if (_quantite == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Choisissez une quantité d'abord."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // ── Retour de données vers MenuPage (Navigator.pop avec résultat) ──
    Navigator.pop(context, {'plat': widget.plat, 'quantite': _quantite});

    // SnackBar visible depuis la page précédente (MenuPage)
    // affiché via le ScaffoldMessenger racine
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '✅ ${widget.plat.nom} × $_quantite ajouté au panier !'),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentGold),
          onPressed: () => Navigator.pop(context),
          tooltip: "Retour",
        ),
        title: Text(
          widget.plat.nom.toUpperCase(),
          style: const TextStyle(
              color: accentGold, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── IMAGE ──────────────────────────────────────
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentGold, width: 2),
                image: DecorationImage(
                    image: AssetImage(widget.plat.imageUrl),
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // ─── NOM + PRIX ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.plat.nom.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textLight),
                  ),
                ),
                Text(
                  "${widget.plat.prix} DA",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentGold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Badge catégorie
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentGold.withOpacity(0.4))),
              child: Text(widget.plat.categorie.toUpperCase(),
                  style: const TextStyle(
                      color: accentGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 20),

            // ─── QUANTITÉ ────────────────────────────────────
            _buildSectionTitle("QUANTITÉ"),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQtyButton(
                  icon: _quantite == 1 ? Icons.delete_outline : Icons.remove,
                  onTap: () {
                    if (_quantite > 0) setState(() => _quantite--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text("$_quantite",
                      style: const TextStyle(
                          color: textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                ),
                _buildQtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantite++),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── DESCRIPTION ─────────────────────────────────
            _buildSectionTitle("DESCRIPTION"),
            const SizedBox(height: 6),
            Text(
              widget.plat.description,
              style: TextStyle(
                  fontSize: 15, color: textLight.withOpacity(0.8), height: 1.6),
            ),
            const SizedBox(height: 20),

            // ─── INGRÉDIENTS ─────────────────────────────────
            _buildSectionTitle("INGRÉDIENTS"),
            const SizedBox(height: 6),
            Text(
              widget.plat.ingredients,
              style: TextStyle(
                  fontSize: 14,
                  color: textLight.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                  height: 1.5),
            ),
            const SizedBox(height: 28),

            // ─── BOUTON AJOUTER AU PANIER ─────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                label: const Text(
                  "AJOUTER AU PANIER",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                onPressed: _ajouterAuPanier,
              ),
            ),
            const SizedBox(height: 28),

            // ─── SECTION INTENTIONS ──────────────────────────
            _buildSectionTitle("ACTIONS"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentGold.withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  _buildIntentButton(
                    icon: Icons.phone_outlined,
                    label: "Appeler le restaurant",
                    onTap: _appelerRestaurant,
                  ),
                  _buildDivider(),
                  _buildIntentButton(
                    icon: Icons.email_outlined,
                    label: "Envoyer un email",
                    onTap: _envoyerEmail,
                  ),
                  _buildDivider(),
                  _buildIntentButton(
                    icon: Icons.map_outlined,
                    label: "Voir sur la carte",
                    onTap: _voirSurCarte,
                  ),
                  _buildDivider(),
                  _buildIntentButton(
                    icon: Icons.share_outlined,
                    label: "Partager ce plat",
                    onTap: _partagerPlat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS UI ──────────────────────────────────────────

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: accentGold,
          letterSpacing: 2),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap}) { //C'est une méthode helper qui crée un bouton stylisé pour contrôler la quantité
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accentGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentGold.withOpacity(0.5)),
        ),
        child: Icon(icon, color: accentGold, size: 22),
      ),
    );
  }

  Widget _buildIntentButton( //est un helper qui crée une ligne cliquable stylisée avec une icône à gauche, un label au centre et une flèche
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: accentGold, size: 22),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: textLight.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.chevron_right, color: textLight.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() =>  //fine ligne de séparation dorée et semi-transparente entre les éléments d'une liste.
      Divider(color: accentGold.withOpacity(0.15), height: 1);
}
