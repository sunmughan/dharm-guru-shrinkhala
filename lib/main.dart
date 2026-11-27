import 'package:material_ui/material_ui.dart';

import 'core/navigation/app_shell.dart';
import 'services/firebase_service.dart';

/// Entry point. Flutter app direct to Firebase, no backend.
/// The setup message only shows when Firebase itself fails to
/// initialise. A failed Remote Config fetch or Messaging token
/// no longer blocks the app, see FirebaseService.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = true;
  String? firebaseError;
  try {
    await FirebaseService.initialise();
  } catch (error) {
    firebaseReady = false;
    firebaseError = FirebaseService.lastInitError ?? error.toString();
  }
  runApp(
    DharmGuruApp(firebaseReady: firebaseReady, firebaseError: firebaseError),
  );
}
