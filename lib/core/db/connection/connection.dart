/// プラットフォームごとの DB 接続を切り替える入口。
///
/// Web とネイティブでは SQLite の動かし方が根本的に違う。
/// ネイティブは共有ライブラリ、Web は WebAssembly を読み込む。
///
/// ここで `kIsWeb` による実行時分岐を使えないのは、Web ビルドに
/// `dart:io` を使うコードが混ざるとコンパイル自体が通らないため。
/// 「条件付き import」ならビルド時に片方しか読み込まれないので解決する。
///
/// 使う側は `openConnection()` を呼ぶだけでよい。
library;

export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.js_interop) 'web.dart';
