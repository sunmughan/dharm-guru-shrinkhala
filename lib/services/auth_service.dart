import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when Google sign in finds an existing email and
/// password account for the same email. The app must sign in
/// with the password once, then link the Google account to it,
/// so one Firebase user ends up with both sign in methods.
/// Carries the email so the UI can prefill the sign in form.
class GoogleLinkNeededException implements Exception {
  GoogleLinkNeededException(this.email);

  final String? email;
}

/// An error with a plain message for the user, for cases the
/// Firebase error codes do not cover. PlainError returns the
/// message as is.
class AuthMessageException implements Exception {
  AuthMessageException(this.message);

  final String message;
}

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

  /// Google credential kept when sign in found an existing email
  /// account for the same email. Linked to that account right
  /// after the password sign in, through
  /// linkPendingGoogleCredential. Null when nothing is pending.
  OAuthCredential? _pendingGoogleCredential;

  /// Email the pending Google credential belongs to.
  String? _pendingLinkEmail;

  /// True when a Google sign in is waiting to be linked to the
  /// account that just signed in with a password.
  bool get hasPendingGoogleLink => _pendingGoogleCredential != null;

  /// Email the pending Google link belongs to, or null.
  String? get pendingLinkEmail => _pendingLinkEmail;

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

  /// True when the signed in account has Google linked as a
  /// sign in method.
  bool get currentUserHasGoogleProvider =>
      _firebaseAuth.currentUser?.providerData.any(
            (UserInfo info) => info.providerId == 'google.com',
          ) ??
      false;

  /// True when the signed in account has email and password
  /// as a sign in method.
  bool get currentUserHasPasswordProvider =>
      _firebaseAuth.currentUser?.providerData.any(
            (UserInfo info) => info.providerId == 'password',
          ) ??
      false;

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
    if (error is AuthMessageException) {
      return error.message;
    }
    if (error is GoogleLinkNeededException) {
      return 'An account already exists for this email. Sign in with '
          'your password once to link Google to it.';
    }
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
      'account-exists-with-different-credential' =>
        'An account already exists for this email. Sign in with your '
            'password once to link Google to it.',
      'credential-already-in-use' =>
        'This Google account is already linked to a different account.',
      'requires-recent-login' =>
        'For safety, sign out and sign in again, then try this change.',
      _ => 'Something went wrong. Try again.',
    };
  }

  /// Google sign in. When nobody is signed in, signs in with the
  /// Google account. When a user is already signed in, links the
  /// Google account to that user instead, so the same account
  /// opens with Google and with email and password both.
  /// When the Google email already has an email and password
  /// account, throws GoogleLinkNeededException and keeps the
  /// credential pending: the caller signs in with the password
  /// once and then calls linkPendingGoogleCredential, so the two
  /// sign in methods end up on the same Firebase user and no
  /// second account is created.
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
    final User? current = _firebaseAuth.currentUser;
    if (current != null) {
      try {
        await current.linkWithCredential(credential);
      } on FirebaseAuthException catch (error) {
        if (error.code == 'provider-already-linked') {
          return;
        }
        rethrow;
      }
      return;
    }
    try {
      await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'account-exists-with-different-credential') {
        _pendingGoogleCredential = credential;
        _pendingLinkEmail = error.email;
        throw GoogleLinkNeededException(error.email);
      }
      rethrow;
    }
  }

  /// Links the Google credential kept by a failed sign in to the
  /// account that just signed in with a password. Clears the
  /// pending credential either way. Does nothing when nothing
  /// is pending or nobody is signed in.
  Future<void> linkPendingGoogleCredential() async {
    final OAuthCredential? credential = _pendingGoogleCredential;
    final User? current = _firebaseAuth.currentUser;
    _pendingGoogleCredential = null;
    _pendingLinkEmail = null;
    if (credential == null || current == null) {
      return;
    }
    try {
      await current.linkWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked') {
        return;
      }
      rethrow;
    }
  }

  /// Changes the signed in account email. Reauthenticates first,
  /// as Firebase requires: with the current password when the
  /// account has one, otherwise with a fresh Google sign in.
  /// Sends a verification link to the new email; the email only
  /// changes after the user taps that link. Callers must say so.
  Future<void> updateEmailAddress({
    required String newEmail,
    String? currentPassword,
  }) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthMessageException('Nobody is signed in.');
    }
    final String? email = user.email;
    if (email == null) {
      throw AuthMessageException('This account has no email address.');
    }
    if (currentUserHasPasswordProvider) {
      if (currentPassword == null || currentPassword.isEmpty) {
        throw AuthMessageException(
          'Enter your current password to change the email.',
        );
      }
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
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
      await user.reauthenticateWithCredential(credential);
    }
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  /// Changes the signed in account password. Reauthenticates
  /// with the current password first, as Firebase requires.
  /// Google only accounts have no password to change: the
  /// caller shows the reset email path instead.
  Future<void> updateAccountPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthMessageException('Nobody is signed in.');
    }
    if (!currentUserHasPasswordProvider) {
      throw AuthMessageException(
        'This account signs in with Google and has no password yet. '
        'Use Forgot password on the sign in screen to set one.',
      );
    }
    final String? email = user.email;
    if (email == null) {
      throw AuthMessageException('This account has no email address.');
    }
    final AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
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
