# バキる (bakiru)

> 消すのは、気持ちいい。

お祈りメール・写真・使わなくなったアプリなどをアプリ内のごみ箱に放り込み、
完全消去するときに「叩き割る」「燃やす」といった演出を再生する、破壊エンタメ型のごみ箱アプリ。

Flutter 製で、Android / iOS / Web で動く。

## 技術スタック

- Flutter / Dart
- 状態管理: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- ローカル DB: [drift](https://pub.dev/packages/drift)
- ネイティブ連携: photo_manager（写真）、google_sign_in + googleapis（メール）、receive_sharing_intent（共有受け取り）
- 演出: [rive](https://pub.dev/packages/rive)
- Android のアプリ削除のみ MethodChannel 経由で自作 Kotlin を呼び出す

## 環境構築

前提: Flutter SDK（stable）がインストール済みで、`flutter doctor` が通ること。

```bash
# 1. 依存パッケージを取得
flutter pub get

# 2. Drift などのコード生成ファイル（*.g.dart）を生成
dart run build_runner build

# 3. Chrome で起動（UI と演出の開発はここ）
flutter run -d chrome
```

コード生成をしないと `*.g.dart` が無くてビルドが通らないので、
`flutter pub get` の直後と、DB のテーブル定義を変えたあとは必ず 2 を実行する。

生成ファイルを作り直しながら開発したいときは、監視モードが便利:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Web で DB を使うとき

Drift は Web だと SQLite を WebAssembly で動かすため、`web/` に次の2つが必要。
未配置のまま Chrome で DB を触ると実行時にエラーになる。

- `sqlite3.wasm`
- `drift_worker.js`

入手方法は [Drift の Web セットアップ](https://drift.simonbinder.eu/platforms/web/) を参照。
接続の切り替え自体は `lib/core/db/connection/` が条件付き import で行うので、
呼ぶ側は `openConnection()` を使うだけでよい。

### OS 連携を確認したいとき

写真・共有・アプリ削除などは Web では動かないので、エミュレータ／実機で確認する。

```bash
flutter run -d <android-device-id>   # Android エミュレータ
flutter run -d <ios-device-id>       # iOS（Mac 実機）
```

Android は `minSdk = 30` を前提にしている。

## フォルダ構成

```
lib/
  main.dart           エントリポイント。ProviderScope の overrides もここ
  app.dart            MaterialApp などアプリ全体の組み立て
  core/               2つ以上の機能から使う共通コード
    model/              全機能が共有する型（TrashItem / Destroyer）
    db/                 Drift のデータベース定義
      connection/         プラットフォーム別の接続（条件付き import）
    platform/           MethodChannel などネイティブ連携の共通部分
    theme/              配色・テキストスタイル
    widgets/            共通ウィジェット
  features/           機能ごとのコード
    trash/              ごみ箱（一覧・追加・完全消去の管理）
    destroy/            消去演出
      provider/           Destroyer を振り分けて実行する
      ui/burn/            燃やす
      ui/shatter/         叩き割る
    photo/              写真の取り込み
    mail/               メール（お祈りメール）の取り込み
    app_uninstall/      アプリの削除
    share_intake/       他アプリからの共有受け取り
test/
  features/           lib と同じ構造でテストを置く
```

各機能は下に `repository` / `provider` / `ui` の3層を持つ。
その機能だけが使う型が必要になったら `model` を足す。

| 層 | 役割 |
| --- | --- |
| `model` | その機能だけが使う型。共通の型は `core/model/` にある |
| `repository` | データの取得・保存。DB や OS の API を叩くのはここだけ |
| `provider` | Riverpod のプロバイダ。状態を持ち、repository を呼ぶ |
| `ui` | 画面とウィジェット。repository は **provider 経由でのみ**呼ぶ |

すべての機能は `TrashItem` を介してやり取りし、**機能どうしを直接 import しない**。
削除処理は `Destroyer` インターフェースを各機能の `repository/` に実装し、
`destroy/provider/` が `supports()` で振り分けて実行する。

## 開発ルール

- `main` への直接 push は禁止。`feature/` ブランチ + Pull Request で進める。
- Lint は `very_good_analysis`。コミット前に `flutter analyze` を通す。
- `*.g.dart` はコミットするが手では編集しない。
- API キーや `google-services.json` などの秘密情報はコミットしない。

詳しい方針は [CLAUDE.md](CLAUDE.md) を参照。
