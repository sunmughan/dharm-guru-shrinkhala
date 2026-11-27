/// Remedy content model. Exact sample values from
/// design/screens/10-remedies.md. The four cards are the
/// presentation sample set for the sample kundli. No remedy
/// is invented. Remedies are guidance only and promise no
/// outcome.
class Remedy {
  const Remedy({
    required this.title,
    required this.body,
    required this.action,
  });

  final String title;
  final String body;

  /// 'done' shows a Mark as done button, 'ask' shows the
  /// gemstone question button.
  final String action;
}

class SampleRemedies {
  SampleRemedies._();

  static const List<Remedy> list = <Remedy>[
    Remedy(
      title: 'For weak Sun',
      body: 'Offer water to the rising sun each morning and chant '
          'Om Suryaya Namah eleven times.',
      action: 'done',
    ),
    Remedy(
      title: 'For Saturn calm',
      body: 'Light a mustard oil diya under a peepal tree on '
          'Saturday evening.',
      action: 'done',
    ),
    Remedy(
      title: 'Gemstone note',
      body: 'Panna suits your rashi swami Mercury. Wear it only '
          'after a full consultation.',
      action: 'ask',
    ),
    Remedy(
      title: 'Daily small act',
      body: 'Feed birds before breakfast. A tiny habit with a large '
          'blessing.',
      action: 'done',
    ),
  ];
}
