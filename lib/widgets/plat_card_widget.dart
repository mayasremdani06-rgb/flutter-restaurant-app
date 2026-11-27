// widgets/plat_card_widget.dart
import 'package:flutter/material.dart';
import '../models/plat.dart';
import '../helpers/preferences_helper.dart';

class PlatCardWidget extends StatelessWidget {
  final Plat plat;
  final Function(int) onQuantityChanged;
  final VoidCallback onImageTap;
  final Color accentColor;
  final Color bgColor;
  final Color textColor;
  final String devise; // 'DA' | 'EUR' | 'USD'

  const PlatCardWidget({
    Key? key,
    required this.plat,
    required this.onQuantityChanged,
    required this.onImageTap,
    required this.accentColor,
    required this.bgColor,
    required this.textColor,
    required this.devise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: plat.isSelected ? accentColor : Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          // ─── Infos ──────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(plat.categorie.toUpperCase(),
                      style: TextStyle(
                          color: accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 3),
                  Text(plat.nom.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(plat.description,
                      style: TextStyle(
                          fontSize: 10, color: textColor.withOpacity(0.55)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDynamicQtyButton(),
                      Text(
                        PreferencesHelper.formaterPrix(plat.prix, devise),
                        style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          // ─── Image (tap → détail) ─────────────────────────────
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onImageTap,
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    plat.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.fastfood, color: accentColor, size: 30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicQtyButton() {
    if (plat.quantite == 0) {
      return GestureDetector(
        onTap: () => onQuantityChanged(1),
        child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withOpacity(0.5)),
          ),
          child: Icon(Icons.local_mall_outlined, color: accentColor, size: 17),
        ),
      );
    }
    return Container(
      height: 32,
      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            icon: Icon(
                plat.quantite == 1
                    ? Icons.delete_outline
                    : Icons.keyboard_arrow_down,
                color: Colors.black,
                size: 18),
            onPressed: () => onQuantityChanged(plat.quantite - 1),
          ),
          Text('${plat.quantite}',
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.black, size: 18),
            onPressed: () => onQuantityChanged(plat.quantite + 1),
          ),
        ],
      ),
    );
  }
}