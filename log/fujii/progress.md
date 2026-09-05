# 進捗ログ（fujii）

Claude に何をやらせたか / どこまで進んだかの記録。
新しい作業をしたら、上に日付のセクションを足していく。

---

## 2026-09-05 スコープの確定（アプリ削除をやめ、捨て台詞を追加）

**ブランチ**: `fujii`（未コミット）

設計を確定させた。**コードの実装はまだしていない**（設計ファイル・フォルダ・依存のみ）。

### 方針の変更点

| 変更 | 内容 | 理由 |
| --- | --- | --- |
| アプリ削除機能を**廃止** | `app_uninstall` を削除 | OS 的に黙って消せず、体験が成立しない |
| 写真は**端末を触らない** | アプリ内のコピーだけを壊す | 取り返しのつかない削除を中心に置かない。権限も不要になる |
| メールは**ゴミ箱移動まで** | `messages.trash` を呼ぶだけ | 完全削除は制限付きスコープで OAuth 審査が必要 |
| **捨て台詞**を追加 | `epitaph` 機能を新設 | 消したものの中身を残さず、言葉だけ振り返れる |
| photo_manager → **image_picker** | OS 標準ピッカーに変更 | 写真ライブラリ全体の権限を要求しないため |
| ネイティブコード**不要**に | MethodChannel / Kotlin を書かない | アプリ削除をやめたので必要がなくなった |

### やったこと

- `CLAUDE.md` … アプリ概要 / 技術スタック / プラットフォーム方針 / 共通の型 /
  フォルダ規約を差し替え、新たに「プロダクト方針」の節を追加
- `README.md` … 機能一覧（写真 / Gmail / 捨て台詞）、必要な権限、
  フォルダ構成を更新
- `lib/features/app_uninstall/` を削除（`test/` 側は元々存在しなかった）
- `lib/features/epitaph/{repository,provider,ui}/` を新設
- `flutter pub remove photo_manager` / `flutter pub add image_picker`

### 要対応：ドキュメントとコードが食い違っている

`lib/core/model/trash_item.dart` は前回作ったままで、新しい設計と合っていない。
「コードの実装はしない」指示だったので**あえて直していない**。

| 項目 | コードの現状 | CLAUDE.md の新設計 |
| --- | --- | --- |
| enum 名 | `TrashType` | `TrashItemType` |
| 値 | `photo` / `mail` / `app` / `shared` | `photo` / `mail` / `text` |

`app` は機能ごと消えたので確実に不要。`shared` は `text` に相当する。
次にコードを触るときに合わせること。

### 積み残し

- [ ] `TrashItemType` への改名と値の整理（上記）
- [ ] `Epitaph` 型を `lib/core/model/` に追加
- [ ] `core/db/database.dart`（Drift のテーブル定義）。TrashItem と Epitaph の2テーブル
- [ ] `web/sqlite3.wasm` と `web/drift_worker.js` の配置
- [ ] Gmail の OAuth クライアント設定（google-services.json は**コミット禁止**）

---

## 2026-09-05 構成の見直し（レビュー指摘 A〜F の反映）

**ブランチ**: `fujii`（PR #1 マージ後の main から作成）

初期構成をレビューして見つかった問題を修正した。

### A. 共通の型の置き場所を `core/model/` に

`TrashItem` と `Destroyer` は全機能が使うのに置き場所が無く、
`features/trash/model/` に置くと他の機能が `features/trash/` を
import することになる（機能間の横依存）。`core/model/` を新設して解決。

- `lib/core/model/trash_item.dart` … `TrashItem` と `TrashType`
- `lib/core/model/destroyer.dart` … `Destroyer` インターフェース

### B. Drift の Web 対応（条件付き import）

「UI は Web で開発する」方針と Drift がぶつかっていた。
Web は WebAssembly、ネイティブは共有ライブラリで動かし方が違い、
`dart:io` を含むコードが Web ビルドに混ざるとコンパイルできない。
`kIsWeb`（実行時分岐）では解決しないので**条件付き import**にした。

- `lib/core/db/connection/connection.dart` … 切り替えの入口
- `native.dart` / `web.dart` / `unsupported.dart`

**未完**: Web で動かすには `web/` に `sqlite3.wasm` と `drift_worker.js` が必要。
まだ置いていないので、Web で DB を触ると実行時に落ちる。

### C. `sqlite3_flutter_libs` を削除

解決されていた `0.6.0+eol` は中身のコードが全削除された空パッケージだった
（`description: "Not used anymore, update to version 3.x of package:sqlite3 instead"`）。
`sqlite3` 3.x が自前でネイティブライブラリをビルドするため不要。

### D. `destroy/` の構成を修正

`burn` / `shatter` は実体が UI なので `ui/` の下に移動。
「どの Destroyer を使うか振り分ける」置き場所が無かったので `provider/` を追加。

```
destroy/provider/     Destroyer を supports() で振り分けて実行
destroy/ui/burn/
destroy/ui/shatter/
```

各 `Destroyer` の実装は機能側の `repository/` に置く
（例: `features/photo/repository/photo_destroyer.dart`）。

### E. 使わない空フォルダを削除

`core/model/TrashItem` で足りるので、以下を削除した。
必要になってから作る方針に変更。

- `features/{photo,mail,app_uninstall,share_intake}/model/`
- `features/share_intake/ui/`（画面を持たない機能のため）

### F. `kIsWeb` の分岐を `main.dart` の1か所に閉じた

`main.dart` を `ProviderScope` で包み、偽実装への差し替えは
ここの `overrides` だけで行う方針をコメントで明記。
features 配下は `kIsWeb` を知らずに済む。

### あわせて更新

- `CLAUDE.md` … フォルダ規約・共通の型・プラットフォーム方針を新構成に合わせた
- `README.md` … フォルダ構成、Web で DB を使うときの手順を追記

### 積み残し（次に決めること）

- [ ] `web/sqlite3.wasm` と `web/drift_worker.js` の配置。
      生成物をリポジトリに入れるか、セットアップ手順にするか要相談
- [ ] **Android のアプリ削除は「黙って消す」ことが OS 的に不可能。**
      `ACTION_DELETE` で OS の確認ダイアログが出るところまでしかできない。
      演出 → OS ダイアログ、という流れになるので UX を相方と相談する
- [ ] **Gmail の完全削除は制限付きスコープで OAuth 審査が必要。**
      ハッカソン中はテストユーザーで回避できるが、
      「Gmail のゴミ箱に移す」(`gmail.modify`) に留める方が現実的
- [ ] `core/db/database.dart`（Drift のテーブル定義）はまだ未作成

---

## 2026-09-05 プロジェクト初期構成

**ブランチ**: `feature/project-structure`（未コミット）

### やったこと

- [x] `flutter create --org com.bakiru --platforms android,ios,web .` でプロジェクト初期化
  - applicationId / bundle ID は `com.bakiru.bakiru`
- [x] 依存パッケージ追加
  - 通常: flutter_riverpod, drift, sqlite3_flutter_libs, path_provider, path, uuid,
    photo_manager, google_sign_in, googleapis, googleapis_auth,
    receive_sharing_intent, flutter_secure_storage, rive
  - dev: build_runner, drift_dev, very_good_analysis
- [x] `android/app/build.gradle.kts` の `minSdk` を 30 に固定
- [x] `analysis_options.yaml` を very_good_analysis の include に置き換え
- [x] `.gitignore` に `google-services.json` / `GoogleService-Info.plist` を追加
- [x] `lib/` のフォルダ構成を作成（末端28フォルダに `.gitkeep`）、`lib/app.dart` を空で作成
- [x] `test/features/` を作成
- [x] `CLAUDE.md` 作成（アプリ概要・技術スタック・フォルダ規約・共通の型・Git運用）
- [x] `README.md` 作成（環境構築手順・フォルダ構成）
- [x] `flutter analyze` 実行

### `flutter analyze` の結果

エラー・警告 **0件**。`info`（lint 提案）が 8件。

| 場所 | 内容 |
| --- | --- |
| lib/main.dart × 5 | `public_member_api_docs` |
| lib/main.dart × 1 | `always_put_required_named_parameters_first` |
| test/widget_test.dart × 2 | `directives_ordering` / `avoid_types_on_closure_parameters` |

すべて `flutter create` が生成したテンプレート由来。very_good_analysis が厳しめなので出ている。
`main.dart` はそのまま残す指示だったので未修正。中身を `app.dart` に移すときに消える見込み。

### 判断したこと・指示から外れたこと

- `flutter_lints` を pubspec から削除した
  → analysis_options が very_good_analysis に変わり、参照されなくなったため
- pubspec の依存をアルファベット順に並べ替えた
  → `sort_pub_dependencies` の lint に引っかかっていたため

### 次にやる前に決めること / 積み残し

- [ ] **`main` ブランチの実体がない**（コミットが1つもないため）。
      いま `feature/project-structure` は親を持たないブランチ。
      PR 運用にするなら、最初のコミットを `main` に置くか、
      コミット後に `git branch -f main <最初のコミット>` で `main` を作る
- [ ] `sqlite3_flutter_libs` の解決バージョンが `0.6.0+eol`（メンテ終了扱い）。
      DB 実装に入る前に Drift 側の推奨パッケージを pub.dev で確認する
- [ ] Drift のコード生成を始めたら `analysis_options.yaml` に
      `analyzer.exclude: ["**/*.g.dart"]` を足す（今は不要なので未設定）
- [ ] `pubspec.yaml` の `description` が `"A new Flutter project."` のまま
- [ ] 差分を2人で確認 → コミット（Conventional Commits 形式）
