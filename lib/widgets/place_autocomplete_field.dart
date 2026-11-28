import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../services/place_autocomplete.dart';

/// Place of birth field with Google Places autocomplete, the
/// same API family PixelGo HMS uses for address autocomplete.
/// Typing shows matching Indian cities; tapping one fills the
/// field and reports its exact coordinates, so the kundli
/// engine never has to guess a place from the city list.
/// Without a configured key it behaves as a plain text field.
class PlaceAutocompleteField extends StatefulWidget {
  const PlaceAutocompleteField({
    super.key,
    required this.controller,
    this.service = const PlaceAutocompleteService(),
    this.onPlaceSelected,
  });

  final TextEditingController controller;
  final PlaceAutocompleteService service;
  final ValueChanged<PlaceDetails>? onPlaceSelected;

  @override
  State<PlaceAutocompleteField> createState() =>
      _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  List<PlaceSuggestion> _suggestions = <PlaceSuggestion>[];
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (!widget.service.hasKey || text.trim().length < 2) {
      setState(() => _suggestions = <PlaceSuggestion>[]);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _loading = true);
      final List<PlaceSuggestion> found =
          await widget.service.fetchSuggestions(text);
      if (!mounted) return;
      setState(() {
        _suggestions = found;
        _loading = false;
      });
    });
  }

  Future<void> _pick(PlaceSuggestion suggestion) async {
    final PlaceDetails? details =
        await widget.service.fetchDetails(suggestion.placeId);
    if (!mounted) return;
    setState(() => _suggestions = <PlaceSuggestion>[]);
    widget.controller.text = details?.description.isNotEmpty == true
        ? details!.description
        : suggestion.description;
    if (details != null) widget.onPlaceSelected?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          decoration: InputDecoration(
            labelText: 'Place of birth',
            hintText: 'Type a city, pick from suggestions',
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
        ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (BuildContext context, int index) {
                final PlaceSuggestion suggestion = _suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(suggestion.description),
                  onTap: () => _pick(suggestion),
                );
              },
            ),
          ),
      ],
    );
  }
}
