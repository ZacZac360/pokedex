import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class PokemonCard extends StatelessWidget {
  final Map pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final id = pokemon['url'].split('/')[6];
    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(imageUrl: imageUrl, height: 100, fit: BoxFit.cover),
          Text(pokemon['name']),
          IconButton(
            icon: Icon(
              favoritesProvider.isFavorite(pokemon['url']) ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(pokemon['url']);
            },
          ),
        ],
      ),
    );
  }
}
