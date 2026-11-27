import 'package:material_ui/material_ui.dart';

import 'screens/admin_screens.dart';
import 'services/admin_seed_service.dart';
import 'services/firebase_service.dart';

/// Admin entrypoint. Build or run with:
/// flutter run --flavor admin -t lib/main_admin.dart
/// flutter build apk --release --flavor admin -t lib/main_admin.dart
/// Same Firebase project and same auth system as the user app.
/// The setup message only shows when Firebase itself fails to
/// initialise, see FirebaseService.
/// The default admin account (admin@gmail.com) is seeded through
/// Firebase Auth on first launch, before the UI starts, so the
/// sign in screen it opens on is already settled.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = true;
  String? firebaseError;
  try {
    await FirebaseService.initialise();
    await AdminSeedService.ensureDefaultAdmin();
  } catch (error) {
    firebaseReady = false;
    firebaseError = FirebaseService.lastInitError ?? error.toString();
  }
  runApp(
    DharmGuruAdminApp(
      firebaseReady: firebaseReady,
      firebaseError: firebaseError,
    ),
  );
}
