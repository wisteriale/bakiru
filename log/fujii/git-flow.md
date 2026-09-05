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

> **このチームは「1人1ブランチ」で運用している**ので、実際の手順は
> **2章**を見ること。この章は「機能ごとにブランチを切る」一般形の説明。
> コミット規約（④）と PR の書き方（⑥）は2章でも共通なので、そこは読むこと。

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

## 2. 1人1ブランチで回す場合（このチームの運用）

### 前提

- 自分のブランチは1本だけ（例: `fujii`、相方は相方の名前）。
  機能ごとには切らず、**同じブランチをずっと使う**。
- `main` へは必ず Pull Request でマージする。
- 相方のブランチには触らない。やり取りは**必ず `main` を経由する**。

この運用は「ブランチを切る手間が無い」代わりに、
**`main` の最新をこまめに取り込まないと、あっという間にズレる**。
朝いちで取り込む習慣をつけるのが一番効く。

---

### A. `main` の最新を自分のブランチに取り込む

状況で2パターンある。

#### パターン1: 自分の PR がマージされた直後 → **ブランチを作り直す**（おすすめ）

自分の変更はもう `main` に入っているので、ブランチを捨てて `main` から
作り直すのが一番きれい。**ブランチ名は同じ**なので運用は変わらない。

```bash
git checkout main
git pull origin main

git branch -D fujii                            # 古い fujii を捨てる
git checkout -b fujii                          # main から作り直す
git push -u origin fujii --force-with-lease    # リモートも置き換える
```

`-D`（大文字）は「マージ済みか確認せずに消す」。
PR でマージ済みだと分かっているので使ってよい。

**注意: 未コミットの変更や push していないコミットがあると消える。**
実行前に必ず `git status` が空であることを確認すること。

#### パターン2: 作業の途中で、相方の PR が `main` にマージされた → **merge で取り込む**

作業中のコミットを残したまま最新を取り込む。

```bash
git checkout fujii
git fetch origin                # リモートの最新情報を取得（まだ何も変わらない）
git log HEAD..origin/main --oneline   # 何が来るか見る（省略可）
git merge origin/main           # 取り込む
git push
```

`git pull origin main` でも同じことができるが、`fetch` してから `merge` する方が
**「何が来るか見てから取り込める」**ので安全。

#### なぜ rebase ではなく merge か

rebase は履歴を書き換えるので、push 済みのブランチだと毎回
`--force-with-lease` が必要になる。1人しか使わないブランチなら rebase でも
動くが、**長く使うブランチでは merge の方が事故が少ない**。
履歴が少し複雑になるのは許容する。

---

### B. 自分のブランチを `main` にマージする

```bash
# 1. 品質チェック（1章③と同じ）
dart format .
flutter analyze
flutter test

# 2. コミットして push
git add -A
git status                      # 意図しないファイルが無いか目視
git commit -m "feat(trash): ごみ箱一覧の画面を追加"
git push
```

3. GitHub で Pull Request を作る（本文の書き方は1章⑥と同じ）
4. 相方がレビューして approve
5. **「Create a merge commit」でマージ**（→ C 参照）
6. マージ画面の **"Delete branch" は押さない**（同じブランチを使い続けるため）
7. マージできたら、上の **A パターン1** でブランチを作り直す

**5→7 はセットで、その日のうちにやること。**
マージしたあとブランチを放置すると、次の作業で必ずコンフリクトする。

---

### C. GitHub のマージ方法は「Create a merge commit」を選ぶ

**Squash and merge は使わないこと。**

squash は「ブランチの複数コミットを1つにまとめて `main` に載せる」方法。
履歴はきれいになるが、まとめた結果は元のコミットとは**別物のコミット**になる。
そのため `main` と自分のブランチの履歴が繋がらず、
同じブランチを使い続けると「同じ変更が2回当たる」形になってコンフリクトする。

事故を防ぐため、**GitHub 側で設定を絞っておく**のが確実。

```
Settings → General → Pull Requests
  [x] Allow merge commits      ← これだけ残す
  [ ] Allow squash merging     ← 外す
  [ ] Allow rebase merging     ← 外す
```

---

### D. コンフリクトが起きたとき（merge 版）

```bash
git merge origin/main
# CONFLICT (content): Merge conflict in lib/app.dart
# Automatic merge failed; fix conflicts and then commit the result.
```

慌てなくてよい。手順は4つだけ。

```bash
# 1. どのファイルが競合しているか確認
git status

# 2. エディタで直す
#    <<<<<<< HEAD から >>>>>>> までが競合箇所。
#    VS Code なら "Accept Current / Incoming / Both" のボタンが出る。
#    マーカー（<<<<<<< ======= >>>>>>>）を残さないこと。

# 3. 直したファイルを add
git add lib/app.dart

# 4. マージを完了させる
git commit          # メッセージは自動で入るので、そのまま保存でよい
```

**やり直したくなったら `git merge --abort`** でマージ前の状態に戻せる。
「よく分からなくなった」ときは、悩まず abort して相方に声をかける方が速い。

`*.g.dart` と `pubspec.lock` のコンフリクトは**手で直さない**。3章を参照。

---

### E. 相方の変更を先に取りたいとき

**原則、相方のブランチを直接 merge しない。** `main` 経由にする。

```bash
# 相方が PR をマージするのを待ってから
git fetch origin
git merge origin/main
```

「動作を確認したいだけ」なら、merge せず**見に行くだけ**にする。

```bash
git fetch origin
git checkout origin/aite-branch   # 一時的に見る（detached HEAD 状態）
flutter run -d chrome             # 動かして確認
git checkout fujii                # 自分のブランチに戻る
```

detached HEAD は「どのブランチにも乗っていない状態」なので、
**ここで編集してコミットしないこと**（戻ったときに消える）。

---

### F. よくある症状と対処

| 症状 | 原因 | 対処 |
| --- | --- | --- |
| `Already up to date.` と出るのに main の変更が反映されない | `git fetch` していないので、手元の `origin/main` が古い | `git fetch origin` してから `git merge origin/main` |
| `git push` が `rejected` される | リモートに自分が持っていないコミットがある（別の PC から push した等） | `git fetch origin` → `git merge origin/fujii` → `git push` |
| ブランチを作り直したら push が拒否される | ローカルとリモートで履歴が別物になったため。A パターン1 の直後に起きる | `git push --force-with-lease`（自分しか使わないブランチなので問題ない） |
| PR の差分が巨大になっている | `main` の取り込みを長期間サボった | 次から朝いちで取り込む。今回は諦めて丁寧にレビューする |
| PR の差分に相方の変更が混ざる | `main` の取り込みが中途半端 | `git fetch origin && git merge origin/main` をやり直す |

---

## 3. つまずきやすいところ

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

## 4. 2人で回すときのコツ

- **同じファイルを同時に触らない。**
  機能ごとにフォルダが分かれているので、「今日は自分が `features/photo/`、相方が `features/destroy/`」
  のように分担すると衝突しない。
- **`core/` を触るときは一声かける。**
  両方から使う場所なので、衝突すると2人とも止まる。
- **PR は小さく、早く出す。**
  1日以上寝かせると main とズレてマージが面倒になる。
- **朝いちで `main` を取り込む。**
  1人1ブランチ運用では、これをサボった分だけコンフリクトが育つ（2章A）。
- **相方がマージしたら、その日のうちにブランチを作り直す**（2章A パターン1）。

---

## 5. よく使うコマンド早見表

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
| リモートの最新**情報**を取る（まだ何も変わらない） | `git fetch origin` |
| main の何が来るか先に見る | `git log HEAD..origin/main --oneline` |
| main の最新を自分のブランチに取り込む | `git fetch origin` → `git merge origin/main` |
| マージをやめて元に戻す | `git merge --abort` |
| ブランチを main から作り直す | `git branch -D fujii` → `git checkout -b fujii` |
| 作り直したブランチを push する | `git push --force-with-lease` |
