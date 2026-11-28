import 'package:dharm_guru_shrinkhala/services/astro.dart';
import 'package:dharm_guru_shrinkhala/services/calculation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 2 calculation contract tests.
void main() {
  BirthInput canonicalInput() {
    return BirthInput(
      date: DateTime(1998, 3, 14),
      localTime: DateTime(1998, 3, 14, 6, 25),
      latitude: 26.9124,
      longitude: 75.7873,
      ianaTimezone: 'Asia/Kolkata',
      locationId: 'jaipur',
    );
  }

  test('canonical birth reproduces the DE441 chart', () {
    final CalculationResult result = CalculationEngine.calculate(
      input: canonicalInput(),
    );
    expect(result.utcInstant, DateTime.utc(1998, 3, 14, 0, 55));
    expect(result.julianDayValue, closeTo(2450886.5382, 0.001));
    expect(result.planetaryPositions['Sun'], closeTo(329.44, 0.5));
    expect(result.planetaryPositions['Moon'], closeTo(158.63, 1.0));
    expect(result.planetaryPositions['Jupiter'], closeTo(315.21, 2.0));
    expect(result.planetaryPositions.length, 9);
    // Lagna Kumbha: ascendant in 300 to 330.
    expect(result.ascendant, greaterThanOrEqualTo(300.0));
    expect(result.ascendant, lessThan(330.0));
    expect(result.houses[1], 'Kumbha');
    expect(result.houses[7], 'Simha');
    expect(result.nakshatras['Moon'], 'Uttara Phalguni');
    expect(result.padas['Moon'], 4);
    expect(result.aspects.isNotEmpty, isTrue);
    expect(result.metadata['calculationVersion'], '1.0.0');
    expect(result.metadata['ayanamsha'], 'lahiri');
    expect(result.metadata['nodeMode'], 'mean');
  });

  test('Raman config shifts every longitude by 1 degree 26 minutes', () {
    final CalculationResult lahiri = CalculationEngine.calculate(
      input: canonicalInput(),
    );
    final CalculationResult raman = CalculationEngine.calculate(
      input: canonicalInput(),
      config: const CalculationConfiguration(
        ayanamsha: AyanamshaMode.raman,
      ),
    );
    expect(
      raman.planetaryPositions['Sun']! - lahiri.planetaryPositions['Sun']!,
      closeTo(1.4333, 0.01),
    );
    expect(raman.metadata['ayanamsha'], 'raman');
  });

  test('true node config moves Rahu off the mean node', () {
    final CalculationResult mean = CalculationEngine.calculate(
      input: canonicalInput(),
    );
    final CalculationResult trueNode = CalculationEngine.calculate(
      input: canonicalInput(),
      config: const CalculationConfiguration(nodeMode: NodeMode.trueNode),
    );
    // True node is 0.70 degrees ahead of mean at this birth.
    expect(
      trueNode.planetaryPositions['Rahu']! -
          mean.planetaryPositions['Rahu']!,
      closeTo(0.70, 0.5),
    );
  });

  test('explicit offset works for a zone the engine does not know', () {
    final CalculationResult result = CalculationEngine.calculate(
      input: BirthInput(
        date: DateTime(2005, 6, 15),
        localTime: DateTime(2005, 6, 15, 8, 30),
        latitude: -33.8688,
        longitude: 151.2093,
        ianaTimezone: 'Australia/Sydney',
        locationId: 'sydney',
        utcOffsetMinutes: 600,
      ),
    );
    expect(result.utcInstant, DateTime.utc(2005, 6, 14, 22, 30));
    expect(result.planetaryPositions['Sun'], closeTo(59.94, 0.5));
  });

  test('unknown zone without an offset throws', () {
    expect(
      () => CalculationEngine.calculate(
        input: BirthInput(
          date: DateTime(2005, 6, 15),
          localTime: DateTime(2005, 6, 15, 8, 30),
          latitude: -33.8688,
          longitude: 151.2093,
          ianaTimezone: 'Australia/Sydney',
          locationId: 'sydney',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('unknown ephemeris, house system and version throw', () {
    expect(
      () => CalculationEngine.calculate(
        input: canonicalInput(),
        config: const CalculationConfiguration(ephemeris: 'vsop87'),
      ),
      throwsArgumentError,
    );
    expect(
      () => CalculationEngine.calculate(
        input: canonicalInput(),
        config: const CalculationConfiguration(houseSystem: 'placidus'),
      ),
      throwsArgumentError,
    );
    expect(
      () => CalculationEngine.calculate(
        input: canonicalInput(),
        config: const CalculationConfiguration(calculationVersion: '9.9.9'),
      ),
      throwsArgumentError,
    );
  });

  test('latitude and longitude outside range throw', () {
    expect(
      () => CalculationEngine.calculate(
        input: BirthInput(
          date: DateTime(2000, 1, 1),
          localTime: DateTime(2000, 1, 1, 12),
          latitude: 91.0,
          longitude: 0.0,
          ianaTimezone: 'Asia/Kolkata',
          locationId: '',
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => CalculationEngine.calculate(
        input: BirthInput(
          date: DateTime(2000, 1, 1),
          localTime: DateTime(2000, 1, 1, 12),
          latitude: 0.0,
          longitude: 181.0,
          ianaTimezone: 'Asia/Kolkata',
          locationId: '',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('tropical mode returns JPL frame longitudes', () {
    final CalculationResult result = CalculationEngine.calculate(
      input: canonicalInput(),
      config: const CalculationConfiguration(zodiacMode: 'tropical'),
    );
    expect(result.planetaryPositions['Sun'], closeTo(353.27, 0.5));
    expect(result.planetaryPositions['Moon'], closeTo(182.47, 1.0));
  });
}
