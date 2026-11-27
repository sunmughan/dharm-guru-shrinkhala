import 'package:material_ui/material_ui.dart';

import 'core/navigation/app_shell.dart';
import 'services/firebase_service.dart';

/// Entry point. Flutter app direct to Firebase, no backend.
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
  runApp(DharmGuruApp(firebaseReady: firebaseReady));
}
