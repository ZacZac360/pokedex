import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FavoritesProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _favorites = {};

  // Check if a Pokémon is a favorite
  bool isFavorite(String url) => _favorites.containsKey(url);

  // Add/remove a Pokémon from favorites
  Future<void> toggleFavorite(String url) async {
    if (_favorites.containsKey(url)) {
      _favorites.remove(url);
    } else {
      // Fetch Pokémon details when adding to favorites
      final details = await fetchPokemonDetails(url);
      _favorites[url] = {
        'name': details['name'],
        'url': url,
        'types': (details['types'] as List)
            .map((typeInfo) => typeInfo['type']['name'])
            .toList(),
      };
    }
    notifyListeners();
  }

  // Get all favorites
  List<Map<String, dynamic>> get favorites => _favorites.values.toList();
}
