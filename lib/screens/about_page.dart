// screens/about_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // ouvrir des liens (Google Maps ici)

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  static const Color bgDark     = Color(0xFF14100E); //partagées par toute la classe, sans instancier d'objet
  static const Color cardDark   = Color(0xFF221A16);
  static const Color accentGold = Color(0xFFC6A165);
  static const Color textLight  = Color(0xFFEFEBE9);

  @override
  Widget build(BuildContext context) {
    return Scaffold( //Structure de base d'un écran Flutter
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentGold),
          onPressed: () => Navigator.pop(context), //revient au précédent
        ),
        title: const Text("À PROPOS",
            style: TextStyle(
                color: accentGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView( //Rend le contenu scrollable verticalement
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container( //pour avoir le logo
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentGold, width: 2),
                color: cardDark,
              ),
              child: const Icon(Icons.coffee_maker_outlined,
                  size: 50, color: accentGold),
            ),
            const SizedBox(height: 16),
            const Text("Café Premium",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textLight,
                    letterSpacing: 2)),
            const SizedBox(height: 6),
            Text("L'art du café et de la pâtisserie", //la phrase au debut
                style: TextStyle(
                    fontSize: 14,
                    color: textLight.withOpacity(0.55),
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 32),

            // Infos
            _buildInfoCard( //pour les informations ajouter
              children: [
                _buildInfoRow(Icons.location_on_outlined, "Adresse",
                    "Rue principale, Tizi-Ouzou, Algérie"),
                _buildDivider(),
                _buildInfoRow(Icons.phone_outlined, "Téléphone", "+213 555 123 456"),
                _buildDivider(),
                _buildInfoRow(Icons.email_outlined, "Email", "contact@cafepremium.dz"),
                _buildDivider(),
                _buildInfoRow(Icons.access_time_outlined, "Horaires",
                    "Lun – Sam : 08h00 – 22h00\nDim : 09h00 – 20h00"),
              ],
            ),
            const SizedBox(height: 20),

            // Description
            _buildInfoCard(  //pour les info dans a propo
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    "Fondé en 2026, Café Premium vous accueille dans un cadre chaleureux "
                    "pour déguster nos créations artisanales. Chaque café est préparé à la "
                    "commande avec des grains soigneusement sélectionnés, et nos pâtisseries "
                    "sont réalisées chaque matin par notre équipe passionnée.",
                    style: TextStyle(
                        fontSize: 14,
                        color: textLight.withOpacity(0.75),
                        height: 1.7),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bouton maps
            SizedBox(  //pour acceder au map
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: accentGold, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.map_outlined, color: accentGold),
                label: const Text("Nous trouver sur la carte",
                    style:
                        TextStyle(color: accentGold, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final uri = Uri.parse(  //url pour accer carte
                      'https://www.google.com/maps/search/?api=1&query=36.7169,4.0497');
                  if (await canLaunchUrl(uri)) { //vérifie si l'appareil peut ouvrir ce lien
                    await launchUrl(uri, mode: LaunchMode.externalApplication); //uvre dans l'app Google Maps
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Text("v1.0.0 — TP N°03 UMMTO",
                style: TextStyle(
                    fontSize: 11, color: textLight.withOpacity(0.3))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentGold.withOpacity(0.2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentGold, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      color: textLight.withOpacity(0.8), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => //Une fine ligne de séparation dorée très transparente
      Divider(color: accentGold.withOpacity(0.12), height: 1);
}
