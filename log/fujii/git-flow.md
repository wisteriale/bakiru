# Git 開発フロー（バキる）

2人で開発するときの手順書。迷ったらここを見る。

**大前提: `main` への直接 push は禁止。`feature/` ブランチ + Pull Request で進める。**

---

## 0. 最初の1回だけ

リポジトリを作った直後にやること。

```bash
# main をリモートに作る（ここだけは main を直接 push する）
git checkout main
git push -u origin main

# 作業ブランチを push
git checkout feature/project-structure
git push -u origin feature/project-structure
```

そのあと GitHub で PR を作成 → もう1人がレビュー → マージ。

PR を1回マージしたら、GitHub の **Settings → Branches** で `main` にブランチ保護を掛ける。
"Require a pull request before merging" をオンにするだけでよい。
これでルールが「気をつける」ではなく「仕組みで守られる」状態になる。

---

## 1. 毎回のサイクル

### ① main を最新にしてブランチを切る

```bash
git checkout main
git pull origin main          # ここを飛ばすとコンフリクトの元
git checkout -b feature/trash-list
```

ブランチ名は `<種別>/<内容>`。内容は英語のケバブケース。

| プレフィックス | 用途 | 例 |
| --- | --- | --- |
| `feature/` | 機能追加 | `feature/trash-list` |
| `fix/` | バグ修正 | `fix/thumbnail-not-shown` |
| `chore/` | 設定・雑務 | `chore/add-rive-assets` |
| `docs/` | ドキュメント | `docs/update-readme` |

**1ブランチ = 1つのまとまり**にする。
「ごみ箱一覧 + 燃やす演出」を1本に詰めるとレビューが重くなり、マージが止まる。

### ② 作業する

Claude に頼む場合も、この作業ブランチの上で頼む。

### ③ コミット前に必ず通す

```bash
dart format .                 # フォーマット
flutter analyze               # lint（エラー0を確認）
flutter test                  # テスト
```

Drift のテーブル定義など、`*.g.dart` に影響する変更をしたときは先にコード生成:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### ④ コミット

```bash
git add -A
git status                    # 意図しないファイルが入っていないか目視
git commit -m "feat(trash): ごみ箱一覧の画面を追加"
```

コミットメッセージは Conventional Commits 形式（日本語可）。

```
<type>(<scope>): <内容>
```

- **type**: `feat` / `fix` / `chore` / `docs` / `refactor` / `test` / `style`
- **scope**: 機能名（`trash` `destroy` `photo` `mail` `app_uninstall` `share_intake` `core`）。
  全体に関わるときは省略可

例:

```
feat(destroy): 叩き割る演出を追加
fix(photo): サムネイルが表示されない不具合を修正
refactor(core): TrashItem を core/model に移動
chore: rive を 0.14.11 に更新
```

### ⑤ push

```bash
git push -u origin feature/trash-list     # 初回
git push                                  # 2回目以降
```

### ⑥ PR を作る

GitHub 上で「Compare & pull request」。本文のテンプレート:

```markdown
## やったこと
- ごみ箱一覧画面を追加
- TrashItem のモデルを定義

## 確認したこと
- [ ] flutter analyze がエラー0
- [ ] flutter test が通る
- [ ] Chrome で表示を確認

## レビューしてほしい点
- provider の分け方がこれで妥当か自信がない
```

**「レビューしてほしい点」を書くのが一番効く。**
2人しかいないので、全部見てもらうより「ここ見て」と言った方が速い。

### ⑦ マージ後の片付け

```bash
git checkout main
git pull origin main
git branch -d feature/trash-list           # ローカルのブランチを削除
```

リモートのブランチは GitHub のマージ画面の「Delete branch」ボタンで消える。

---

## 2. つまずきやすいところ

### main が進んでいてコンフリクトした

作業中に相方の PR がマージされた場合。

```bash
git checkout feature/trash-list
git fetch origin
git rebase origin/main
# コンフリクトしたらファイルを直して
git add <直したファイル>
git rebase --continue
git push --force-with-lease     # rebase 後は普通の push だと弾かれる
```

`--force-with-lease` は「自分が知らない変更がリモートに来ていたら止まる」安全版の force push。
素の `--force` は相方の作業を消す可能性があるので使わない。

rebase が怖ければ `git merge origin/main` でもよい（履歴は少し汚れるが安全）。

### `*.g.dart` でコンフリクトした

**手で解決しない。** 生成物なので、元の定義側だけ解決して作り直す。

```bash
git checkout --ours lib/core/db/database.g.dart   # 中身は捨てる
dart run build_runner build --delete-conflicting-outputs
git add lib/core/db/database.g.dart
```

### `pubspec.lock` でコンフリクトした

これも生成物。片方を採用して `flutter pub get` で作り直せば OK。

### 秘密情報をコミットしてしまった

`.gitignore` に `google-services.json` / `GoogleService-Info.plist` は登録済み。
それでも入ってしまい、**push する前に気づいた場合**:

```bash
git rm --cached <ファイル>
git commit --amend
```

push した後だと履歴から消すのが面倒になる。`git status` の目視は毎回やること。

### ブランチを切り忘れて main で作業してしまった

まだコミットしていなければ、そのままブランチを切れば変更ごと移動する。

```bash
git checkout -b feature/trash-list
```

コミットまでしてしまった場合:

```bash
git branch feature/trash-list      # 今の状態でブランチを作る
git reset --hard origin/main       # main を元に戻す
git checkout feature/trash-list    # 作業ブランチへ
```

`git reset --hard` は変更を消すコマンドなので、ブランチを作ったことを確認してから打つ。

---

## 3. 2人で回すときのコツ

- **同じファイルを同時に触らない。**
  機能ごとにフォルダが分かれているので、「今日は自分が `features/photo/`、相方が `features/destroy/`」
  のように分担すると衝突しない。
- **`core/` を触るときは一声かける。**
  両方から使う場所なので、衝突すると2人とも止まる。
- **PR は小さく、早く出す。**
  1日以上寝かせると main とズレて rebase が面倒になる。

---

## 4. よく使うコマンド早見表

| やりたいこと | コマンド |
| --- | --- |
| 今どのブランチ？ | `git branch --show-current` |
| 何が変わった？ | `git status` / `git diff` |
| ステージした内容を見る | `git diff --staged` |
| 直前のコミットを取り消す（変更は残す） | `git reset --soft HEAD^` |
| ステージを取り消す（変更は残す） | `git reset` |
| ファイルの変更を捨てる | `git restore <ファイル>` |
| 作業を一時退避する | `git stash` → 戻すのは `git stash pop` |
| 履歴を見る | `git log --oneline --graph --all` |
| リモートの最新を取り込む | `git pull origin main` |
