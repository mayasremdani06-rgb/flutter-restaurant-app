#  Café Premium

## Présentation

Café Premium est une application mobile développée avec Flutter pour Un café-pâtisserie. Elle permet au client de consulter les détails de chaque produit, de composer un panier, de passer des commandes, etc. En plus, elle possède un espace admin qui facilite l'ajout ainsi que la modification des produits.

## Fonctionnalités

### Côté client

- Catalogue par catégorie : Cake ou Coffee, avec un tri selon le nom ou le prix.
- Fiche produit : description détaillée et ingrédients, pour que le client sache ce qu'il mange.
- Panier : permet de visualiser les choix, de les modifier et de les valider.
- Raccourcis et actions rapides : appel, localisation, envoi d'e-mails, partage des produits entre amis.

### Page À propos

Contient les coordonnées ainsi que l'ensemble des informations sur la pâtisserie.

### Préférences utilisateur

Thème, tri, choix de la devise.

### Administration

CRUD complet sur les plats : lire, écrire, supprimer, etc.

## Stack technique

| Domaine | Technologie |
|---|---|
| Framework | Flutter / Dart |
| Base de données locale | [`sqflite`](https://pub.dev/packages/sqflite) + [`path`](https://pub.dev/packages/path) |
| Préférences & panier | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Liens externes (tél., mail, carte) | [`url_launcher`](https://pub.dev/packages/url_launcher) |
| Partage | [`share_plus`](https://pub.dev/packages/share_plus) |
| Gestion d'état | `ValueNotifier` / `ValueListenableBuilder` |
| Thème | Material Design, thèmes clair et sombre |
