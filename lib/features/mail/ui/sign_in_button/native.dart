
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Android / iOS 用の Google サインインボタン。
///
/// ネイティブでは authenticate() を自前のボタンから呼べる。
Widget buildGoogleSignInButton() => const _AuthenticateButton();

class _AuthenticateButton extends StatelessWidget {
  const _AuthenticateButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        await GoogleSignIn.instance.authenticate();
      },
      icon: const Icon(Icons.login),
      label: const Text('Google でサインイン'),
    );
  }
}
