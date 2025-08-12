# 🛠️ セットアップガイド

KokkoSofterのWindows・Linux環境での詳細なセットアップ手順です。

## 📋 目次

- [前提条件・必要環境](#前提条件必要環境)
- [Windows セットアップ](#windows-セットアップ)
- [Linux セットアップ](#linux-セットアップ)
- [macOS セットアップ](#macos-セットアップ)
- [開発環境セットアップ](#開発環境セットアップ)
- [本番環境セットアップ](#本番環境セットアップ)
- [検証・テスト](#検証テスト)

## 前提条件・必要環境

### 必須要件
| 項目 | 開発環境 | 本番環境 | 備考 |
|------|----------|----------|------|
| **Python** | 3.8+ | 3.9+ | 推奨: 3.11+ |
| **Node.js** | 18.0+ | 20.0+ | TailwindCSS用 |
| **Git** | 最新版 | 最新版 | バージョン管理 |
| **データベース** | SQLite | PostgreSQL | 開発: SQLite可 |
| **Webサーバー** | Django dev | Nginx + Gunicorn | 本番環境必須 |

### 推奨システム要件
- **OS**: Windows 10+, macOS 12+, Ubuntu 20.04+
- **メモリ**: 4GB以上（本番: 8GB+）
- **ストレージ**: 2GB以上の空き容量
- **ブラウザ**: Chrome 90+, Firefox 88+, Safari 14+

### ネットワーク要件
- **インターネット接続**: パッケージダウンロード用
- **ポート**: 8000（開発）, 80/443（本番）
- **プロキシ**: 企業環境では設定が必要な場合があります

## Windows セットアップ

### 1. 必要なアプリケーションのインストール

#### Python のインストール
```powershell
# Microsoft Store 経由（推奨）
winget install Python.Python.3.12

# または python.org から直接インストール
# https://www.python.org/downloads/windows/

# インストール確認
python --version
pip --version
```

#### Node.js のインストール
```powershell
# winget 経由
winget install OpenJS.NodeJS

# または Node.js 公式サイトから
# https://nodejs.org/

# インストール確認
node --version
npm --version
```

#### Git のインストール
```powershell
# winget 経由
winget install Git.Git

# または Git for Windows から
# https://gitforwindows.org/

# インストール確認
git --version
```

#### Chocolatey を使用する場合
```powershell
# Chocolatey のインストール（管理者権限）
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 必要なアプリケーションをまとめてインストール
choco install python nodejs git -y
```

### 2. PowerShell実行ポリシーの設定
```powershell
# 管理者権限でPowerShellを開いて実行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# または個別実行時にバイパス
PowerShell -ExecutionPolicy Bypass -File .\deploy.ps1 development
```

### 3. プロジェクトのクローン・セットアップ
```powershell
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 自動セットアップ（推奨）
.\deploy.ps1 development

# 手動セットアップの場合
python -m venv venv
venv\Scripts\activate
pip install -r requirements-dev.txt
npm install
npm run build
python manage.py migrate
python manage.py createsuperuser
```

### 4. 開発サーバーの起動
```powershell
# 仮想環境を有効化
venv\Scripts\activate

# 開発サーバー起動
python manage.py runserver

# ブラウザでアクセス
# http://127.0.0.1:8000/
```

## Linux セットアップ

### Ubuntu/Debian

#### 1. システムの更新・必要パッケージのインストール
```bash
# システム更新
sudo apt update && sudo apt upgrade -y

# Python 3.8+ とpip
sudo apt install python3 python3-pip python3-venv -y

# 追加の開発ツール
sudo apt install build-essential curl wget software-properties-common -y

# Git
sudo apt install git -y
```

#### 2. Node.js のインストール（NodeSource リポジトリ）
```bash
# NodeSource リポジトリ追加（Node.js 20.x）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Node.js インストール
sudo apt-get install -y nodejs

# インストール確認
node --version
npm --version
```

#### 3. プロジェクトセットアップ
```bash
# リポジトリクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 自動セットアップ（推奨）
make full-setup

# 開発サーバー起動
make run
```

### CentOS/RHEL/Fedora

#### 1. 必要パッケージのインストール
```bash
# Python 3.8+ とpip
sudo dnf install python3 python3-pip python3-venv -y

# 開発ツール
sudo dnf groupinstall "Development Tools" -y
sudo dnf install curl wget -y

# Node.js 18+
sudo dnf install nodejs npm -y

# Git
sudo dnf install git -y
```

#### 2. プロジェクトセットアップ
```bash
# リポジトリクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# セットアップ
make full-setup
make run
```

## macOS セットアップ

### 1. Homebrew のインストール（未インストールの場合）
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 必要なアプリケーションのインストール
```bash
# Python, Node.js, Git
brew install python@3.12 node git

# インストール確認
python3 --version
node --version
git --version
```

### 3. プロジェクトセットアップ
```bash
# リポジトリクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# セットアップ
make full-setup
make run
```

## 開発環境セットアップ

### 手動セットアップ手順

#### 1. Python仮想環境の作成
```bash
# 仮想環境作成
python -m venv venv

# 仮想環境有効化
# Windows
venv\Scripts\activate
# Linux/macOS
source venv/bin/activate

# pip アップグレード
python -m pip install --upgrade pip
```

#### 2. Python依存関係のインストール
```bash
# 開発環境用（SQLiteのみ）
pip install -r requirements-dev.txt

# 本番環境用（PostgreSQL対応）
pip install -r requirements.txt

# インストール確認
pip list
```

#### 3. Node.js依存関係・CSS構築
```bash
# Node.js パッケージインストール
npm install

# TailwindCSS ビルド
npm run build

# 開発時の監視モード
npm run dev
```

#### 4. データベース設定
```bash
# マイグレーション実行
python manage.py makemigrations
python manage.py migrate

# スーパーユーザー作成
python manage.py createsuperuser

# 静的ファイル収集
python manage.py collectstatic --noinput
```

#### 5. 設定ファイルの確認
```bash
# .env ファイルの作成（.env.example をコピー）
cp .env.example .env

# SECRET_KEY の生成（自動で設定される場合もあります）
python manage.py shell -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 環境変数設定（.env ファイル）

```bash
# 開発環境の例
DEBUG=True
SECRET_KEY=your-generated-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
CSRF_TRUSTED_ORIGINS=http://localhost:8000,http://127.0.0.1:8000
```

## 本番環境セットアップ

### Linux（Ubuntu）本番環境

#### 1. 本番環境デプロイ（新規環境）
```bash
# リポジトリクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 実行権限付与
chmod +x deploy.sh

# 本番環境自動デプロイ
./deploy.sh production
```

#### 1b. 本番環境デプロイ（既存環境の更新）
```bash
# 既存の本番環境を更新する場合
cd /var/www/kokkosofter

# ローカル変更を破棄して最新版を取得
git reset --hard HEAD
git pull origin main

# 実行権限を再設定
chmod +x deploy.sh

# デプロイ続行
./deploy.sh production
```

#### 2. PostgreSQL のセットアップ
```bash
# PostgreSQL インストール
sudo apt install postgresql postgresql-contrib -y

# データベース・ユーザー作成
sudo -u postgres psql

# PostgreSQL 内で実行
CREATE DATABASE kokkosofter;
CREATE USER kokkosofter WITH ENCRYPTED PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE kokkosofter TO kokkosofter;
\q
```

#### 3. Nginx 設定
```bash
# Nginx インストール
sudo apt install nginx -y

# 設定適用
make nginx-setup

# Nginx 開始・有効化
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### 4. Systemd サービス設定
```bash
# systemd サービス設定コピー
sudo cp kokkosofter.service /etc/systemd/system/

# サービス有効化・開始
sudo systemctl daemon-reload
sudo systemctl enable kokkosofter
sudo systemctl start kokkosofter

# ステータス確認
make service-status
```

#### 5. SSL証明書設定（Let's Encrypt）
```bash
# Certbot インストール
sudo apt install certbot python3-certbot-nginx -y

# SSL証明書取得
sudo certbot --nginx -d your-domain.com

# 自動更新テスト
sudo certbot renew --dry-run
```

### ドメイン設定
```bash
# ドメイン設定の対話式設定
make configure-domain

# または一括設定
make quick-domain-setup
```

## 検証・テスト

### 開発環境の確認
```bash
# Django システムチェック
python manage.py check

# テスト実行
python manage.py test

# 開発サーバー起動
python manage.py runserver 0.0.0.0:8000
```

### 本番環境の確認
```bash
# Django デプロイチェック
python manage.py check --deploy

# サービス状態確認
make service-status

# Nginx 設定テスト
make nginx-test

# ログ確認
make service-logs
```

### アクセステスト
- **開発環境**: http://127.0.0.1:8000/
- **本番環境**: http://your-domain.com/
- **管理画面**: /admin/

## トラブルシューティング

一般的な問題は [トラブルシューティングガイド](TROUBLESHOOTING.md) を参照してください。

### よくある問題
1. **権限エラー**: `make fix-permissions`
2. **CSRF エラー**: `make fix-csrf`
3. **静的ファイル問題**: `make fix-media`
4. **サービス起動失敗**: `make service-logs`

## 次のステップ

セットアップ完了後:
1. [機能一覧](FEATURES.md) でアプリケーション機能を確認
2. [開発ガイド](DEVELOPMENT.md) で開発手順を学習
3. [UI/UXガイド](UI_GUIDE.md) でカスタマイズ方法を確認

---

**🔧 詳細な問題解決は [トラブルシューティング](TROUBLESHOOTING.md) を参照してください。**
```bash
# pip を最新版に更新
python -m pip install --upgrade pip

# 依存関係をインストール
pip install -r requirements.txt

# インストール確認
pip list
```

### 3. Node.js環境の構築

#### Node.jsパッケージのインストール
```bash
# パッケージのインストール（自動でTailwindCSS・DaisyUIも導入）
npm install

# TailwindCSSの初期化（必要に応じて）
npx tailwindcss init -p

# インストール確認
npm list
```

#### TailwindCSSのビルド
```bash
# 開発用（ウォッチモード）
npm run build-css

# 本番用（最適化）
npm run build-css-prod
```

### 4. データベースの設定

#### 開発環境（SQLite）
```bash
# マイグレーションファイル作成
python manage.py makemigrations

# データベースの作成・更新
python manage.py migrate

# 初期データの作成（任意）
python manage.py loaddata initial_data.json
```

#### 本番環境（PostgreSQL）
```bash
# PostgreSQLのインストール（Ubuntu例）
sudo apt update
sudo apt install postgresql postgresql-contrib

# データベース・ユーザー作成
sudo -u postgres createdb kokkosofter
sudo -u postgres createuser kokkosofter_user -P

# 環境変数設定（.env ファイル）
DATABASE_URL=postgresql://kokkosofter_user:password@localhost/kokkosofter
```

### 5. 管理者アカウントの作成

```bash
# スーパーユーザー作成
python manage.py createsuperuser

# 入力例:
# Username: admin
# Email: admin@example.com  
# Password: ********
# Password (again): ********
```

### 6. 静的ファイルの準備

```bash
# 静的ファイルの収集（本番環境）
python manage.py collectstatic

# メディアフォルダの作成
mkdir -p media/avatars
mkdir -p media/post_images
```

## ⚙️ 設定ファイル

### 環境変数（.env）

プロジェクトルートに `.env` ファイルを作成：

```env
# 基本設定
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1

# データベース
DATABASE_URL=sqlite:///db.sqlite3

# メール設定（任意）
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# 外部API（任意）
WEATHER_API_KEY=your-openweather-api-key

# セキュリティ
SECURE_SSL_REDIRECT=False
SECURE_BROWSER_XSS_FILTER=True
SECURE_CONTENT_TYPE_NOSNIFF=True
```

### settings.py の調整

必要に応じて `KokkoSofter/settings.py` を編集：

```python
# タイムゾーン
TIME_ZONE = 'Asia/Tokyo'

# 言語設定
LANGUAGE_CODE = 'ja'

# メディアファイル設定
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# ログ設定
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'django.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

## 🚀 開発サーバーの起動

### 基本的な起動
```bash
# 開発サーバー起動
python manage.py runserver

# カスタムポート
python manage.py runserver 8080

# 外部アクセス許可
python manage.py runserver 0.0.0.0:8000
```

### 並行作業（推奨）
```bash
# ターミナル1: Django開発サーバー
python manage.py runserver

# ターミナル2: TailwindCSSウォッチ
npm run build-css
```

## 🧪 テスト

### テストの実行
```bash
# 全テスト実行
python manage.py test

# 特定アプリのテスト
python manage.py test accounts
python manage.py test posts
python manage.py test core

# カバレッジ付きテスト（coverage要インストール）
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html
```

### テストデータの作成
```bash
# フィクスチャの作成
python manage.py dumpdata accounts.User --indent 2 > test_users.json

# フィクスチャの読み込み
python manage.py loaddata test_users.json
```

## 🔧 トラブルシューティング

### よくある問題

#### 1. パッケージインストールエラー
```bash
# Pythonパッケージ
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt --no-cache-dir

# Node.jsパッケージ
npm cache clean --force
npm install
```

#### 2. データベースエラー
```bash
# マイグレーションリセット
python manage.py migrate --fake-initial
python manage.py migrate
```

#### 3. 静的ファイル問題
```bash
# 静的ファイル再生成
python manage.py collectstatic --clear
npm run build-css-prod
```

#### 4. 権限エラー（Linux/macOS）
```bash
# ファイル権限修正
chmod +x manage.py
chmod -R 755 static/
chmod -R 755 media/
```

### ログの確認

```bash
# Django ログ
tail -f django.log

# 開発サーバーログ
python manage.py runserver --verbosity=2

# データベースクエリログ
# settings.py で LOGGING レベルを DEBUG に設定
```

## 🔄 定期メンテナンス

### データベース最適化
```bash
# SQLite 最適化（開発環境）
python manage.py dbshell
.vacuum

# PostgreSQL 最適化（本番環境）
python manage.py dbshell -c "VACUUM ANALYZE;"
```

### ログローテーション
```bash
# ログファイル圧縮・アーカイブ
gzip django.log
mv django.log.gz logs/django-$(date +%Y%m%d).log.gz
```

### パッケージ更新
```bash
# Python パッケージ更新
pip list --outdated
pip install --upgrade package-name

# Node.js パッケージ更新
npm outdated
npm update
```

## 📈 パフォーマンス最適化

### Django最適化
```python
# settings.py 本番設定
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com']

# キャッシュ設定
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}
```

### フロントエンド最適化
```bash
# TailwindCSS 最適化
npm run build-css-prod

# 画像最適化（ImageOptim等使用）
# JavaScript/CSS最小化
```

---

[← READMEに戻る](../README.md) | [← 機能詳細](FEATURES.md) | [デプロイメント →](DEPLOYMENT.md)
