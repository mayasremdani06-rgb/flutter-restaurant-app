// helpers/database_helper.dart
// ─── Helper SQLite : CRUD sur la table plats ─────────────────────────────────
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plat.dart';

class DatabaseHelper {
  static const _dbName = 'cafe_premium.db';
  static const _dbVersion = 1;
  static const _table = 'plats';

  static Database? _db;

  // ─── Singleton de la base ──────────────────────────────────────────────────
  static Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            nom         TEXT    NOT NULL,
            description TEXT    NOT NULL,
            ingredients TEXT    NOT NULL,
            prix        REAL    NOT NULL,
            imageUrl    TEXT    NOT NULL,
            categorie   TEXT    NOT NULL
          )
        ''');
        // Insertion des plats par défaut au premier lancement
        await _insererDefauts(db);
      },
    );
  }

  // ─── Données par défaut (identiques à l'ancien code en dur) ───────────────
  static Future<void> _insererDefauts(Database db) async {
    final defauts = [
      // ── CAKE ──────────────────────────────────────────────────────────────
      Plat(nom: 'Dark Muffins',             description: 'Muffins moelleux au cacao pur.',                                          ingredients: 'Cacao en poudre, lait entier, pépites.',                       prix: 300, imageUrl: 'assets/1.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Carré Royal au Chocolat',  description: 'Un gâteau somptueux à trois étages, alternant génoise moelleuse au cacao et ganache fondante.', ingredients: 'Chocolat noir intense, crème entière, farine de blé.', prix: 450, imageUrl: 'assets/2.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Tour de Brownies',         description: 'Trois généreux carrés de brownies au cœur dense et ultra-fondant.',       ingredients: 'Chocolat noir corsé, beurre fondu, sucre, noix.',               prix: 380, imageUrl: 'assets/3.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Brownie Glacé & Coulis',   description: 'Un brownie tiède baignant dans une sauce au chocolat avec glace vanille.',ingredients: 'Chocolat noir, beurre, glace vanille, coulis.',                 prix: 420, imageUrl: 'assets/4.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Fondant Pépites',          description: 'Petit gâteau fondant parsemé de généreuses pépites croquantes.',          ingredients: 'Farine, beurre, pépites de chocolat de couverture.',             prix: 350, imageUrl: 'assets/5.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Royal Chocolate Intégral', description: "Un gâteau entier recouvert d'un glaçage miroir au chocolat brillant.",   ingredients: 'Chocolat miroir, ganache, génoise cacao.',                       prix: 580, imageUrl: 'assets/7.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Bol de Glace Artisanale',  description: 'Glace au chocolat noir intense servie dans un bol avec coulis fondant.',  ingredients: 'Glace chocolat noir, coulis, pépites.',                          prix: 320, imageUrl: 'assets/8.jpg.jpg',  categorie: 'Cake'),
      Plat(nom: 'Bundt Cake au Chocolat',   description: 'Un Bundt cake moelleux et aéré au cacao, décoré de brisures.',            ingredients: 'Cacao profond, farine, glaçage fondant.',                        prix: 360, imageUrl: 'assets/9.jpg.jpg',  categorie: 'Cake'),
      // ── COFFEE ────────────────────────────────────────────────────────────
      Plat(nom: 'Cappuccino Arôme',         description: "Espresso double corsé, surmonté d'une mousse de lait crémeuse.",          ingredients: 'Espresso, lait entier moussé, cacao.',                           prix: 250, imageUrl: 'assets/10.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Latte Art Expresso',       description: 'Un espresso riche moussé avec un latte art complexe.',                    ingredients: 'Espresso, lait entier moussé.',                                   prix: 280, imageUrl: 'assets/11.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Cappuccino Cœur',          description: 'Cappuccino doux avec cœur dessiné au latte art et grains frais.',         ingredients: 'Espresso, lait, grains de café.',                                prix: 260, imageUrl: 'assets/12.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Frappé Mocha Dream',       description: 'Milkshake au café Mocha glacé avec crème fouettée.',                      ingredients: 'Café, glace vanille, chocolat, crème fouettée.',                  prix: 340, imageUrl: 'assets/13.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Double Espresso Gold',     description: 'Espresso double serré extrait à la perfection avec une crema dorée.',     ingredients: 'Espresso double, crema gold.',                                   prix: 220, imageUrl: 'assets/14.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Irish Coffee',             description: 'Espresso corsé, whisky irlandais et crème fouettée.',                     ingredients: 'Espresso, whisky, sucre de canne, crème.',                       prix: 380, imageUrl: 'assets/15.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Affogato à l\'Italienne',  description: 'Glace vanille plongée dans un espresso brûlant et crémeux.',              ingredients: 'Glace vanille, espresso double, chocolat noir.',                  prix: 420, imageUrl: 'assets/16.jpg',    categorie: 'Coffee'),
      Plat(nom: 'Triple Layer Drink',       description: 'Expérience en trois couches : chocolat, lait et espresso.',               ingredients: 'Chocolat noir, lait, espresso.',                                  prix: 480, imageUrl: 'assets/17.jpg',    categorie: 'Coffee'),
    ];
    for (final p in defauts) {
      await db.insert(_table, p.toMap());
    }
  }

  // ─── LIRE tous les plats ───────────────────────────────────────────────────
  /// Lance une [Exception] si la lecture échoue → affichage d'un message d'erreur dans l'UI.
  static Future<List<Plat>> getPlats() async {
    try {
      final db = await database;
      final rows = await db.query(_table);
      return rows.map(Plat.fromMap).toList();
    } catch (e) {
      throw Exception('Impossible de charger les plats : $e');
    }
  }

  // ─── INSÉRER un plat ──────────────────────────────────────────────────────
  static Future<int> insertPlat(Plat plat) async {
    try {
      final db = await database;
      return await db.insert(_table, plat.toMap());
    } catch (e) {
      throw Exception('Impossible d\'ajouter le plat : $e');
    }
  }

  // ─── SUPPRIMER un plat ────────────────────────────────────────────────────
  static Future<int> deletePlat(int id) async {
    try {
      final db = await database;
      return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Impossible de supprimer le plat : $e');
    }
  }

  // ─── METTRE À JOUR un plat ────────────────────────────────────────────────
  static Future<int> updatePlat(Plat plat) async {
    try {
      final db = await database;
      return await db.update(
        _table,
        plat.toMap(),
        where: 'id = ?',
        whereArgs: [plat.id],
      );
    } catch (e) {
      throw Exception('Impossible de modifier le plat : $e');
    }
  }
}