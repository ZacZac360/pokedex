import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FilterBar extends StatefulWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const FilterBar({super.key, required this.currentFilter, required this.onFilterChanged});

  @override
  _FilterBarState createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  final List<String> _types = ['All', 'Favorites'];

  @override
  void initState() {
    super.initState();
    fetchPokemonTypes().then((types) {
      setState(() {
        _types.addAll(types);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: widget.currentFilter,
        items: _types
            .map((filter) => DropdownMenuItem(
          value: filter,
          child: Text(filter),
        ))
            .toList(),
        onChanged: (value) {
          if (value != null) widget.onFilterChanged(value);
        },
        isExpanded: true,
      ),
    );
  }
}

