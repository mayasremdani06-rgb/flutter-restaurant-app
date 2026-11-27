// models/plat.dart
// ─── Modèle Plat avec support SQLite (id, fromMap, toMap) ────────────────────

class Plat {
  int? id; // clé primaire SQLite (null avant insertion)
  String nom;
  String description;
  String ingredients;
  double prix;
  String imageUrl;
  String categorie;
  int quantite;
  bool isSelected;

  Plat({
    this.id,
    required this.nom,
    required this.description,
    required this.ingredients,
    required this.prix,
    required this.imageUrl,
    required this.categorie,
    this.quantite = 0,
    this.isSelected = false,
  });

  // ─── SQLite : désérialisation ──────────────────────────────────────────────
  factory Plat.fromMap(Map<String, dynamic> map) => Plat(
    id: map['id'] as int?,
    nom: map['nom'] as String,
    description: map['description'] as String,
    ingredients: map['ingredients'] as String,
    prix: (map['prix'] as num).toDouble(),
    imageUrl: map['imageUrl'] as String,
    categorie: map['categorie'] as String,
  );

  // ─── SQLite : sérialisation (sans quantite/isSelected, qui sont en mémoire)
  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'nom': nom,
      'description': description,
      'ingredients': ingredients,
      'prix': prix,
      'imageUrl': imageUrl,
      'categorie': categorie,
    };
    if (id != null) m['id'] = id;
    return m;
  }
}