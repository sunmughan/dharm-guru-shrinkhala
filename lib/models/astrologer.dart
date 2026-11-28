/// Astrologer record, Phase 10.
///
/// One astrologer is a real document in the `astrologers`
/// collection, read and written through Firestore only. The
/// astrologer the app is built for is Hans Ojha: his document
/// id and name below are the only identity facts the code
/// carries. Everything else about him, phone, photo, bio,
/// qualifications, languages, experience and rate, comes from
/// his record, and stays absent until he provides it. Nothing
/// here invents any of those values.
library;

/// Stable document id for the Hans Ojha record, so the
/// workspace, the consult chat and the admin screens all
/// address the same document.
const String kHansOjhaDocId = 'hans-ojha';

/// The astrologer name, as given by the owner. The only
/// identity fact about him the code carries.
const String kHansOjhaName = 'Hans Ojha';

/// Statuses an astrologer record can carry. The admin add
/// form creates 'waiting'; Approve in Manage Astrologers
/// sets 'offline' until slots bring the astrologer online.
class AstrologerStatus {
  AstrologerStatus._();

  static const String waiting = 'waiting';
  static const String approved = 'approved';

  /// 'Online' is the display spelling used by the admin
  /// filter; 'offline' is what Approve actually stores.
  /// isListedForConsultStatus compares case insensitively
  /// so both spellings list.
  static const String online = 'Online';
  static const String offline = 'offline';
  static const String rejected = 'rejected';
}

class Astrologer {
  const Astrologer({
    required this.id,
    required this.name,
    this.phone,
    this.photoUrl,
    this.bio,
    this.languages,
    this.qualifications,
    this.experience,
    this.rate,
    this.chatAvailable = true,
    this.callAvailable = true,
    this.status = AstrologerStatus.waiting,
    this.slots = const <String>[],
  });

  final String id;
  final String name;

  /// Phone calls dial this number. Null when Hans Ojha has
  /// not provided one yet; the UI says so plainly instead of
  /// dialling anything.
  final String? phone;

  /// Photo URL. Null when no photo has been provided yet.
  final String? photoUrl;

  /// Short bio. Null when no bio has been provided yet.
  final String? bio;

  /// Languages, as one string. Null when not provided yet.
  final String? languages;

  /// Qualifications. Null when not provided yet.
  final String? qualifications;

  /// Experience. Null when not provided yet.
  final String? experience;

  /// Rate. Null when pricing has not been decided yet.
  final String? rate;

  final bool chatAvailable;
  final bool callAvailable;

  /// One of AstrologerStatus. 'waiting' means the owner has
  /// not approved the record yet.
  final String status;

  final List<String> slots;

  static String? _text(Map<String, dynamic> map, String key) {
    final Object? value = map[key];
    if (value is! String) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  factory Astrologer.fromMap(Map<String, dynamic> map) {
    final Object? rawSlots = map['slots'];
    return Astrologer(
      id: map['id'] is String ? map['id'] as String : '',
      name: map['name'] is String ? map['name'] as String : '',
      phone: _text(map, 'phone'),
      photoUrl: _text(map, 'photoUrl'),
      bio: _text(map, 'bio'),
      languages: _text(map, 'languages'),
      qualifications: _text(map, 'qualifications'),
      experience: _text(map, 'experience'),
      rate: _text(map, 'rate'),
      chatAvailable: map['chatAvailable'] is bool
          ? map['chatAvailable'] as bool
          : true,
      callAvailable: map['callAvailable'] is bool
          ? map['callAvailable'] as bool
          : true,
      status: map['status'] is String
          ? map['status'] as String
          : AstrologerStatus.waiting,
      slots: rawSlots is List<dynamic>
          ? rawSlots.map((dynamic s) => s.toString()).toList()
          : const <String>[],
    );
  }

  /// Map for writing the record. Fields Hans Ojha has not
  /// provided yet are left out entirely, never stored as a
  /// placeholder value.
  Map<String, Object?> toMap() {
    final Map<String, Object?> map = <String, Object?>{
      'name': name,
      'chatAvailable': chatAvailable,
      'callAvailable': callAvailable,
      'status': status,
      'slots': slots,
    };
    if (phone != null) map['phone'] = phone;
    if (photoUrl != null) map['photoUrl'] = photoUrl;
    if (bio != null) map['bio'] = bio;
    if (languages != null) map['languages'] = languages;
    if (qualifications != null) map['qualifications'] = qualifications;
    if (experience != null) map['experience'] = experience;
    if (rate != null) map['rate'] = rate;
    return map;
  }

  /// The record the admin app creates for Hans Ojha when none
  /// exists yet: his name only. Every other field stays
  /// absent until he provides it.
  static Map<String, Object?> initialHansOjhaRecord() {
    return <String, Object?>{
      'name': kHansOjhaName,
      'chatAvailable': true,
      'callAvailable': true,
      'status': AstrologerStatus.waiting,
      'slots': <String>[],
    };
  }

  bool get hasPhone => phone != null;
  bool get hasPhoto => photoUrl != null;
  bool get hasBio => bio != null;
  bool get hasQualifications => qualifications != null;
  bool get hasLanguages => languages != null;
  bool get hasExperience => experience != null;
  bool get hasRate => rate != null;

  /// True when the record is approved for the consult list.
  /// Approve in Manage Astrologers stores 'offline' until
  /// slots bring the astrologer online, so 'offline' and
  /// 'Online' list too; only 'waiting' and 'rejected' do
  /// not. Compared case insensitively because Approve
  /// stores lowercase 'offline' while the admin filter
  /// spells it 'Offline'.
  bool get isListedForConsult =>
      isListedForConsultStatus(status);

  static bool isListedForConsultStatus(String status) {
    final String lower = status.toLowerCase();
    return lower == AstrologerStatus.approved ||
        lower == AstrologerStatus.online.toLowerCase() ||
        lower == AstrologerStatus.offline;
  }

  /// Labels for the details Hans Ojha has not provided yet,
  /// shown honestly in the workspace instead of invented
  /// values. Empty once everything is provided.
  List<String> get missingDetails {
    final List<String> missing = <String>[];
    if (!hasPhone) missing.add('Phone number');
    if (!hasPhoto) missing.add('Photo');
    if (!hasBio) missing.add('Bio');
    if (!hasQualifications) missing.add('Qualifications');
    if (!hasLanguages) missing.add('Languages');
    if (!hasExperience) missing.add('Experience');
    if (!hasRate) missing.add('Rate');
    return missing;
  }
}
