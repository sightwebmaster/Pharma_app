# Patterns Courants (Common Patterns)

Des schémas de code reviennent fréquemment au sein de l'application et doivent être respectés.

## 1. Routage et Navigation (Routage Natif)

L'application utilise le **routage nommé natif Flutter** (pas de package externe comme GoRouter).
Le fichier **`lib/core/routes/app_routes.dart`** centralise l'ensemble des routes sous forme de chaînes de caractères (ex: `static const String home = '/home';`) et fournit un `Map<String, WidgetBuilder>` ou une génération dynamique via `onGenerateRoute`.

**Usage pour la navigation :**

```dart
// Pour naviguer vers une nouvelle page
Navigator.pushNamed(context, AppRoutes.home);

// Pour remplacer la page (ex: après connexion)
Navigator.pushReplacementNamed(context, AppRoutes.dashboard);

// Pour passer des arguments
Navigator.pushNamed(context, AppRoutes.details, arguments: itemId);
```

## 2. Appels API et Gestion des Erreurs

- Les requêtes réseau se font toutes au travers des classes du namespace `services/` (qui peuvent utiliser le singleton `api_client.dart`).
- Les appels HTTP/Services retournent généralement un bloc `try/catch`.
- Les objets retournés depuis les appels API sont toujours parsés en `Models` via les fabriques `_$ModelFromJson()`.

**Pattern dans les ViewModels :**

```dart
try {
  final result = await _apiClient.fetchSomething();
  _data = result.map((json) => MyModel.fromJson(json)).toList();
} catch (e) {
  // Gérer l'erreur proprement et assigner un message convivial
  _errorMessage = ExceptionHelper.getErrorMessage(e);
}
```

## 3. Initialisation Asynchrone dans l'UI

Lorsqu'un écran a besoin de charger des données au démarrage, le pattern recommandé avec Provider est l'utilisation de `WidgetsBinding.instance.addPostFrameCallback` ou `initState`.

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MyViewModel>().fetchInitialData();
  });
}
```

## 4. Modèles de Données et Sérialisation

Tous les modèles complexes (ex: `user_model.dart`) DOIVENT implémenter la sérialisation avec `json_serializable`.

**Pattern cible :**

```dart
import 'package:json_annotation/json_annotation.dart';
part 'my_model.g.dart';

@JsonSerializable()
class MyModel {
  final String id;
  // ... propriétés

  MyModel({required this.id});

  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MyModelToJson(this);
}
```
