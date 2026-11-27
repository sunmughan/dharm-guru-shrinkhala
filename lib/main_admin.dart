import 'package:material_ui/material_ui.dart';

import 'screens/admin_screens.dart';
import 'services/firebase_service.dart';

/// Admin entrypoint. Build or run with:
/// flutter run -t lib/main_admin.dart
/// flutter build apk --release -t lib/main_admin.dart
/// Same Firebase project and same auth system as the user app.
/// If Firebase is not configured, the app still starts and shows
/// the setup message instead of crashing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = true;
  try {
    await FirebaseService.initialise();
  } catch (_) {
    firebaseReady = false;
  }
  runApp(DharmGuruAdminApp(firebaseReady: firebaseReady));
}
