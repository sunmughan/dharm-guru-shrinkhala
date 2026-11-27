import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/user_profile.dart';

/// Complete profile form, modelled on what a top astrology app
/// collects (Astrotalk reference): full name, gender, date of
/// birth, time of birth with an explicit "I do not know my birth
/// time" choice, place of birth (city, state, country), marital
/// status, occupation, phone, language, and the daily horoscope
/// alert time. Every field saves to the user document in
/// Firestore and is read back by the Profile screen, the Home
/// greeting and the Kundli form. Nothing here is a sample: an
/// empty field stays empty until the user fills it.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({
    super.key,
    this.authService,
    this.firestoreService,
    this.existing,
  });

  final AuthService? authService;
  final FirestoreService? firestoreService;

  /// Profile to edit, or null to start from a blank form.
  final UserProfile? existing;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alertTimeController = TextEditingController();

  String? _gender;
  String? _maritalStatus;
  String? _language;
  bool _birthTimeUnknown = false;
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;
  TimeOfDay? _alertTime;
  String? _error;
  bool _busy = false;

  AuthService get _auth => widget.authService ?? AuthService();
  FirestoreService get _firestore =>
      widget.firestoreService ?? FirestoreService();

  @override
  void initState() {
    super.initState();
    final UserProfile? existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _gender = existing.gender;
      _maritalStatus = existing.maritalStatus;
      _occupationController.text = existing.occupation ?? '';
      _phoneController.text = existing.phoneNumber ?? '';
      _language = existing.language;
      _cityController.text = existing.birthCity ?? '';
      _stateController.text = existing.birthState ?? '';
      _countryController.text = existing.birthCountry ?? '';
      _birthTimeUnknown = existing.birthTimeUnknown;
      if (existing.dateOfBirth != null) {
        final List<String> bits = existing.dateOfBirth!.split('-');
        if (bits.length == 3) {
          final int? year = int.tryParse(bits[0]);
          final int? month = int.tryParse(bits[1]);
          final int? day = int.tryParse(bits[2]);
          if (year != null && month != null && day != null) {
            _dateOfBirth = DateTime(year, month, day);
            _dobController.text =
                '$day ${_monthName(month)} $year';
          }
        }
      }
      if (existing.timeOfBirth != null) {
        _timeOfBirth = _parseStoredTime(existing.timeOfBirth!);
        if (_timeOfBirth != null) {
          _timeController.text = _formatTimeOfDay(_timeOfBirth!);
        }
      }
      if (existing.horoscopeAlertTime != null) {
        _alertTime = _parseStoredTime(existing.horoscopeAlertTime!);
        if (_alertTime != null) {
          _alertTimeController.text = _formatTimeOfDay(_alertTime!);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _timeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _occupationController.dispose();
    _phoneController.dispose();
    _alertTimeController.dispose();
    super.dispose();
  }

  static const List<String> _months = <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _monthName(int month) => _months[month - 1];

  TimeOfDay? _parseStoredTime(String stored) {
    final List<String> bits = stored.split(':');
    if (bits.length != 2) return null;
    final int? hour = int.tryParse(bits[0]);
    final int? minute = int.tryParse(bits[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _storeTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatTimeOfDay(TimeOfDay time) {
    final String suffix = time.hour >= 12 ? 'PM' : 'AM';
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $suffix';
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      _dobController.text =
          '${picked.day} ${_monthName(picked.month)} ${picked.year}';
    });
  }

  Future<void> _pickTime({
    required bool isAlertTime,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isAlertTime
          ? (_alertTime ?? const TimeOfDay(hour: 6, minute: 0))
          : (_timeOfBirth ?? const TimeOfDay(hour: 6, minute: 25)),
    );
    if (picked == null) return;
    setState(() {
      if (isAlertTime) {
        _alertTime = picked;
        _alertTimeController.text = _formatTimeOfDay(picked);
      } else {
        _timeOfBirth = picked;
        _timeController.text = _formatTimeOfDay(picked);
      }
    });
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter your full name.');
      return;
    }
    if (_dateOfBirth == null) {
      setState(() => _error = 'Pick your date of birth.');
      return;
    }
    final String city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _error = 'Enter your place of birth city.');
      return;
    }
    final String? uid = _auth.currentUserId;
    if (uid == null) {
      setState(() => _error = 'Nobody is signed in.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final UserProfile profile = UserProfile(
      name: name,
      gender: _gender,
      dateOfBirth:
          '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
      timeOfBirth:
          _birthTimeUnknown || _timeOfBirth == null
              ? null
              : _storeTime(_timeOfBirth!),
      birthTimeUnknown: _birthTimeUnknown,
      birthCity: city,
      birthState: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      birthCountry: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      maritalStatus: _maritalStatus,
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      language: _language,
      horoscopeAlertTime:
          _alertTime == null ? null : _storeTime(_alertTime!),
    );
    try {
      await _firestore.saveUserProfile(uid: uid, data: profile.toMap());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save the profile. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.themed(context, AppTextStyles.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          _sectionTitle('About you'),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full name *'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: UserProfile.genders
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) =>
                setState(() => _gender = value),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _maritalStatus,
            decoration:
                const InputDecoration(labelText: 'Marital status'),
            items: UserProfile.maritalStatuses
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) =>
                setState(() => _maritalStatus = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _occupationController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Occupation'),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionTitle('Birth details'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your kundli is calculated from these details. '
            'Time of birth is optional: tick the box when you do not know it.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dobController,
            readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(
              labelText: 'Date of birth *',
              hintText: 'Pick a date',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _timeController,
            readOnly: true,
            enabled: !_birthTimeUnknown,
            onTap: () => _pickTime(isAlertTime: false),
            decoration: const InputDecoration(
              labelText: 'Time of birth',
              hintText: 'Pick a time',
            ),
          ),
          CheckboxListTile(
            title: const Text('I do not know my birth time'),
            value: _birthTimeUnknown,
            onChanged: (bool? value) {
              setState(() {
                _birthTimeUnknown = value ?? false;
                if (_birthTimeUnknown) {
                  _timeOfBirth = null;
                  _timeController.clear();
                }
              });
            },
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          TextField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Place of birth: city *',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _stateController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Place of birth: state',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _countryController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Place of birth: country',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _sectionTitle('Contact and language'),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number'),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _language,
            decoration:
                const InputDecoration(labelText: 'Horoscope language'),
            items: UserProfile.languages
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (String? value) =>
                setState(() => _language = value),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _alertTimeController,
            readOnly: true,
            onTap: () => _pickTime(isAlertTime: true),
            decoration: const InputDecoration(
              labelText: 'Daily horoscope alert time',
              hintText: 'Pick a time, default 06:00 AM',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null) ...<Widget>[
            Text(
              _error!,
              style: AppTextStyles.themed(context, AppTextStyles.body)
                  .copyWith(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ElevatedButton(
            onPressed: _busy ? null : _save,
            child: const Text('Save profile'),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fields marked * are needed for your kundli. The rest '
            'are optional and can be filled in later.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
