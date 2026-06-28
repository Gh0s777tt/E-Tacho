import 'dart:async';

/// Authenticated user (minimal shape for the MVP).
class AuthUser {
  const AuthUser({required this.id, this.email, this.displayName});

  final String id;
  final String? email;
  final String? displayName;
}

/// Authentication abstraction. The MVP ships an in-memory [StubAuthService];
/// a Supabase-backed implementation drops in behind the same interface once a
/// project URL + anon key are available.
abstract class AuthService {
  Stream<AuthUser?> authState();
  AuthUser? get currentUser;
  Future<void> signInWithEmail(String email, String password);
  Future<void> registerWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> dispose();
}

class StubAuthService implements AuthService {
  StubAuthService({AuthUser? initialUser}) : _user = initialUser;

  AuthUser? _user;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authState() async* {
    yield _user;
    yield* _controller.stream;
  }

  void _set(AuthUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async =>
      _set(AuthUser(id: 'stub-$email', email: email));

  @override
  Future<void> registerWithEmail(String email, String password) async =>
      _set(AuthUser(id: 'stub-$email', email: email));

  @override
  Future<void> signInWithGoogle() async =>
      _set(const AuthUser(id: 'stub-google', displayName: 'Google user'));

  @override
  Future<void> signInWithApple() async =>
      _set(const AuthUser(id: 'stub-apple', displayName: 'Apple user'));

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
