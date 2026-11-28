import 'package:dharm_guru_shrinkhala/services/place_autocomplete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('place autocomplete parsing', () {
    test('parses suggestions from a Places response', () {
      final List<PlaceSuggestion> found = parseAutocompleteResponse(
        <String, dynamic>{
          'predictions': <Map<String, dynamic>>[
            <String, dynamic>{
              'description': 'Durg, Chhattisgarh, India',
              'place_id': 'place-durg',
            },
            <String, dynamic>{
              'description': 'Jirapur, Madhya Pradesh, India',
              'place_id': 'place-jirapur',
            },
            <String, dynamic>{'description': '', 'place_id': ''},
          ],
          'status': 'OK',
        },
      );
      expect(found.length, 2);
      expect(found.first.description, 'Durg, Chhattisgarh, India');
      expect(found.first.placeId, 'place-durg');
      expect(found.last.description, 'Jirapur, Madhya Pradesh, India');
    });

    test('parses coordinates from a Place Details response', () {
      final PlaceDetails? details = parsePlaceDetailsResponse(
        <String, dynamic>{
          'result': <String, dynamic>{
            'formatted_address': 'Jirapur, Madhya Pradesh, India',
            'geometry': <String, dynamic>{
              'location': <String, dynamic>{'lat': 24.0214, 'lng': 76.3764},
            },
          },
          'status': 'OK',
        },
      );
      expect(details, isNotNull);
      expect(details!.latitude, 24.0214);
      expect(details.longitude, 76.3764);
    });

    test('returns null when details carry no geometry', () {
      expect(
        parsePlaceDetailsResponse(
          <String, dynamic>{'result': <String, dynamic>{}},
        ),
        isNull,
      );
      expect(parseAutocompleteResponse(<String, dynamic>{}), isEmpty);
    });

    test('service without a key never calls the network', () async {
      const PlaceAutocompleteService service =
          PlaceAutocompleteService(apiKey: '');
      expect(service.hasKey, isFalse);
      expect(await service.fetchSuggestions('Durg'), isEmpty);
      expect(await service.fetchDetails('place-durg'), isNull);
    });
  });
}
