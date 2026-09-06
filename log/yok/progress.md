# 進捗ログ(yokoyama)

作業の記録です。

## 2026-09-06

### 実施したこと

- 共通の仮土台を追加した。
  - `TrashType` を `TrashItemType` に変更し、種別を `photo` / `mail` /
    `text` に整理した。
  - 捨て台詞用の `Epitaph` と `DestroyMethod` を追加した。
  - `TrashRepository` / `PhotoRepository` / `MailRepository` の
    インターフェースを追加した。
  - DB完成前でも画面を作れるよう、ダミー3件を返す
    `FakeTrashRepository` を追加した。
  - `main.dart` の `ProviderScope.overrides` で、ダミー実装を注入した。

- B担当のUIの最初の導線を作った。
  - `app.dart` にアプリ全体の組み立てと、ごみ箱一覧画面を実装した。
  - 写真・メール・テキストのダミー項目を一覧表示できるようにした。
  - 「端末の写真は削除されず、アプリ内のコピーだけが壊れる」ことを
    画面上に表示した。
  - 項目をタップすると、叩き割る演出の仮画面へ遷移するようにした。
  - `core/theme/app_theme.dart` に、オレンジを基調とした仮テーマを追加した。

- テストと動作確認をした。
  - `flutter analyze` は問題なし。
  - 一覧から叩き割る画面へ遷移するウィジェットテストを追加し、成功した。
  - Chromeでデバッグ起動できることを確認した。
  - Chrome起動時に停止していた原因はエラーではなく、VS Codeの
    ブレークポイントだった。解除または続行すれば起動できる。

### 主な変更ファイル

- `lib/main.dart`
- `lib/app.dart`
- `lib/core/model/trash_item.dart`
- `lib/core/model/epitaph.dart`
- `lib/core/repository/`
- `lib/core/theme/app_theme.dart`
- `lib/features/destroy/ui/shatter/shatter_page.dart`
- `test/widget_test.dart`

### 未着手・次にやること

- 一覧画面の世界観・見た目を決めて作り込む。
- 「叩き割る」仮画面へRive演出を追加する。
- 捨て台詞の入力と一覧を実装する。
- 写真の取り込みと共有シート受け取りを実装する。

### 注意点

- `core/db/`、`features/trash/`、`features/mail/` は担当Aの範囲なので
  変更していない。
- 現在は本物のDBではなく、`FakeTrashRepository` のダミーデータで
  UIを確認している。
