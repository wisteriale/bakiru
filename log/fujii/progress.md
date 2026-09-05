# 進捗ログ（fujii）

Claude に何をやらせたか / どこまで進んだかの記録。
新しい作業をしたら、上に日付のセクションを足していく。

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
