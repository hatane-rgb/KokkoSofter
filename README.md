# 🚀 KokkoSofter

モダンでスタイリッシュなチーム向けソーシャル投稿プラットフォーム

![Django](https://img.shields.io/badge/Django-5.2.4-green)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ 特徴

- 🎨 **DaisyUI + Tailwind CSS** による美しいUI
- 📱 **完全レスポンシブ** デザイン
- 🌙 **ダーク/ライトテーマ** 切り替え
- 💫 **スムーズなページ遷移** アニメーション
- 🖼️ **画像アップロード** 機能
- 👥 **リアルタイム** ユーザー状態表示
- 🌤️ **天気情報** ウィジェット
- 🕐 **デジタル時計** ウィジェット
- 🔒 **セキュア** な認証システム

## 🚀 クイックスタート

### 開発環境

```bash
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 開発環境をセットアップ
make dev-setup

# 開発サーバーを起動
make run
```

### 本番環境

```bash
# 本番環境をセットアップ
./deploy.sh production

# または Makefileを使用（Linux/Mac/WSL）
make production-setup
```

## 📋 前提条件

- Python 3.8以上
- PostgreSQL（本番環境推奨）
- Nginx（本番環境）

## 🛠️ インストール手順

### 1. 環境設定

```bash
# 仮想環境の作成
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# または
venv\Scripts\activate     # Windows

# 依存関係のインストール
pip install -r requirements.txt
```

### 2. 環境変数の設定

```bash
# .env ファイルを作成
cp .env.example .env

# .env ファイルを編集して適切な値を設定
nano .env
```

#### 主要な環境変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `SECRET_KEY` | Django の秘密鍵 | `your-secret-key-here` |
| `DEBUG` | デバッグモード | `False` (本番環境) |
| `ALLOWED_HOSTS` | 許可されたホスト | `your-domain.com,www.your-domain.com` |
| `DATABASE_URL` | データベースURL | `postgres://user:pass@localhost:5432/db` |

### 3. データベース設定

```bash
# マイグレーションの実行
cd KokkoSofter
python manage.py makemigrations
python manage.py migrate

# スーパーユーザーの作成
python manage.py createsuperuser

# 静的ファイルの収集
python manage.py collectstatic
```

## 🔧 利用可能なコマンド

### Makefileコマンド (Linux/Mac/WSL)

```bash
make help              # ヘルプを表示
make dev-setup         # 開発環境をセットアップ
make run               # 開発サーバーを起動
make migrate           # マイグレーションを実行
make superuser         # スーパーユーザーを作成
make static            # 静的ファイルを収集
make test              # テストを実行
make clean             # 一時ファイルを削除
make start             # 簡単な開発開始
```

### Windowsバッチコマンド

```cmd
manage.bat help        # ヘルプを表示
manage.bat dev-setup   # 開発環境をセットアップ
manage.bat run         # 開発サーバーを起動
manage.bat migrate     # マイグレーションを実行
manage.bat superuser   # スーパーユーザーを作成
manage.bat static      # 静的ファイルを収集
manage.bat test        # テストを実行
manage.bat clean       # 一時ファイルを削除
manage.bat start       # 簡単な開発開始
```

### シェルスクリプト

```bash
./deploy.sh development  # 開発環境のデプロイ
./deploy.sh production   # 本番環境のデプロイ
```

## 🐳 Docker対応（オプション）

対応予定乞うご期待

## 🌐 本番環境デプロイ

### Ubuntu/Debian サーバー

1. **システムの更新**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-venv python3-pip postgresql nginx -y
```

2. **プロジェクトのクローン**
```bash
sudo mkdir -p /var/www/kokkosofter
sudo chown $USER:$USER /var/www/kokkosofter
cd /var/www/kokkosofter
git clone https://github.com/hatane-rgb/KokkoSofter.git .
```

3. **デプロイの実行**
```bash
chmod +x deploy.sh
./deploy.sh production
```

4. **Nginx設定**
```bash
sudo cp nginx_kokkosofter.conf /etc/nginx/sites-available/kokkosofter
sudo ln -s /etc/nginx/sites-available/kokkosofter /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

5. **systemdサービス**
```bash
sudo cp kokkosofter.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kokkosofter
sudo systemctl start kokkosofter
```

## 🔒 セキュリティ

- ✅ CSRF保護
- ✅ XSS保護
- ✅ セキュアなセッション管理
- ✅ HTTPS強制（本番環境）
- ✅ セキュリティヘッダー
- ✅ ファイルアップロード制限

## 📁 プロジェクト構成

```
KokkoSofter/
├── KokkoSofter/          # Djangoプロジェクト設定
├── accounts/             # ユーザー認証アプリ
├── core/                 # コアアプリ
├── posts/                # 投稿管理アプリ
├── templates/            # テンプレート
├── static/              # 静的ファイル
├── media/               # メディアファイル
├── requirements.txt     # Python依存関係
├── .env.example        # 環境変数テンプレート
├── deploy.sh           # デプロイスクリプト
├── Makefile           # 管理コマンド
├── gunicorn_config.py # Gunicorn設定
├── nginx_kokkosofter.conf # Nginx設定
└── kokkosofter.service # systemdサービス
```

## 🤝 コントリビューション

1. フォークする
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. コミット (`git commit -m 'Add amazing feature'`)
4. プッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🆘 サポート

問題が発生した場合は、[Issues](https://github.com/hatane-rgb/KokkoSofter/issues) を作成してください。

## 🎯 ロードマップ

- [ ] リアルタイムチャット機能
- [ ] プッシュ通知
- [ ] ファイル共有機能
- [ ] カレンダー統合
- [ ] Todo管理機能
- [ ] チーム管理機能

---

**Made with ❤️ by KokkoSoft Team**

このREADMEはGithub Copilotに描いてもらいました！時代の進歩