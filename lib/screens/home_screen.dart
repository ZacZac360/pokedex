import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/filter_bar.dart';
import '../providers/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:pokemon/widgets/search_bar.dart' as custom;
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _pokemon = [];
  String _filter = 'All';
  String _searchQuery = '';
  int _offset = 0;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPokemon();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
        _fetchPokemon();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPokemon({bool clear = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (clear) {
        _pokemon = [];
        _offset = 0;
      }
    });

    List data;

    if (_filter == 'Favorites') {
      // Fetch favorites directly from the provider
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      data = favoritesProvider.favorites; // Favorites are preloaded, no API call needed
    } else if (_searchQuery.isNotEmpty) {
      data = await fetchPokemonBySearchAndFilter(_searchQuery, _filter);
    } else if (_filter == 'All') {
      data = await fetchPokemonList(offset: _offset, limit: 20);
    } else {
      data = await fetchPokemonByType(_filter.toLowerCase(), offset: _offset, limit: 20);
    }

    setState(() {
      _pokemon.addAll(data);
      _offset += 20;
      _isLoading = false;
    });
  }


  void _updateFilter(String filter) {
    setState(() {
      _filter = filter;
    });
    _fetchPokemon(clear: true);
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchPokemon(clear: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: Column(
        children: [
          custom.SearchBar(onSearch: _updateSearch),
          FilterBar(currentFilter: _filter, onFilterChanged: _updateFilter),
          Expanded(
            child: _isLoading && _pokemon.isEmpty
                ? const Center(child: CircularProgressIndicator()) // Show loader if data is loading
                : _pokemon.isEmpty
                ? const Center(child: Text("No results found",
                style: TextStyle(fontSize: 18, color: Colors.grey)))
                : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
              ),
              itemCount: _pokemon.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when fetching more data
                if (index == _pokemon.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show the Pokemon Card when data is available
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(pokemonUrl: _pokemon[index]['url']),
                      ),
                    );
                  },
                  child: PokemonCard(pokemon: _pokemon[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
