# バキる (bakiru)

## アプリ概要

「消すのは、気持ちいい。」がコンセプトの、破壊エンタメ型ごみ箱アプリ。

お祈りメールや消したい写真をアプリ内のごみ箱に入れ、
「叩き割る」「燃やす」などの演出で破壊する。
捨てる行為そのものを気持ちいい体験にするのが狙い。

想定ユーザーは広く若い世代。

### 扱う対象は2種類

| 対象 | 取り込み方 | 破壊したときに起きること |
| --- | --- | --- |
| 写真 | OS 標準ピッカー / 共有シート | **アプリ内に取り込んだコピーだけ**を壊す。端末の写真ライブラリには触らないので、元の写真は残る |
| メール | Gmail 連携 | 演出のあと Gmail API で**ゴミ箱に移動**する。完全削除はしない |

写真で端末のライブラリを触らないのは、取り返しのつかない削除をアプリの中心に
置きたくないため。写真ライブラリの権限も要求せずに済む。

### 捨て台詞

破壊の直前に、ユーザーが一言残せる。
消したものの**中身は一切残さず、言葉だけ**を保存し、あとから振り返れる。

## プロダクト方針

**ここはユーザーへの約束なので、実装の都合で曲げない。**

### 写真

- 「**端末の写真は削除されません。アプリ内の写真だけが壊れます**」と初回に明示する。
  設定画面からもいつでも確認できるようにする。
- 端末の写真が消えたとユーザーに誤認させる文言・演出は**禁止**。
  写真に対して「完全に消しました」「復元できません」のような表現を使わない。

### メール

- 「**Gmail のゴミ箱に移動します。30日後に Gmail 側で自動削除されます**」と明示する。
- 完全削除は行わない。

### 失敗したとき

- 破壊操作が Gmail API で失敗した場合は、**演出のあとに失敗を通知**し、
  アイテムをごみ箱に戻す。
- 演出の途中でエラーを出さないのは、体験が途切れるのを避けるため。
  ただし「失敗を黙って握りつぶす」のは禁止。必ずユーザーに伝える。

## 技術スタック

| 領域 | 採用技術 |
| --- | --- |
| フレームワーク | Flutter / Dart |
| 状態管理 | flutter_riverpod |
| ローカル DB | Drift（SQLite 本体は `sqlite3` 3.x が同梱するので追加の依存は不要） |
| 写真の取り込み | image_picker（OS 標準ピッカー）、receive_sharing_intent（共有シート） |
| Gmail 連携 | google_sign_in + googleapis |
| 演出 | rive |

- **photo_manager は使わない。** 写真ライブラリ全体へのアクセス権限が必要になるため。
  OS 標準ピッカーと共有シートなら、ユーザーが選んだものだけが渡ってくる。
  **写真ライブラリへのアクセス権限は要求しない。**
- Gmail のスコープは `gmail.readonly`（一覧の取得）と `gmail.modify`（ゴミ箱移動）の**2つだけ**。
  完全削除に必要な制限付きスコープは要求しない。
- **ネイティブコード（MethodChannel）は現時点で不要。** Kotlin / Swift は書かない。

## プラットフォーム方針

- UI と演出は **Flutter Web** で開発・確認する（ホットリロードが速く、実機がいらないため）。
- **Gmail 連携は Web でも動く**ので、Chrome で確認してよい。
- **共有シートは Web で動かない**ため、**Android エミュレータ**で確認する。
- **iOS** は節目ごとに Mac の実機で確認する。
- Web で動かない機能は `abstract class` の裏に隠し、`kIsWeb` で偽実装（フェイク）に差し替える。
  - 例: `abstract class ShareIntakeRepository` を用意し、Web ではダミーを注入する。
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
    model/            全機能が共有する型
                      TrashItem / Destroyer / Epitaph / DestroyMethod
    db/               Drift のデータベース定義
      database.dart   どのテーブルを使うかの宣言だけ
      tables/         テーブル定義（1テーブル1ファイル）
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
    photo/            写真の取り込み。以下は model を持たない
      repository/     ピッカー/共有シートで受けた画像をアプリ内にコピーし
      provider/       TrashItem に変換する。LocalCopyDestroyer もここ
      ui/
    mail/             Gmail 連携。GmailTrashDestroyer もここ
      repository/
      provider/
      ui/
    share_intake/     共有シートから受け取って TrashItem に変換するだけ
      repository/
      provider/
    epitaph/          捨て台詞の保存と振り返り
      repository/
      provider/
      ui/
```

機能は `trash`（ごみ箱本体）/ `destroy`（演出）/ `photo`（写真の取り込み）/
`mail`（Gmail 連携）/ `share_intake`（共有シート）/ `epitaph`（捨て台詞）の6つ。

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

全機能が共有する型は `lib/core/model/` に置く。
`features/trash/` に置くと他の機能がそこを import することになるため。

### DB のテーブルとの関係

`core/model/` の手書きの型と、Drift が生成するテーブルのクラスは**別物**にする。

| ドメイン型（手書き） | テーブル（Drift が生成） |
| --- | --- |
| `TrashItem` | `TrashItemRow` |
| `Epitaph` | `EpitaphRow` |

変換は **repository の責務**。
「`Map` をそのまま保存できない」「enum をそのまま保存できない」といった
DB の都合はテーブル側に閉じ込める。こうするとドメイン型が Drift に
依存しないので、Web の偽実装（Fake）でも同じ型をそのまま使える。

- `payload` は DB では `payloadJson`（JSON 文字列）1カラムに入れる。
- enum は index ではなく**名前**で保存する（`textEnum`）。
  あとで並び順を変えても既存データが壊れないため。
- テーブル定義は `core/db/tables/` に1ファイルずつ置く。
  `database.dart` は「どのテーブルを使うか」の宣言だけにして、
  2人が別のテーブルを同時に触っても衝突しにくくしている。

### TrashItem

ごみ箱に入っているもの1件（`lib/core/model/trash_item.dart`）。

| フィールド | 意味 |
| --- | --- |
| `id` | 一意な ID（uuid） |
| `type` | `TrashItemType`（`photo` / `mail` / `text`） |
| `title` | 一覧に出す表示名 |
| `thumbnailPath` | サムネイル画像のパス |
| `addedAt` | ごみ箱に入れた日時 |
| `purgeAt` | 完全消去する予定の日時 |
| `payload` | 種別ごとの追加情報 |

`payload` の中身は `type` で決まる。

| `type` | `payload` に入れるもの |
| --- | --- |
| `photo` | アプリ内にコピーした画像のファイルパス |
| `mail` | Gmail の `messageId`、送信者、件名、日付 |
| `text` | 共有されてきたテキストや URL |

### Destroyer

削除処理のインターフェース（`lib/core/model/destroyer.dart`）。

```dart
abstract class Destroyer {
  bool supports(TrashItem item);
  Future<void> destroy(TrashItem item);
}
```

`supports` で「この Destroyer が扱える種別か」を判定し、`destroy` で実際に消す。
実装は**2つだけ**。

| 実装 | 担当する `type` | やること | 置き場所 |
| --- | --- | --- | --- |
| `LocalCopyDestroyer` | `photo` / `text` | アプリ内のコピーと DB レコードを消すだけ | `features/photo/repository/` |
| `GmailTrashDestroyer` | `mail` | Gmail API の `messages.trash` を呼んだあと、アプリ内レコードを消す | `features/mail/repository/` |

`LocalCopyDestroyer` が端末の写真ライブラリを触ることは**ない**。
消すのはアプリ内のコピーだけ。

### Epitaph（捨て台詞）

破壊の直前にユーザーが残した一言。`TrashItem` とは**別テーブル**に保存する。

| フィールド | 意味 |
| --- | --- |
| `id` | 一意な ID（uuid） |
| `text` | ユーザーが残した言葉 |
| `type` | 何を捨てたときのものか（`TrashItemType`） |
| `title` | 捨てたものの表示名 |
| `destroyedAt` | 破壊した日時 |
| `destroyMethod` | どの演出で壊したか（燃やす / 叩き割る） |

**元データの中身は一切含めない。** 写真そのものやメール本文は残さない。
「消したはずのものがアプリ内に残っている」状態を作らないため。
別テーブルにしているのも、`TrashItem` が消えても捨て台詞だけが残るようにするため。

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
