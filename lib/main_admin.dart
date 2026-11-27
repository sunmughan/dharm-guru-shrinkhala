import 'package:material_ui/material_ui.dart';

import 'screens/admin_screens.dart';
import 'services/firebase_service.dart';

/// Admin entrypoint. Build or run with:
/// flutter run --flavor admin -t lib/main_admin.dart
/// flutter build apk --release --flavor admin -t lib/main_admin.dart
/// Same Firebase project and same auth system as the user app.
/// The setup message only shows when Firebase itself fails to
/// initialise, see FirebaseService.
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
