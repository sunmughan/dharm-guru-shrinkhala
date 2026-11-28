/// Deep link target for a notification, parsed from the push
/// payload or from a notification document. The values match
/// the openScreen values the admin app already writes and the
/// screens the user app inbox already opens, so the push path
/// and the inbox path agree on every target.
enum NotificationTarget {
  home,
  horoscope,
  panchang,
  consult,
  chat,
}

class NotificationDeepLink {
  const NotificationDeepLink({
    required this.target,
    this.chatId,
  });

  final NotificationTarget target;

  /// Chat id for a chat target, null for every other target.
  final String? chatId;

  /// Parses the data map of a push message or a notification
  /// document. Reads target first, then openScreen. A chat
  /// target without a chat id falls back to consult, and an
  /// unknown target falls back to home. Nothing here opens a
  /// screen by itself, the caller navigates.
  static NotificationDeepLink parse(Map<String, String> data) {
    final String raw =
        (data['target'] ?? data['openScreen'] ?? 'Home').trim();
    switch (raw) {
      case 'Daily Horoscope':
      case 'horoscope':
        return const NotificationDeepLink(target: NotificationTarget.horoscope);
      case 'Panchang':
      case 'panchang':
        return const NotificationDeepLink(target: NotificationTarget.panchang);
      case 'Consult':
      case 'consult':
        return const NotificationDeepLink(target: NotificationTarget.consult);
      case 'Chat':
      case 'chat':
        final String? chatId = data['chatId'];
        if (chatId == null || chatId.isEmpty) {
          return const NotificationDeepLink(
            target: NotificationTarget.consult,
          );
        }
        return NotificationDeepLink(
          target: NotificationTarget.chat,
          chatId: chatId,
        );
      case 'Home':
      case 'home':
      default:
        return const NotificationDeepLink(target: NotificationTarget.home);
    }
  }
}
