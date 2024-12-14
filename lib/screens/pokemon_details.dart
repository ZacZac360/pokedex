import 'package:flutter/material.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Map pokemon;

  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemon['name'].capitalize())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pokémon image
            Image.network(pokemon['image']),
            const SizedBox(height: 16),
            // Pokémon name and ID
            Text(
              '${pokemon['name'].capitalize()} (#${pokemon['id']})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Types
            Text('Types: ${pokemon['types'].join(', ')}'),
            const SizedBox(height: 8),
            // Abilities
            Text('Abilities: ${pokemon['abilities'].join(', ')}'),
            const SizedBox(height: 8),
            // Stats
            const Text('Stats:'),
            ...pokemon['stats'].map((stat) {
              return Text('${stat['stat']['name']}: ${stat['base_stat']}');
            }).toList(),
          ],
        ),
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
