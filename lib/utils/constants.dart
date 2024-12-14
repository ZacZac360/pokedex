import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonFilters {
  static final Map<int, List<String>> _pokemonTypes = {};

  static Future<void> initialize() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      for (var pokemon in data['results']) {
        final pokemonResponse = await http.get(Uri.parse(pokemon['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = json.decode(pokemonResponse.body);
          final id = pokemonData['id'];
          final types = (pokemonData['types'] as List)
              .map((type) => type['type']['name'].toString())
              .toList();
          _pokemonTypes[id] = types;
        }
      }
    }
  }

  static bool isTypeMatch(int id, String type) {
    return _pokemonTypes[id]?.contains(type.toLowerCase()) ?? false;
  }
}
