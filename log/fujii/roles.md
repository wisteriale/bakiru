# 役割分担（バキる / 2人開発）

## このファイルの使い方

- **人が読む用**: 1〜5章。分担と衝突回避のルール。
- **AI に貼る用**: 6章に、そのままコピペできるプロンプトを用意してある。
  相方も AI を使うので、**担当が決まったら 6章の該当ブロックを自分の AI に貼る**こと。
- 6章のプロンプトは単体で意味が通るように書いてある（このファイルの他の章を
  読まなくても AI が動ける）。リポジトリ内で使うなら `CLAUDE.md` も読ませるとより正確。

---

## 0. 前提（プロジェクトの要約）

### アプリ

「消すのは、気持ちいい。」がコンセプトの破壊エンタメ型ごみ箱アプリ。
お祈りメールや消したい写真をアプリ内のごみ箱に入れ、
「叩き割る」「燃やす」などの演出で破壊する。

**扱う対象は2種類。**

| 対象 | 取り込み方 | 破壊したときに起きること |
| --- | --- | --- |
| 写真 | OS 標準ピッカー / 共有シート | アプリ内のコピーだけを壊す。**端末の写真は残る** |
| メール | Gmail 連携 | 演出のあと Gmail のゴミ箱へ移動。**完全削除はしない** |

破壊の直前に一言残せる「**捨て台詞**」機能があり、
中身は残さず言葉だけを保存して振り返れる。

### 技術スタック

Flutter / Dart、状態管理 flutter_riverpod、ローカル DB Drift、
写真は image_picker + receive_sharing_intent、Gmail は google_sign_in + googleapis、
演出は rive。**ネイティブコード（MethodChannel / Kotlin / Swift）は書かない。**

### フォルダ構成

```
lib/
  main.dart           ProviderScope の overrides もここ
  app.dart            MaterialApp、画面遷移
  core/               2つ以上の機能から使うものだけ
    model/            TrashItem / Destroyer / Epitaph
    db/               Drift のテーブル定義
      connection/     プラットフォーム別の接続（条件付き import）
    theme/  widgets/  platform/
  features/
    trash/            ごみ箱本体
    destroy/          演出（provider / ui/burn / ui/shatter）
    photo/            写真の取り込み
    mail/             Gmail 連携
    share_intake/     共有シート受け取り
    epitaph/          捨て台詞
```

各機能は `repository` / `provider` / `ui` の3層。
`ui` は **provider 経由でのみ** repository を呼ぶ。
**機能どうしを直接 import しない**（共有したくなったら `core/` に上げる）。

### 共通の型

- `TrashItem` … id, type（`TrashItemType`: photo / mail / text）, title,
  thumbnailPath, addedAt, purgeAt, payload
- `Destroyer` … `bool supports(TrashItem)` / `Future<void> destroy(TrashItem)`
  - `LocalCopyDestroyer`（photo / text 用）→ `features/photo/repository/`
  - `GmailTrashDestroyer`（mail 用）→ `features/mail/repository/`
- `Epitaph` … id, text, type, title, destroyedAt, destroyMethod
  - `TrashItem` とは別テーブル。**元データの中身は一切含めない**

詳細は `CLAUDE.md` を参照。

---

## 1. 分担の大原則

### ① 分担は「フォルダ単位」で持つ

`features/<機能名>/` を1人が丸ごと持つ。
同じ機能を「モデルは自分、UI は相方」と横に切ると必ず衝突する。
**縦（機能）で切って、横（層）で切らない。**

### ② `core/` は分担せず、最初に2人で決める

`core/` は両方から使うので、片方が勝手に変えると相手が止まる。
**Day 0 に2人で一気に決めて、以降は原則凍結。**

### ③ 待たないために「境界」を先に切る

B が画面を作るのに A の DB 完成を待つ、という状態を作らない。
`abstract class` だけ先に決めれば、
**A は本物の実装、B は偽実装（Fake）を相手に、同時に作れる。**

```dart
// Day 0 に2人で決めるのはこれだけ。中身は空でいい
abstract class TrashRepository {
  Stream<List<TrashItem>> watchAll();
  Future<void> add(TrashItem item);
  Future<void> remove(String id);
}
```

B は `FakeTrashRepository`（固定のダミー3件を返すだけ）を書き、
`main.dart` の `ProviderScope.overrides` で差し替えて画面を作る。
A が本物を完成させたら override を外すだけで繋がる。

---

## 2. 担当A — データと外部連携

| 範囲 | 内容 |
| --- | --- |
| `core/db/` | Drift のテーブル定義、マイグレーション、build_runner |
| `features/trash/` | ごみ箱の CRUD、`purgeAt` の管理 |
| `features/mail/` | Gmail の OAuth、一覧取得、`GmailTrashDestroyer` |

**重いのは Gmail。** Google Cloud Console でのクライアント ID 作成、
テストユーザー登録、スコープ設定は、コードより設定作業と待ち時間が多い。
**最初に着手して、詰まっている間に DB を進める**のが正解。

スコープは `gmail.readonly`（一覧）と `gmail.modify`（ゴミ箱移動）の**2つだけ**。
完全削除に必要な制限付きスコープは要求しない（OAuth 審査が必要になるため）。

---

## 3. 担当B — 体験とUI

| 範囲 | 内容 |
| --- | --- |
| `core/theme/`, `core/widgets/`, `app.dart` | 配色、共通パーツ、画面遷移 |
| `features/destroy/` | Rive 演出、`Destroyer` の振り分け |
| `features/epitaph/` | 捨て台詞の入力と一覧 |
| `features/photo/` | image_picker → アプリ内コピー、`LocalCopyDestroyer` |
| `features/share_intake/` | 共有シート受け取り |

**重いのは `destroy/`。** Rive のアニメーション作成はコードと別スキルで時間が読めない。
**「叩き割る」1本を先に完成させ、「燃やす」は余力で。**
演出が2種類ないと成立するアプリではない。

`photo` と `share_intake` を B に寄せたのは、どちらも
「取り込んで `TrashItem` に変換するだけ」で UI との距離が近いため。

---

## 4. どちらを取るか決める基準

分量はだいたい釣り合っているので**好みで決めてよい**。

- Rive を触りたい／見た目を作りたい → **B**
- Google Cloud Console やデータ設計が苦にならない → **A**

強いて言えば、Gmail 連携は環境依存のエラーが多く人に聞きづらいので、
**粘り強い方が A を取る**と進みが良い。

---

## 5. 進め方と衝突回避

### Day 0 — 2人で（1〜2時間、ペアで1台）

ここだけは分担しない。**飛ばすと以降ずっと衝突する。**

1. `lib/core/model/trash_item.dart` の確定
   （現状 `TrashType` のままなので `TrashItemType` に改名し、
   値を `photo` / `mail` / `text` の3つに整理する）
2. `Epitaph` 型の追加
3. `core/db/` のテーブル定義（`trash_items` と `epitaphs` の2つ）
4. 各 `abstract class` の宣言だけ
   （`TrashRepository` / `PhotoRepository` / `MailRepository`）
5. これを**1つの PR でマージしてしまう**

### 以降 — 並行

A は本物の実装、B は Fake 相手に画面と演出。互いに待たない。

### 合流ポイント

「B の演出画面が、A の本物の DB を読む」ところ。
ここは**2人で1台の前に座って**繋ぐのが速い。
リモートで PR を往復させると半日溶ける。

### 衝突しやすいファイル

| ファイル | 誰が持つか | 対策 |
| --- | --- | --- |
| `core/db/database.dart` | **A のみ** | B が `epitaphs` テーブルを足したくなったら A に頼む |
| `*.g.dart` | — | 手で直さない。コンフリクトしたら build_runner で作り直す |
| `main.dart` の overrides | **B のみ** | A が本物を繋ぐときだけ声をかける |
| `app.dart`（画面遷移） | **B のみ** | A は画面を追加しない |
| `pubspec.yaml` | 両方 | パッケージを足したら**その日のうちに PR を出す**。溜めると必ず衝突 |

### `database.dart` の衝突を減らすコツ

テーブル定義を1ファイルに書かず分けておくと、A と B が同時に触れる。

```
core/db/
  database.dart          @DriftDatabase(tables: [...]) の宣言だけ
  tables/
    trash_items.dart     A が持つ
    epitaphs.dart        B が持つ
```

`database.dart` 本体を触るのは「テーブルを1行足すとき」だけになる。

### 運用ルール

- 相方も `log/<名前>/progress.md` を作る。
  「昨日どこまでやったか」「何で詰まっているか」を非同期で読めるようにする。
- **1日1回だけ、5分の同期。**
  ハッカソンで一番多い事故は「相方が同じものを2回作っていた」。
- Git の手順は `log/fujii/git-flow.md` を参照。

---

## 6. AI に貼り付ける用のプロンプト

担当が決まったら、**自分の担当のブロックをまるごとコピーして AI に貼る**。
リポジトリ内で作業しているなら「まず CLAUDE.md を読んで」と一言足すとより正確。

### 6-1. 担当A 用

```markdown
あなたは Flutter アプリ「バキる」の開発を手伝います。私は2人チームの「担当A」です。

## アプリ概要
「消すのは、気持ちいい。」がコンセプトの破壊エンタメ型ごみ箱アプリ。
お祈りメールや消したい写真をアプリ内のごみ箱に入れ、
「叩き割る」「燃やす」などの演出で破壊する。
破壊の直前に一言残せる「捨て台詞」機能がある。

扱う対象は2種類。
- 写真: OS標準ピッカー/共有シートで取り込む。破壊してもアプリ内のコピーを消すだけで、
  端末の写真ライブラリには触らない（元の写真は残る）。写真ライブラリの権限は要求しない。
- メール: Gmail連携で取り込む。破壊時は Gmail API の messages.trash でゴミ箱に移動する。
  完全削除はしない。

## 技術スタック
Flutter / Dart、状態管理 flutter_riverpod、ローカルDB Drift、
Gmail連携 google_sign_in + googleapis、写真 image_picker + receive_sharing_intent、
演出 rive。ネイティブコード（MethodChannel / Kotlin / Swift）は書かない。

## フォルダ規約
lib/core/ に2つ以上の機能から使うものを置く（model, db, theme, widgets, platform）。
lib/features/<機能名>/ の下は repository / provider / ui の3層。
ui は provider 経由でのみ repository を呼ぶ。機能どうしを直接 import しない。

## 共通の型
- TrashItem: id, type（TrashItemType: photo / mail / text）, title, thumbnailPath,
  addedAt, purgeAt, payload
  payload の中身は type で決まる。photo はアプリ内コピーのファイルパス、
  mail は Gmail の messageId・送信者・件名・日付、text は共有されたテキストやURL。
- Destroyer: bool supports(TrashItem) と Future<void> destroy(TrashItem) の2メソッド。
  実装は2つだけ。LocalCopyDestroyer（photo/text用）と GmailTrashDestroyer（mail用）。
- Epitaph（捨て台詞）: id, text, type, title, destroyedAt, destroyMethod。
  TrashItem とは別テーブルで、元データの中身は一切含めない。

## 私（担当A）の担当範囲
- lib/core/db/ … Drift のテーブル定義、マイグレーション、build_runner
- lib/features/trash/ … ごみ箱の CRUD、purgeAt の管理
- lib/features/mail/ … Gmail の OAuth、一覧取得、GmailTrashDestroyer
Gmail のスコープは gmail.readonly と gmail.modify の2つだけ。
完全削除に必要な制限付きスコープは要求しない。

## 触ってはいけない範囲（相方=担当Bの担当）
lib/app.dart、lib/main.dart の ProviderScope.overrides、
lib/core/theme/、lib/core/widgets/、
lib/features/destroy/、lib/features/epitaph/、lib/features/photo/、
lib/features/share_intake/。
これらに変更が必要だと判断したら、勝手に編集せず私に伝えてください。

## プロダクト方針（実装の都合で曲げない）
- 写真について、端末の写真が消えたと誤認させる文言・演出は禁止。
- メールは「Gmailのゴミ箱に移動、30日後に自動削除」と明示する。完全削除しない。
- 破壊が Gmail API で失敗したら、演出のあとに失敗を通知しアイテムをごみ箱に戻す。
  失敗を黙って握りつぶさない。

## コーディング規約
- lint は very_good_analysis。public メンバーには必ず doc コメントを付ける。
  1行80文字以内。import は package: 形式（相対 import は使わない）。
- 生成ファイル（*.g.dart）はコミットするが手では編集しない。
- コミットメッセージは Conventional Commits 形式（日本語可）。
  例: feat(mail): Gmailの一覧取得を追加

## 私について
大学3年生で、非同期処理・DI・コード生成は学習中です。
- コードを書いたら、コメントとは別に「なぜそう書いたか」を短く説明してください。
- 私が分からなそうな概念が出てきたら、勝手に進めず確認の質問をしてください。
- 過剰な抽象化はしないでください。まず単純に解いてください。
```

### 6-2. 担当B 用

```markdown
あなたは Flutter アプリ「バキる」の開発を手伝います。私は2人チームの「担当B」です。

## アプリ概要
「消すのは、気持ちいい。」がコンセプトの破壊エンタメ型ごみ箱アプリ。
お祈りメールや消したい写真をアプリ内のごみ箱に入れ、
「叩き割る」「燃やす」などの演出で破壊する。
破壊の直前に一言残せる「捨て台詞」機能がある。

扱う対象は2種類。
- 写真: OS標準ピッカー/共有シートで取り込む。破壊してもアプリ内のコピーを消すだけで、
  端末の写真ライブラリには触らない（元の写真は残る）。写真ライブラリの権限は要求しない。
- メール: Gmail連携で取り込む。破壊時は Gmail API の messages.trash でゴミ箱に移動する。
  完全削除はしない。

## 技術スタック
Flutter / Dart、状態管理 flutter_riverpod、ローカルDB Drift、
写真 image_picker + receive_sharing_intent、Gmail連携 google_sign_in + googleapis、
演出 rive。ネイティブコード（MethodChannel / Kotlin / Swift）は書かない。

## フォルダ規約
lib/core/ に2つ以上の機能から使うものを置く（model, db, theme, widgets, platform）。
lib/features/<機能名>/ の下は repository / provider / ui の3層。
ui は provider 経由でのみ repository を呼ぶ。機能どうしを直接 import しない。

## 共通の型
- TrashItem: id, type（TrashItemType: photo / mail / text）, title, thumbnailPath,
  addedAt, purgeAt, payload
- Destroyer: bool supports(TrashItem) と Future<void> destroy(TrashItem) の2メソッド。
  実装は2つだけ。LocalCopyDestroyer（photo/text用、アプリ内のコピーとDBレコードを
  消すだけ）と GmailTrashDestroyer（mail用、担当Aが作る）。
- Epitaph（捨て台詞）: id, text, type, title, destroyedAt, destroyMethod。
  TrashItem とは別テーブルで、元データの中身は一切含めない。

## 私（担当B）の担当範囲
- lib/app.dart、lib/main.dart の ProviderScope.overrides
- lib/core/theme/、lib/core/widgets/
- lib/features/destroy/ … Rive 演出、Destroyer の振り分け
- lib/features/epitaph/ … 捨て台詞の入力と一覧
- lib/features/photo/ … image_picker でのコピー取り込み、LocalCopyDestroyer
- lib/features/share_intake/ … 共有シート受け取り
演出は「叩き割る」を先に1本完成させ、「燃やす」は余力で作ります。

## 触ってはいけない範囲（相方=担当Aの担当）
lib/core/db/、lib/features/trash/、lib/features/mail/。
これらに変更が必要だと判断したら、勝手に編集せず私に伝えてください。

## 重要: 相方の実装を待たずに進める方針
DB とごみ箱本体は担当Aが並行して作っています。私はそれを待ちません。
abstract class（TrashRepository など）に対して偽実装（Fake）を書き、
main.dart の ProviderScope.overrides で差し替えて画面と演出を作ります。
例: FakeTrashRepository は固定のダミー3件を返すだけでよい。
本物ができたら override を外すだけで繋がるようにしてください。

## プラットフォーム方針
UIと演出は Flutter Web（Chrome）で開発・確認します。
共有シートは Web で動かないので Android エミュレータで確認します。
Web で動かない機能は abstract class の裏に隠し、kIsWeb で偽実装に差し替えます。
kIsWeb を書いてよいのは main.dart の ProviderScope.overrides だけです。

## プロダクト方針（実装の都合で曲げない）
- UI上で「端末の写真は削除されません。アプリ内の写真だけが壊れます」と初回に明示し、
  設定画面からも確認できるようにする。
- 端末の写真が消えたと誤認させる文言・演出は禁止。
  写真に対して「完全に消しました」「復元できません」のような表現を使わない。
- メールは「Gmailのゴミ箱に移動、30日後に自動削除」と明示する。
- 破壊が失敗したら、演出のあとに失敗を通知しアイテムをごみ箱に戻す。
  演出の途中でエラーを出さない（体験が途切れるため）。ただし黙って握りつぶさない。

## コーディング規約
- lint は very_good_analysis。public メンバーには必ず doc コメントを付ける。
  1行80文字以内。import は package: 形式（相対 import は使わない）。
- 生成ファイル（*.g.dart）はコミットするが手では編集しない。
- コミットメッセージは Conventional Commits 形式（日本語可）。
  例: feat(destroy): 叩き割る演出を追加

## 私について
大学3年生で、非同期処理・DI・コード生成は学習中です。
- コードを書いたら、コメントとは別に「なぜそう書いたか」を短く説明してください。
- 私が分からなそうな概念が出てきたら、勝手に進めず確認の質問をしてください。
- 過剰な抽象化はしないでください。まず単純に解いてください。
```

### 6-3. Day 0 を2人でやるとき用

```markdown
Flutter アプリ「バキる」の土台を作ります。2人開発の初日で、
ここで作ったものを両方が使うため、あとから変えると2人分の手戻りが出ます。

以下だけを作ってください。機能の実装はまだしません。

1. lib/core/model/trash_item.dart の修正
   現在 enum が TrashType（値: photo / mail / app / shared）になっているので、
   TrashItemType に改名し、値を photo / mail / text の3つに整理する。
2. lib/core/model/epitaph.dart の新規作成
   フィールドは id, text, type（TrashItemType）, title, destroyedAt, destroyMethod。
   元データの中身は一切持たせない。
3. lib/core/db/ に Drift のテーブル定義
   trash_items と epitaphs の2テーブル。
   テーブル定義は core/db/tables/ に1ファイルずつ分ける
   （2人が同時に触っても衝突しにくくするため）。
   database.dart は @DriftDatabase(tables: [...]) の宣言だけにする。
4. abstract class の宣言だけ（中身は未実装でよい）
   - TrashRepository（watchAll / add / remove）
   - PhotoRepository
   - MailRepository

lint は very_good_analysis です。public メンバーには doc コメントを付け、
1行80文字以内、import は package: 形式にしてください。
作り終えたら flutter analyze を実行し、エラーが無いことを確認してください。

私たちは大学3年生で、非同期処理・DI・コード生成は学習中です。
コードを書いたら「なぜそう書いたか」を短く説明してください。
```
