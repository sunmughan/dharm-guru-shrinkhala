import 'package:material_ui/material_ui.dart';

import '../core/theme/design_tokens.dart';
import '../services/auth_service.dart';

/// Email must have something before and after the @ and a dot
/// in the domain part. Plain language, no regex shown to the user.
String? validateEmail(String value) {
  final String email = value.trim();
  final int at = email.indexOf('@');
  if (at < 1 ||
      !email.substring(at + 1).contains('.') ||
      email.endsWith('.')) {
    return 'Enter a valid email address, like name@example.com.';
  }
  return null;
}

/// Firebase needs at least 6 characters for a password.
String? validatePassword(String value) {
  if (value.length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

String? validatePasswordMatch(String password, String confirm) {
  if (password != confirm) {
    return 'Passwords do not match.';
  }
  return null;
}

enum _AuthMode { signIn, signUp, forgot }

/// Sign in gate screen. Email and password sign in, sign up with
/// email and password, forgot password by reset email, and Google
/// sign in. Phone OTP stays in AuthService with no screen yet.
/// On success the auth state stream flips and the app shell takes
/// over, so this screen navigates nowhere itself.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  String? _error;
  String? _notice;
  String? _resetSentTo;
  bool _busy = false;

  AuthService get _auth => widget.authService ?? AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _notice = null;
      _resetSentTo = null;
    });
  }

  Future<void> _submitEmail() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String? emailError = validateEmail(email);
    if (emailError != null) {
      setState(() => _error = emailError);
      return;
    }
    if (_mode == _AuthMode.forgot) {
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        await _auth.sendPasswordResetEmail(email);
        setState(() => _resetSentTo = email);
      } catch (error) {
        setState(() => _error = AuthService.plainError(error));
      } finally {
        setState(() => _busy = false);
      }
      return;
    }
    final String? passwordError = validatePassword(password);
    if (passwordError != null) {
      setState(() => _error = passwordError);
      return;
    }
    if (_mode == _AuthMode.signUp) {
      final String? matchError = validatePasswordMatch(
        password,
        _confirmController.text,
      );
      if (matchError != null) {
        setState(() => _error = matchError);
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_mode == _AuthMode.signUp) {
        await _auth.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // A Google sign in earlier found this email on an existing
      // account. The password sign in just succeeded, so link the
      // Google account to it now: one account, both sign in
      // methods, never two accounts for the same person.
      if (_auth.hasPendingGoogleLink) {
        try {
          await _auth.linkPendingGoogleCredential();
          if (mounted) {
            setState(() {
              _notice = 'Google account linked to this account.';
            });
          }
        } catch (error) {
          if (mounted) {
            setState(() => _error = AuthService.plainError(error));
          }
        }
      }
    } catch (error) {
      setState(() => _error = AuthService.plainError(error));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _submitGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await _auth.signInWithGoogle();
    } on GoogleLinkNeededException catch (error) {
      // This Google email already has an email and password
      // account. Prefill that email and ask for the password once;
      // _submitEmail links the Google account right after.
      if (mounted) {
        setState(() {
          _mode = _AuthMode.signIn;
          if (error.email != null) {
            _emailController.text = error.email!;
          }
          _error =
              'An account already exists for this email. Sign in with '
              'your password once to link Google to it.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = AuthService.plainError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = switch (_mode) {
      _AuthMode.signIn => 'Sign in',
      _AuthMode.signUp => 'Create account',
      _AuthMode.forgot => 'Forgot password',
    };
    final String submitLabel = switch (_mode) {
      _AuthMode.signIn => 'Sign In',
      _AuthMode.signUp => 'Create Account',
      _AuthMode.forgot => 'Send reset link',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Dharm Guru Shrinkhala')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.themed(context, AppTextStyles.title),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_mode == _AuthMode.forgot && _resetSentTo != null)
            Text(
              'Reset link sent to $_resetSentTo. Open your email, tap the link, and set a new password. Then sign in with the new password.',
              style: AppTextStyles.themed(context, AppTextStyles.body),
            )
          else ...<Widget>[
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_mode != _AuthMode.forgot) ...<Widget>[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_mode == _AuthMode.signUp)
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                ),
              if (_mode == _AuthMode.signUp)
                const SizedBox(height: AppSpacing.md),
            ],
            if (_error != null) ...<Widget>[
              Text(
                _error!,
                style: AppTextStyles.themed(context, AppTextStyles.body)
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_notice != null) ...<Widget>[
              Text(
                _notice!,
                style: AppTextStyles.themed(context, AppTextStyles.body),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            ElevatedButton(
              onPressed: _busy ? null : _submitEmail,
              child: Text(submitLabel),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Google sign in is on sign in and on create account
          // both, so a new user can start with Google and an
          // existing user can link it from either screen.
          if (_mode != _AuthMode.forgot) ...<Widget>[
            OutlinedButton(
              onPressed: _busy ? null : _submitGoogle,
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (_mode == _AuthMode.signIn)
            // One tight row: Forgot password on the left, Create
            // account on the right. Never stacked full width links
            // with dead space between them.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: TextButton(
                    onPressed:
                        _busy ? null : () => _showMode(_AuthMode.forgot),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed:
                        _busy ? null : () => _showMode(_AuthMode.signUp),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Create account',
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          if (_mode != _AuthMode.signIn)
            TextButton(
              onPressed: _busy ? null : () => _showMode(_AuthMode.signIn),
              child: const Text('Back to sign in'),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sign in is needed to use the app. No kundli, matching or remedies open without it.',
            style: AppTextStyles.themed(context, AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
