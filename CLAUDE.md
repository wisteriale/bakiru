# バキる (bakiru)

## アプリ概要

「消すのは、気持ちいい。」がコンセプトの、破壊エンタメ型ごみ箱アプリ。

お祈りメール・写真・アプリなどをアプリ内のごみ箱に入れ、完全消去するときに
「叩き割る」「燃やす」などの演出を再生する。捨てる行為そのものを気持ちいい体験にするのが狙い。

想定ユーザーは広く若い世代。

## 技術スタック

| 領域 | 採用技術 |
| --- | --- |
| フレームワーク | Flutter / Dart |
| 状態管理 | flutter_riverpod |
| ローカル DB | Drift（SQLite 本体は `sqlite3` 3.x が同梱するので追加の依存は不要） |
| ネイティブ連携 | photo_manager（写真）、google_sign_in + googleapis（メール）、receive_sharing_intent（共有受け取り） |
| Android のアプリ削除 | MethodChannel + 自作 Kotlin コード |
| 演出 | rive |

Android のアプリ削除だけは既存プラグインで賄えないため、MethodChannel を通して
自分たちで書いた Kotlin を呼び出す。

## プラットフォーム方針

- UI と演出は **Flutter Web** で開発・確認する（ホットリロードが速く、実機がいらないため）。
- OS 連携（写真・共有・アプリ削除）は **Android エミュレータ** で確認する。
- **iOS** は節目ごとに Mac の実機で確認する。
- Web で動かない機能は `abstract class` の裏に隠し、`kIsWeb` で偽実装（フェイク）に差し替える。
  - 例: `abstract class PhotoRepository` を用意し、Web では固定のダミー写真を返す実装を注入する。
  - これにより「Web で UI を作る → 実機で本物の実装に差し替える」が同じコードのまま成立する。
- **`kIsWeb` を書いてよいのは `main.dart` の `ProviderScope.overrides` だけ。**
  features 配下のコードは自分がどのプラットフォームで動いているかを知らなくてよい。
  分岐が散らばると「今どっちの実装が動いているか」を追えなくなるため。
- **DB だけは例外で `kIsWeb` を使わない。** Web は WebAssembly、ネイティブは共有ライブラリと
  SQLite の動かし方が根本から違い、`dart:io` を含むコードが Web ビルドに混ざるとコンパイルが通らない。
  そのため `core/db/connection/` で**条件付き import**（ビルド時に切り替え）を使う。
  - Web で DB を動かすには `web/` に `sqlite3.wasm` と `drift_worker.js` が必要。

## フォルダ規約

```
lib/
  main.dart           エントリポイント。ProviderScope の overrides もここ
  app.dart            MaterialApp などアプリ全体の組み立て
  core/               2つ以上の機能から使うものだけ置く
    model/            全機能が共有する型（TrashItem / Destroyer）
    db/               Drift のデータベース定義
      connection/     プラットフォーム別の接続（条件付き import）
    platform/         MethodChannel などネイティブ連携の共通部分
    theme/            配色・テキストスタイル
    widgets/          共通ウィジェット
  features/
    trash/            ごみ箱（一覧・追加・完全消去の管理）
      model/          trash だけが使う型
      repository/
      provider/
      ui/
    destroy/          消去演出
      provider/       Destroyer を supports で振り分けて実行する
      ui/
        burn/         燃やす
        shatter/      叩き割る
    photo/            以下は model を持たない（core の TrashItem で足りるため）
      repository/     PhotoDestroyer もここに置く
      provider/
      ui/
    mail/             photo と同じ構成
    app_uninstall/    photo と同じ構成
    share_intake/     共有を受け取って TrashItem に変換するだけ
      repository/
      provider/
```

ルール:

- `ui` は **provider 経由でのみ** repository を呼ぶ。`ui` から repository を直接 import しない。
- 2つ以上の機能から使うものだけ `core/` に置く。1つの機能でしか使わないものは features 配下に置いたままにする。
- **機能どうしを直接 import しない。** 共有したくなったら `core/` に上げる。
- 各機能の `Destroyer` 実装は、その機能の `repository/` に置く
  （例: `features/photo/repository/photo_destroyer.dart`）。
  `destroy/provider/` はそれらを集めて振り分けるだけ。
- フォルダは**必要になってから作る**。使わない空フォルダは置かない。
- テストは `test/features/<機能名>/` に lib と同じ構造で置く。

## 共通の型

すべての機能が扱う共通のデータは `TrashItem`（`lib/core/model/trash_item.dart`）。
全機能から使うので `features/trash/` ではなく `core/` に置いている。

| フィールド | 意味 |
| --- | --- |
| `id` | 一意な ID（uuid） |
| `type` | 種別（写真 / メール / アプリ など） |
| `title` | 一覧に出す表示名 |
| `thumbnailPath` | サムネイル画像のパス |
| `addedAt` | ごみ箱に入れた日時 |
| `purgeAt` | 完全消去する予定の日時 |
| `payload` | 種別ごとの追加情報 |

削除処理は `Destroyer` インターフェース（`lib/core/model/destroyer.dart`）を実装する。

```dart
abstract class Destroyer {
  bool supports(TrashItem item);
  Future<void> destroy(TrashItem item);
}
```

`supports` で「この Destroyer が扱える種別か」を判定し、`destroy` で実際に消す。
新しい種別を足すときは、その機能の `repository/` に `Destroyer` を1つ足して
`destroy/provider/` の一覧に登録するだけで済む。

## コーディング規約

- Lint は `very_good_analysis` に従う（`analysis_options.yaml` で include 済み）。
- 生成ファイル（`*.g.dart`）は**コミットするが、手で編集しない**。
  変更したいときは元の定義を直して `dart run build_runner build` を回す。
- コミットメッセージは Conventional Commits 形式。日本語で書いてよい。
  - 例: `feat(trash): ごみ箱一覧の画面を追加`
  - 例: `fix(photo): サムネイルが表示されない不具合を修正`

## Git 運用

- `main` への直接 push は禁止。
- `feature/<内容>` ブランチを切って作業し、Pull Request でマージする。

## 開発者向けの注意（Claude へ）

- 開発者は大学3年生2人。**非同期処理・DI・コード生成は学習中**。
- コードを書いたら、コード中のコメントとは別に「**なぜそう書いたか**」を短く説明すること。
- 開発者が分からなそうな概念（`Future`/`Stream`、Riverpod の依存注入、build_runner の生成など）が
  出てきたら、勝手に進めず確認の質問をすること。
- 過剰な抽象化はしない。まず単純に解く。

## 禁止事項

- API キー、`google-services.json`、`GoogleService-Info.plist` などの秘密情報をコミットしない
  （`.gitignore` に登録済み）。
- `main` ブランチへの直接 push。
- 生成ファイルの手編集。
