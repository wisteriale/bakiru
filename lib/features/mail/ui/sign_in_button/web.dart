import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as web_only;

/// Web 用の Google サインインボタン。
///
/// Google が用意したボタンをそのまま置く。見た目を自前で作れないのは
/// Google Identity Services の仕様。押すと認証が始まり、結果は
/// MailRepository.watchSignedIn() に流れてくる。
Widget buildGoogleSignInButton() => web_only.renderButton();
