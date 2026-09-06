import 'package:flutter/widgets.dart';

/// Web でもネイティブでもないプラットフォーム用。
///
/// 実際に呼ばれることはない。条件付き import の既定値として必要。
Widget buildGoogleSignInButton() {
  throw UnsupportedError('このプラットフォームでは Google サインインを使えません。');
}
