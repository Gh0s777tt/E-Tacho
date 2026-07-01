import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_service.dart';

/// Real [AuthService] backed by Supabase. Wired in only when Supabase is
/// configured (see [SupabaseConfig]); otherwise the app uses the stub.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final sb.SupabaseClient _client;

  AuthUser? _map(sb.User? user) =>
      user == null ? null : AuthUser(id: user.id, email: user.email);

  @override
  AuthUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AuthUser?> authState() async* {
    yield currentUser;
    yield* _client.auth.onAuthStateChange.map((e) => _map(e.session?.user));
  }

  @override
  Future<void> signInWithEmail(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> registerWithEmail(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  // OAuth needs provider config in Supabase + platform deep links.
  @override
  Future<void> signInWithGoogle() =>
      _client.auth.signInWithOAuth(sb.OAuthProvider.google);

  @override
  Future<void> signInWithApple() =>
      _client.auth.signInWithOAuth(sb.OAuthProvider.apple);

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> dispose() async {}
}
