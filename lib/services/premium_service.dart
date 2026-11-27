import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Premium gate. Remote Config already carries
/// premium_enabled, default false, fetched at startup by
/// FirebaseService. The whole premium flow stays off until
/// the owner turns that flag on and pricing is decided.
/// Tests pass their own flag reader so no Firebase call runs.
class PremiumService {
  PremiumService({this.isEnabled});

  final bool Function()? isEnabled;

  bool get isPremiumEnabled =>
      isEnabled?.call() ??
      FirebaseRemoteConfig.instance.getBool('premium_enabled');
}
