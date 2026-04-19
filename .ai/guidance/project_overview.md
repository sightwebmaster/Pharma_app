# Aperçu du Projet : Pharma App

## Objectif Global

**Pharma App** est une application Flutter ciblant multiples plateformes (Android, iOS, Web, Windows). Elle intègre des services de gestion médicale (récupération de médicaments, scan QR Code, recommandations, gestion de profils de patients et proches). Elle s'appuie massivement sur **Firebase** (FCM pour les notifications, Firestore/Auth potentiel), ainsi que sur une API externe REST/HTTP (`api_client.dart`).

## Structure des Dossiers Clés

```
lib/
├── core/         # Thèmes (Material 3), routes, constantes.
├── data/         # Objets métiers (Models).
├── presentation/ # Interfaces graphiques (Screens, Widgets) + Logique d'état (ViewModels).
├── services/     # Couche réseau, logique Firebase, Accès Base de données/API.
└── main.dart     # Point d'entrée, initialisation Firebase et MultiProvider de base.
```

## Points d'Entrée Importants à Connaître

- **Initialisation** : `main.dart` garantit l'initialisation de Flutter, injecte l'instance `Firebase.initializeApp()` (avec `firebase_options.dart`) et initialise les services singletons (`ApiClient`, `StorageService`).
- **Fournisseur d'État** : Les ViewModels majeurs sont généralement injectés via un `MultiProvider` global.
- **Services Principaux** :
  - L'application communique avec le hardware/API via une multitude de services bien distincts (ex: `auth_service.dart`, `medication_service.dart`, `qrcode_service.dart`, `fcm_registration_service.dart`).
- **Routing** : Configuré sous `core/routes/app_routes.dart`.

## À Prendre en Compte pour l'IA

- Le projet compile sur Windows (spécificités de bureau attendues).
- La présence forte de Firebase impose le respect des initialisations asynchrones exactes (cf `if (!kIsWeb) await Firebase.initializeApp(...)` dans main).
