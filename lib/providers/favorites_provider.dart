import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favorites = {};

  // Check if a Pokémon is a favorite
  bool isFavorite(String url) => _favorites.contains(url);

  // Add/remove a Pokémon from favorites
  void toggleFavorite(String url) {
    if (_favorites.contains(url)) {
      _favorites.remove(url);
    } else {
      _favorites.add(url);
    }
    notifyListeners();
  }

  // Get all favorites
  List<String> get favorites => _favorites.toList();
}
