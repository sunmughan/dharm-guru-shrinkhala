import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Auth service: email and password, phone sign in and Google sign in.
/// Phone verification uses Firebase Auth. No custom backend.
class AuthService {
  // Private initializing formal: only AuthService() with no argument
  // is ever called, from any library, so no caller passes _auth.
  AuthService({this._auth});

  // Nullable on purpose: tests subclass AuthService and override the
  // stream and methods below, so FirebaseAuth.instance is never
  // touched when no real auth object is passed in.
  final FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _auth ?? FirebaseAuth.instance;

  Stream<User?> get userChanges => _firebaseAuth.authStateChanges();

  /// True when a user is signed in, false otherwise.
  Stream<bool> get signedIn =>
      userChanges.map((User? user) => user != null);

  User? get currentUser => _firebaseAuth.currentUser;

  /// Signed in user id and email, or null. Separate getters so
  /// tests can override them without building a fake Firebase
  /// User object.
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sends the Firebase password reset email. The user taps the link
  /// in that email and sets a new password on the Firebase page.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Firebase error codes in plain words, so the UI never shows
  /// raw codes like invalid-credential to the user.
  static String plainError(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Something went wrong. Try again.';
    }
    return switch (error.code) {
      'invalid-email' =>
        'That email address does not look right. Check it and try again.',
      'user-not-found' =>
        'No account exists for that email. Create an account first.',
      'wrong-password' =>
        'The password is wrong. Try again or reset it.',
      'invalid-credential' =>
        'The email or password is wrong. Try again or reset your password.',
      'email-already-in-use' =>
        'An account already exists for that email. Sign in instead.',
      'weak-password' =>
        'Choose a stronger password with at least 6 characters.',
      'too-many-requests' =>
        'Too many tries. Wait a little while and try again.',
      'network-request-failed' =>
        'No internet connection. Check your connection and try again.',
      'operation-not-allowed' =>
        'Email sign in is not switched on yet. Ask the app team to enable it.',
      'user-disabled' => 'This account has been disabled.',
      _ => 'Something went wrong. Try again.',
    };
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? account =
        await GoogleSignIn().signIn();
    if (account == null) {
      return;
    }
    final GoogleSignInAuthentication googleAuth =
        await account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(FirebaseAuthException error) onFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
