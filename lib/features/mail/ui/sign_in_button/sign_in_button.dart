/// プラットフォームごとの Google サインインボタンを切り替える入口。
///
/// Web の Google Sign-In は「Google が用意したボタンからしか
/// サインインできない」という制約がある（自前のボタンから
/// authenticate() を呼ぶと例外になる）。一方ネイティブでは
/// そのボタンが無いので、自前のボタンから authenticate() を呼ぶ。
///
/// ここで `kIsWeb` による実行時分岐を使えないのは、Web 専用の
/// コードがネイティブのビルドに混ざるとコンパイルできないため。
/// DB の接続と同じく「条件付き import」で切り替える。
library;

export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart';
