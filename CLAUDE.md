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
| ローカル DB | Drift（+ sqlite3_flutter_libs） |
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

## フォルダ規約

```
lib/
  main.dart           エントリポイント
  app.dart            MaterialApp などアプリ全体の組み立て
  core/               2つ以上の機能から使うものだけ置く
    db/               Drift のデータベース定義
    platform/         MethodChannel などネイティブ連携の共通部分
    theme/            配色・テキストスタイル
    widgets/          共通ウィジェット
  features/<機能名>/
    model/            データの形（TrashItem など）
    repository/       データの取得・保存（DB / OS API を叩くのはここだけ）
    provider/         Riverpod のプロバイダ。状態と、repository の呼び出し
    ui/               画面とウィジェット
```

ルール:

- `ui` は **provider 経由でのみ** repository を呼ぶ。`ui` から repository を直接 import しない。
- 2つ以上の機能から使うものだけ `core/` に置く。1つの機能でしか使わないものは features 配下に置いたままにする。
- 機能は `trash` / `destroy` / `photo` / `mail` / `app_uninstall` / `share_intake` の6つ。
  `destroy` だけは演出の種類ごとに `burn/` `shatter/` に分かれる。
- テストは `test/features/<機能名>/` に lib と同じ構造で置く。

## 共通の型

すべての機能が扱う共通のデータは `TrashItem`。

| フィールド | 意味 |
| --- | --- |
| `id` | 一意な ID（uuid） |
| `type` | 種別（写真 / メール / アプリ など） |
| `title` | 一覧に出す表示名 |
| `thumbnailPath` | サムネイル画像のパス |
| `addedAt` | ごみ箱に入れた日時 |
| `purgeAt` | 完全消去する予定の日時 |
| `payload` | 種別ごとの追加情報 |

削除処理は `Destroyer` インターフェースを実装する。

```dart
abstract class Destroyer {
  bool supports(TrashItem item);
  Future<void> destroy(TrashItem item);
}
```

`supports` で「この Destroyer が扱える種別か」を判定し、`destroy` で実際に消す。
新しい種別を足すときは `Destroyer` を1つ増やすだけで済むようにする。

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
