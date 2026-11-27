// screens/cart_page.dart
import 'package:flutter/material.dart';
import '../models/plat.dart';

class CartPage extends StatefulWidget { //C'est la page du panier de l'application. Elle affiche les plats ajoutés, permet de modifier les quantités, calcule le total et valide la commande.
  final List<Plat> cartItems; //Liste des plats dans le panier
  final Function(Plat, int) onQuantityChanged; //appler quantite change

  const CartPage({
    Key? key,
    required this.cartItems, //oblg
    required this.onQuantityChanged,//oblg
  }) : super(key: key);  // transmet la clé à StatefulWidget (classe parente)

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const Color bgDark     = Color(0xFF14100E);
  static const Color cardDark   = Color(0xFF221A16);
  static const Color accentGold = Color(0xFFC6A165);
  static const Color textLight  = Color(0xFFEFEBE9);

  double getTotal() =>
      widget.cartItems.fold(0, (sum, p) => sum + p.prix * p.quantite); //avoir le totale

  @override //interface
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "VOTRE COMMANDE",
          style: TextStyle(
              color: accentGold, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty //cas panier est vide
          ? Center(
              child: Text("Votre panier est vide.",
                  style: TextStyle(
                      color: textLight.withOpacity(0.5), fontSize: 18)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plat = widget.cartItems[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: accentGold.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      // Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentGold.withOpacity(0.4), width: 2),
                          image: DecorationImage(
                              image: AssetImage(plat.imageUrl),
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plat.nom,
                                style: const TextStyle(
                                    color: textLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(height: 4),
                            Text("${plat.prix} DA × ${plat.quantite} = ${(plat.prix * plat.quantite).toStringAsFixed(0)} DA",
                                style: TextStyle(
                                    color: accentGold.withOpacity(0.85),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      // Contrôle quantité ajouter supprimer
                      Container(
                        decoration: BoxDecoration(
                            color: accentGold,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                  plat.quantite == 1
                                      ? Icons.delete_outline
                                      : Icons.remove,
                                  color: Colors.black,
                                  size: 18),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              onPressed: () {
                                setState(() {
                                  widget.onQuantityChanged(
                                      plat, plat.quantite - 1);
                                  if (plat.quantite == 0) {
                                    widget.cartItems.removeAt(index); //quntite 0 sup index
                                  }
                                });
                              },
                            ),
                            Text("${plat.quantite}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.black, size: 18),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              onPressed: () {
                                setState(() {
                                  widget.onQuantityChanged(
                                      plat, plat.quantite + 1);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.cartItems.isEmpty
          ? null
          : Container(  //pour la barre eb dessous de prix
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                  color: cardDark,
                  border: Border(
                      top: BorderSide(color: accentGold.withOpacity(0.3)))),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total :",
                            style:
                                TextStyle(fontSize: 16, color: textLight)),
                        Text("${getTotal().toStringAsFixed(0)} DA",
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: accentGold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          padding:
                              const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () { //cliquer conf
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "✅ Commande validée ! Merci de votre confiance."),
                              backgroundColor: Color(0xFF0F6E56),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          "VALIDER LA COMMANDE",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
