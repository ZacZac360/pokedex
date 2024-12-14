import 'dart:convert';
import 'package:http/http.dart' as http;

// Fetch the list of Pokémon
Future<List> fetchPokemonList({int offset = 0, int limit = 20}) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit'));
  if (response.statusCode == 200) {
    final List results = jsonDecode(response.body)['results'];
    return Future.wait(results.map((pokemon) async {
      final detailsResponse = await http.get(Uri.parse(pokemon['url']));
      final details = jsonDecode(detailsResponse.body);
      final types = (details['types'] as List).map((typeInfo) => typeInfo['type']['name']).toList();
      return {
        'name': pokemon['name'],
        'url': pokemon['url'],
        'types': types,
      };
    }).toList());
  } else {
    throw Exception('Failed to fetch Pokémon');
  }
}

// Fetch Pokémon types
Future<List<String>> fetchPokemonTypes({int offset = 0, int limit = 20}) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['results'] as List)
        .map((type) => type['name'].toString())
        .toList();
  } else {
    throw Exception('Failed to load Pokémon types');
  }
}

Future<List> fetchPokemonBySearch(String query) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'));
  if (response.statusCode == 200) {
    final List results = jsonDecode(response.body)['results'];
    final matchingPokemon = results
        .where((pokemon) => pokemon['name'].toLowerCase().contains(query))
        .toList();

    return Future.wait(matchingPokemon.map((pokemon) async {
      final detailsResponse = await http.get(Uri.parse(pokemon['url']));
      final details = jsonDecode(detailsResponse.body);
      final types = (details['types'] as List).map((typeInfo) => typeInfo['type']['name']).toList();
      return {
        'name': pokemon['name'],
        'url': pokemon['url'],
        'types': types,
      };
    }).toList());
  } else {
    throw Exception('Failed to fetch Pokémon by search');
  }
}

Future<List> fetchPokemonBySearchAndFilter(String query, String filter) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'));
  if (response.statusCode == 200) {
    final List results = jsonDecode(response.body)['results'];
    final matchingPokemon = results
        .where((pokemon) => pokemon['name'].toLowerCase().contains(query))
        .toList();

    final detailedPokemon = await Future.wait(matchingPokemon.map((pokemon) async {
      final detailsResponse = await http.get(Uri.parse(pokemon['url']));
      final details = jsonDecode(detailsResponse.body);
      final types = (details['types'] as List).map((typeInfo) => typeInfo['type']['name']).toList();

      return {
        'name': pokemon['name'],
        'url': pokemon['url'],
        'types': types,
      };
    }));

    // Apply filter after fetching all details
    return detailedPokemon
        .where((p) => filter == 'All' || p['types'].contains(filter.toLowerCase()))
        .toList();
  } else {
    throw Exception('Failed to fetch Pokémon by search and filter');
  }
}

// Fetch details for a specific Pokémon
Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Pokémon details');
  }
}

// Fetch Pokémon by type
Future<List> fetchPokemonByType(String type, {int offset = 0, int limit = 20}) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/$type'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['pokemon'] == null || data['pokemon'] is! List) {
      throw Exception('Unexpected data structure for Pokémon type: $type');
    }

    final List pokemonList = data['pokemon'];

    // Apply pagination to the results
    final paginatedList = pokemonList.skip(offset).take(limit).toList();

    // Fetch detailed data for each Pokémon
    return Future.wait(paginatedList.map((p) async {
      final detailsResponse = await http.get(Uri.parse(p['pokemon']['url']));
      final details = jsonDecode(detailsResponse.body);
      final types = (details['types'] as List).map((typeInfo) => typeInfo['type']['name']).toList();
      return {
        'name': p['pokemon']['name'],
        'url': p['pokemon']['url'],
        'types': types,
      };
    }).toList());
  } else {
    throw Exception('Failed to fetch Pokémon by type: $type');
  }
}
