import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).authError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = ref.read(authServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_register ? l.authRegisterTitle : l.authSignInTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l.email),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('password'),
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: l.password),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                key: const ValueKey('submit'),
                onPressed: _busy
                    ? null
                    : () => _run(() => _register
                        ? auth.registerWithEmail(_email.text.trim(), _password.text)
                        : auth.signInWithEmail(_email.text.trim(), _password.text)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(_register ? l.register : l.signIn),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _run(auth.signInWithGoogle),
                icon: const Icon(Icons.account_circle),
                label: Text(l.signInWithGoogle),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _run(auth.signInWithApple),
                icon: const Icon(Icons.apple),
                label: Text(l.signInWithApple),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() => _register = !_register),
                child: Text(
                  _register ? l.authToggleToSignIn : l.authToggleToRegister,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
