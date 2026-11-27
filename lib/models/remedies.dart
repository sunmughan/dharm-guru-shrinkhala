/// Remedy content model. Remedies are derived from the real
/// kundli by lib/services/remedies_engine.dart: weak planets
/// from computed positions, and the current Vimshottari
/// Mahadasha. Remedies are guidance only and promise no
/// outcome.
class Remedy {
  const Remedy({required this.title, required this.body, required this.action});

  final String title;
  final String body;

  /// 'done' shows a Mark as done button, 'ask' opens live
  /// consult for a question about the remedy.
  final String action;

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'body': body,
    'action': action,
  };

  static Remedy fromJson(Map<String, dynamic> json) => Remedy(
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    action: json['action'] as String? ?? '',
  );
}
