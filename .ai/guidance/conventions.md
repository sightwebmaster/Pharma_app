# Conventions de Développement

Ces conventions assurent que le code généré est homogène et suit les meilleures pratiques de l'écosystème Flutter/Dart.

## Nommage

1. **Fichiers et Dossiers** : `snake_case` (ex: `user_profile_screen.dart`).
2. **Classes, Enums, Mixins** : `PascalCase` (ex: `UserProfileScreen`, `AuthViewModel`).
3. **Variables, Méthodes, Instances** : `camelCase` (ex: `fetchUserData()`, `isLoading`).
4. **Constantes** : `camelCase` ou `SCREAMING_SNAKE_CASE` (pour les configurations clés dans `core/constants/`).
5. **Variables privées** : Doivent toujours commencer par un underscore `_` (ex: `_service`, `_isLoading`).

## Modèles et Génération de Code

- Les modèles situés dans `data/models` utilisent **`json_serializable`**.
- Chaque modèle doit inclure les instructions `part 'nom_fichier.g.dart';`.
- La génération se fait via `build_runner`. Il faut instruire le terminal (via `flutter pub run build_runner build --delete-conflicting-outputs`) en cas d'ajout ou de modification de modèle.

## Gestion des Exceptions, Formulaires et Conventions Spécifiques

- **Gestion des Exceptions** : L'application possède des comportements spécifiques (spécifiés comme "patterns manquants" oui). Les services (ex: `api_client.dart`) doivent attraper les exceptions de base (HTTP, Firebase, Socket) et les relayer via des exceptions personnalisées intelligibles pour les ViewModels.
- **Linting** : Suivre de manière très stricte l'outil d'analyse statique défini dans `analysis_options.yaml`. Toujours ajouter le modifieur `const` pour les constructeurs de widgets statiques.
- **Formulaires** : Utiliser la classe native `Form` accompagnée d'une `GlobalKey<FormState>`. La logique de validation doit être rigoureusement dissociée (ou externalisée dans `core/utils/validators.dart`).

## Imports

- Organiser les imports dans l'ordre suivant :
  1. Imports natifs Dart (ex: `dart:convert`).
  2. Imports du SDK Flutter.
  3. Imports de packages tiers (ex: `provider`, `firebase_core`).
  4. Imports relatifs et propres au projet (`package:pharma_app/...`).
- Privilégier les imports absolus (`package:pharma_app/`) sur les imports relatifs compliqués (`../../`).
