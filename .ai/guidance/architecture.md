# Architecture du Projet

Ce projet Flutter suit une architecture en couches basée sur le pattern **MVVM** (Model-View-ViewModel). Cette structure permet de séparer clairement la logique métier, la gestion d'état et l'interface utilisateur.

## Vue d'ensemble des Couches

### 1. Presentation (`lib/presentation/`)

C'est la couche UI et la gestion d'état locale.

- **`screens/`** : Les pages/écrans principaux de l'application (Vues). Ne contiennent pas de logique métier complexe.
- **`widgets/`** : Composants réutilisables (boutons, cartes, listes).
- **`viewmodels/`** : Les classes gérant l'état pour les écrans (ViewModels) via `ChangeNotifier`. Ils appellent les services et exposent les données aux vues.

### 2. Services (`lib/services/`)

Contient la logique de communication avec l'extérieur. C'est ici que sont gérés les appels API, l'interaction avec Firebase ou la base de données locale.

- **Exemples** : `api_client.dart` (requêtes HTTP), `auth_service.dart` (authentification), `medication_service.dart` (gestion des médicaments).

### 3. Data (`lib/data/`)

Dédiée à la structure des données de l'application.

- **`models/`** : Classes de données fortement typées (ex: `user_model.dart`). Ces modèles utilisent souvent le package `json_serializable` pour générer automatiquement la sérialisation (fichiers `.g.dart`).

### 4. Core (`lib/core/`)

Contient les ressources transversales et utilitaires.

- **`config/` & `constants/`** : Variables globales, URLs d'API, constantes.
- **`routes/`** : Configuration du système de navigation.
- **`themes/`** : Centralisation du design (Material 3).
- **`utils/`** : Fonctions utilitaires, formateurs, helpers.

## Flux de Données (Data Flow)

1. L'utilisateur interagit avec une vue (`Screen`).
2. La vue appelle une méthode de son `ViewModel` correspondant.
3. Le ViewModel fait appel à un `Service` (ex: récupération de données de Firebase ou API).
4. Le `Service` renvoie des données brutes, qui sont mappées en `Models` typés.
5. Le `ViewModel` met à jour son état et appelle `notifyListeners()`.
6. La Vue, qui écoute (via `Consumer` ou `context.watch`), se reconstruit avec les nouvelles données.
