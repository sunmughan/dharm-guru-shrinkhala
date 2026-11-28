import 'dart:convert';
import 'dart:io';

/// Google Places autocomplete for the place of birth field.
/// Same Google Maps API family PixelGo HMS uses for its address
/// autocomplete (Maps JavaScript API, Places library). The key
/// is NOT in the repo: it comes from the
/// GOOGLE_PLACES_API_KEY dart-define, set in CI from the
/// GOOGLE_PLACES_API_KEY repo secret. Without a key the field
/// still works as plain text and the chart falls back to the
/// city list, so a missing key never breaks the form.
const String googlePlacesApiKey =
    String.fromEnvironment('GOOGLE_PLACES_API_KEY');

/// One autocomplete suggestion: the text to show and the id
/// used to fetch its coordinates.
class PlaceSuggestion {
  const PlaceSuggestion({required this.description, required this.placeId});

  final String description;
  final String placeId;

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: (json['description'] as String?) ?? '',
      placeId: (json['place_id'] as String?) ?? '',
    );
  }
}

/// A picked place with exact coordinates from Place Details.
class PlaceDetails {
  const PlaceDetails({
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  final String description;
  final double latitude;
  final double longitude;
}

/// Pure parsers, so tests cover them without any network call.
List<PlaceSuggestion> parseAutocompleteResponse(
  Map<String, dynamic> json,
) {
  final Object? raw = json['predictions'];
  if (raw is! List) return <PlaceSuggestion>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(PlaceSuggestion.fromJson)
      .where((PlaceSuggestion s) =>
          s.description.isNotEmpty && s.placeId.isNotEmpty)
      .toList();
}

PlaceDetails? parsePlaceDetailsResponse(Map<String, dynamic> json) {
  final Object? result = json['result'];
  if (result is! Map<String, dynamic>) return null;
  final Object? geometry = result['geometry'];
  if (geometry is! Map<String, dynamic>) return null;
  final Object? location = geometry['location'];
  if (location is! Map<String, dynamic>) return null;
  final Object? lat = location['lat'];
  final Object? lng = location['lng'];
  if (lat is! num || lng is! num) return null;
  return PlaceDetails(
    description: (result['formatted_address'] as String?) ??
        (result['name'] as String?) ??
        '',
    latitude: lat.toDouble(),
    longitude: lng.toDouble(),
  );
}

String autocompleteUrl(String query, String apiKey) {
  final String input = Uri.encodeQueryComponent(query);
  return 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input&types=(cities)&language=en&components=country:in'
      '&key=$apiKey';
}

String placeDetailsUrl(String placeId, String apiKey) {
  return 'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${Uri.encodeQueryComponent(placeId)}'
      '&fields=formatted_address,name,geometry&key=$apiKey';
}

/// Thin client over the Places HTTP API. One HttpClient per
/// call, 6 second timeout, empty list on any failure: a failed
/// lookup must never crash the birth form.
class PlaceAutocompleteService {
  const PlaceAutocompleteService({this.apiKey = googlePlacesApiKey});

  final String apiKey;

  bool get hasKey => apiKey.isNotEmpty;

  Future<Map<String, dynamic>?> _getJson(String url) async {
    final HttpClient client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 6);
    try {
      final HttpClientRequest request =
          await client.getUrl(Uri.parse(url));
      final HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;
      final String body = await response.transform(utf8.decoder).join();
      final Object? decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  Future<List<PlaceSuggestion>> fetchSuggestions(String query) async {
    if (!hasKey || query.trim().length < 2) return <PlaceSuggestion>[];
    final Map<String, dynamic>? json =
        await _getJson(autocompleteUrl(query.trim(), apiKey));
    if (json == null) return <PlaceSuggestion>[];
    return parseAutocompleteResponse(json);
  }

  Future<PlaceDetails?> fetchDetails(String placeId) async {
    if (!hasKey || placeId.isEmpty) return null;
    final Map<String, dynamic>? json =
        await _getJson(placeDetailsUrl(placeId, apiKey));
    if (json == null) return null;
    return parsePlaceDetailsResponse(json);
  }
}
