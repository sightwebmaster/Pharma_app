# Gestion d'État

La gestion de l'état de l'application s'appuie principalement sur le package **Provider** (`package:provider`). Elle suit le paradigme MVVM en implémentant des `ChangeNotifier` pour chaque domaine fonctionnel.

## Principes Généraux

- Les **ViewModels** (`lib/presentation/viewmodels/`) étendent `ChangeNotifier`.
- Le point d'entrée `main.dart` déclare un `MultiProvider` global si l'état doit être partagé entre plusieurs écrans, ou un `ChangeNotifierProvider` local injecté au niveau du constructeur de la route.

## Règles d'Utilisation

1. **ViewModels** :
   - Ils stockent les variables d'état (données, états de chargement, erreurs).
   - Ils exécutent la logique métier et les appels asynchrones aux `services`.
   - Utilisation de `notifyListeners()` lorsque l'état change pour redessiner l'UI.

2. **Écoute de l'état dans l'UI** :
   - Privilégier le widget **`Consumer<T>`** pour réagir aux changements d'état sans reconstruire tout l'écran, uniquement les parties de l'UI concernées.
   - **`context.read<T>()`** est utilisé dans les callbacks (comme `onPressed`) pour déclencher des actions sans écouter les changements (ne cause pas de reconstruction).
   - **`context.watch<T>()`** peut être utilisé dans la méthode `build` pour écouter l'état global du ViewModel s'il s'applique à la majeure partie de l'écran.

## Exemple d'Implémentation

```dart
// viewmodels/example_viewmodel.dart
class ExampleViewModel extends ChangeNotifier {
  final ExampleService _service = ExampleService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.fetchData();
      // ... maj de l'état avec 'data'
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```
