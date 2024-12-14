import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailsScreen extends StatefulWidget {
  final String pokemonUrl;

  const DetailsScreen({super.key, required this.pokemonUrl});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? pokemonData;
  Map<String, dynamic>? speciesData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemonDetails();
  }

  Future<void> fetchPokemonDetails() async {
    final response = await http.get(Uri.parse(widget.pokemonUrl));
    if (response.statusCode == 200) {
      pokemonData = jsonDecode(response.body);
      await fetchPokemonSpecies(pokemonData!['species']['url']);
      setState(() {
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  Future<void> fetchPokemonSpecies(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      speciesData = jsonDecode(response.body);
    } else {
      throw Exception('Failed to load Pokémon species data');
    }
  }

  String getFlavorText(String language) {
    if (speciesData == null) return '';
    for (var entry in speciesData!['flavor_text_entries']) {
      if (entry['language']['name'] == language) {
        return entry['flavor_text'].replaceAll('\n', ' ');
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String name = pokemonData!['name'];
    final int id = pokemonData!['id'];
    final List types = pokemonData!['types'];
    final List abilities = pokemonData!['abilities'];
    final List stats = pokemonData!['stats'];
    final String flavorText = getFlavorText('en');

    return Scaffold(
      appBar: AppBar(
        title: Text(name.toUpperCase()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pokémon Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                pokemonData!['sprites']['other']['official-artwork']['front_default'],
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            // Basic Info
            Text(
              'ID: #$id',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Types: ${types.map((type) => type['type']['name'].toUpperCase()).join(', ')}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            // Flavor Text
            if (flavorText.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    flavorText,
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Abilities Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Abilities',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...abilities.map((ability) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          ability['ability']['name'].toUpperCase(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Stats Section
            Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Base Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...stats.map((stat) {
                      return _buildStatBar(
                        stat['stat']['name'],
                        stat['base_stat'],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String name, int value, {int maxStat = 150}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Container(
              height: 10,
              width: (value / maxStat) * MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
