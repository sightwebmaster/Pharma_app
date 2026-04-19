# Thème et Design System

L'application utilise le framework **Material 3**. Tous les aspects visuels et le design system sont centralisés afin de garantir une cohérence visuelle sur l'ensemble de l'application.

## Centralisation

Toute la configuration du thème se trouve dans le dossier **`lib/core/themes/app_theme.dart`**.

**Règle absolue :**
Ne **JAMAIS** écrire de couleurs ou de styles en dur (hardcoded) dans les composants UI (`Screens` ou `Widgets`). Utilisez toujours le thème global via le context.

## Composants du Thème

1. **Couleurs** (`colorScheme`)
   - Les couleurs doivent correspondre aux tokens du Material 3 (primary, secondary, surface, error, etc.).
   - Utilisation : `Theme.of(context).colorScheme.primary`.

2. **Typographie** (`textTheme`)
   - Tous les styles de texte doivent être déclarés dans `app_theme.dart`.
   - Utilisation : `Theme.of(context).textTheme.headlineMedium`, `bodyLarge`, etc.

3. **Espacements & Tailles** (S'ils existent dans `lib/core/constants/`)
   - Préférer l'utilisation de constantes d'espacement (ex: `AppSizes.medium`) pour les marges (`Padding`, `SizedBox`) plutôt que des valeurs numériques isolées.

## Exemple Consigne pour l'IA

> Lors de la création d'un nouveau Widget (ex: un bouton personnalisé ou une carte), utilise `Theme.of(context)` pour appliquer les couleurs de fond et le texte. Si un composant a besoin d'être mis en évidence, réfère-toi au `colorScheme.primary` ou `colorScheme.secondary`.

```dart
// BONNE PRATIQUE
Text(
  'Bonjour',
  style: Theme.of(context).textTheme.titleLarge?.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
);

// MAUVAISE PRATIQUE
Text(
  'Bonjour',
  style: TextStyle(
    color: Colors.blue, // INTERDIT: Couleur en dur
    fontSize: 22,       // INTERDIT: Taille en dur
  ),
);
```
