# 🆘 トラブルシューティング

KokkoSofterの一般的な問題と解決方法をまとめました。

## 📋 目次

- [インストール・セットアップの問題](#インストールセットアップの問題)
- [本番環境デプロイの問題](#本番環境デプロイの問題)
- [Python環境の問題](#python環境の問題)
- [Node.js・TailwindCSSの問題](#nodejs-tailwindcssの問題)
- [データベースの問題](#データベースの問題)
- [権限・ファイルアクセスの問題](#権限ファイルアクセスの問題)
- [本番環境の問題](#本番環境の問題)
- [Nginx・Webサーバーの問題](#nginx-webサーバーの問題)
- [CSRF・セキュリティの問題](#csrf-セキュリティの問題)

## 本番環境デプロイの問題

### 🔄 Git merge エラー

**症状**: `error: Your local changes to the following files would be overwritten by merge`

**原因**: 本番環境ディレクトリに既存ファイルがあり、GitHubの最新版と競合

**解決方法**:

#### 方法1: 既存環境の強制更新（推奨）
```bash
# 本番環境ディレクトリに移動
cd /var/www/kokkosofter

# ローカル変更を破棄して最新版を取得
git reset --hard HEAD
git pull origin main

# 実行権限を再設定
chmod +x deploy.sh

# デプロイ再実行
./deploy.sh production
```

#### 方法2: 一からやり直し
```bash
# 既存ディレクトリを削除（バックアップ推奨）
sudo rm -rf /var/www/kokkosofter

# 新規クローン・デプロイ
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter
chmod +x deploy.sh
./deploy.sh production
```

#### 方法3: stashを使用
```bash
cd /var/www/kokkosofter

# ローカル変更を一時保存
git stash

# 最新版を取得
git pull origin main

# デプロイ再実行
chmod +x deploy.sh
./deploy.sh production
```

### 🚫 Permission denied エラー

**症状**: `chmod: changing permissions of 'deploy.sh': Operation not permitted`

**解決方法**:
```bash
# 所有者を確認
ls -la deploy.sh

# 所有者変更（必要に応じて）
sudo chown $(whoami):$(whoami) deploy.sh

# 実行権限付与
chmod +x deploy.sh
```

### 📁 ディレクトリが見つからない

**症状**: `/var/www/kokkosofter` ディレクトリが存在しない

**解決方法**:
```bash
# ディレクトリ作成
sudo mkdir -p /var/www/kokkosofter
sudo chown $(whoami):$(whoami) /var/www/kokkosofter

# または新規クローン
git clone https://github.com/hatane-rgb/KokkoSofter.git /var/www/kokkosofter
cd /var/www/kokkosofter
chmod +x deploy.sh
./deploy.sh production
```

### 📄 ログファイル権限エラー

**症状**: `PermissionError: [Errno 13] Permission denied: '/var/log/kokkosofter/django.log'`

**原因**: Djangoがログファイルに書き込み権限を持っていない

**解決方法**:

#### 自動修正（推奨）
```bash
cd /var/www/kokkosofter
make fix-permissions
```

#### 手動修正
```bash
# ログディレクトリの作成・権限設定
sudo mkdir -p /var/log/kokkosofter
sudo chown -R www-data:www-data /var/log/kokkosofter
sudo chmod -R 755 /var/log/kokkosofter

# プロジェクトディレクトリの権限設定
sudo chown -R www-data:www-data /var/www/kokkosofter
sudo chmod -R 755 /var/www/kokkosofter

# ユーザーをwww-dataグループに追加
sudo usermod -a -G www-data $(whoami)

# セッションを更新（ログアウト・ログインまたは）
newgrp www-data
```

#### 一時的な解決（開発環境）
```bash
# ログディレクトリに書き込み権限を付与
sudo chmod 777 /var/log/kokkosofter

# またはプロジェクトディレクトリにログファイルを作成
mkdir -p logs
touch logs/django.log
chmod 666 logs/django.log
```

## インストール・セットアップの問題

### 🐍 Python not found / Python が見つからない

**症状**: `python: command not found` または `'python' is not recognized`

**解決方法**:

#### Windows
```powershell
# Python のインストール確認
python --version
python3 --version

# PATH確認
echo $env:PATH

# Microsoft Store または python.org からインストール
winget install Python.Python.3.12

# または Chocolatey
choco install python
```

#### Linux (Ubuntu/Debian)
```bash
# Pythonインストール
sudo apt update
sudo apt install python3 python3-pip python3-venv -y

# シンボリックリンク作成（必要に応じて）
sudo ln -sf /usr/bin/python3 /usr/bin/python
```

#### macOS
```bash
# Homebrew でインストール
brew install python@3.12

# PATH設定（~/.zshrc または ~/.bash_profile に追加）
export PATH="/opt/homebrew/bin:$PATH"
```

### 📦 npm / Node.js not found

**症状**: `npm: command not found` または Node.js が見つからない

**解決方法**:

#### Windows
```powershell
# Node.js インストール
winget install OpenJS.NodeJS

# 確認
node --version
npm --version
```

#### Linux
```bash
# NodeSource リポジトリを使用（推奨）
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 確認
node --version
npm --version
```

#### macOS
```bash
# Homebrew でインストール
brew install node

# 確認
node --version
npm --version
```

### 🔐 PowerShell Execution Policy エラー

**症状**: Windows で `execution of scripts is disabled` エラー

**解決方法**:
```powershell
# 管理者権限でPowerShellを開いて実行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# または一時的にバイパス
PowerShell -ExecutionPolicy Bypass -File .\deploy.ps1 development
```

## Python環境の問題

### 🔄 仮想環境が作成されない

**症状**: `python -m venv venv` が失敗する

**解決方法**:

#### Linux/macOS
```bash
# venv モジュールのインストール
sudo apt install python3-venv     # Ubuntu/Debian
sudo dnf install python3-venv     # CentOS/RHEL/Fedora

# 手動で仮想環境を再作成
rm -rf venv
python3 -m venv venv
source venv/bin/activate
```

#### Windows
```powershell
# 仮想環境の削除・再作成
Remove-Item -Recurse -Force venv -ErrorAction SilentlyContinue
python -m venv venv
venv\Scripts\activate
```

### 📝 pip install エラー

**症状**: パッケージのインストール中にエラーが発生

**解決方法**:
```bash
# pip のアップグレード
python -m pip install --upgrade pip

# キャッシュクリア
pip cache purge

# 個別インストール（エラー箇所の特定）
pip install -r requirements.txt --verbose

# C++ コンパイラが必要な場合（Windows）
# Visual Studio Build Tools をインストール
```

### 🔑 ModuleNotFoundError

**症状**: `No module named 'django'` などのインポートエラー

**解決方法**:
```bash
# 仮想環境の有効化確認
echo $VIRTUAL_ENV    # Linux/macOS
echo $env:VIRTUAL_ENV # Windows PowerShell

# 仮想環境を有効化
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# パッケージ再インストール
pip install -r requirements.txt
```

## Node.js・TailwindCSSの問題

### 🎨 TailwindCSS ビルドエラー

**症状**: `npm run build` が失敗する

**解決方法**:
```bash
# Node modules の再インストール
rm -rf node_modules package-lock.json
npm install

# キャッシュクリア
npm cache clean --force

# 手動ビルド
npm run build

# 開発モード（監視）
npm run dev
```

### 📦 npm install エラー

**症状**: `npm install` 中にネットワークやパーミッションエラー

**解決方法**:
```bash
# npm キャッシュクリア
npm cache clean --force

# レジストリ設定確認
npm config get registry

# プロキシ設定（企業環境）
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# 権限問題（Linux/macOS）
sudo chown -R $(whoami) ~/.npm
```

## データベースの問題

### 🗄️ Django Migration エラー

**症状**: `python manage.py migrate` が失敗

**解決方法**:
```bash
# migration ファイルの確認
python manage.py showmigrations

# migration のリセット（開発環境のみ）
rm -rf */migrations/__pycache__
find . -path "*/migrations/*.py" -not -name "__init__.py" -delete
python manage.py makemigrations
python manage.py migrate

# fake migration（最終手段）
python manage.py migrate --fake-initial
```

### 🔒 SQLite ファイルロック

**症状**: `database is locked` エラー

**解決方法**:
```bash
# Django プロセスの終了
pkill -f "python manage.py runserver"  # Linux/macOS
taskkill /F /IM python.exe              # Windows

# SQLite ファイルの権限確認
ls -la db.sqlite3
chmod 664 db.sqlite3  # Linux/macOS

# 新しいデータベース作成（開発環境）
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

## 権限・ファイルアクセスの問題

### 🔐 Permission Denied

**症状**: ファイルやディレクトリアクセス権限エラー

**解決方法**:

#### Linux/macOS
```bash
# プロジェクトディレクトリの所有者変更
sudo chown -R $USER:$USER .

# 実行権限付与
chmod +x deploy.sh

# メディアディレクトリの権限設定
make fix-permissions
```

#### Windows
```powershell
# 管理者権限でPowerShellを実行
# またはユーザーアカウント制御(UAC)を一時的に無効化
```

### 📁 ディレクトリ作成エラー

**症状**: ログやメディアディレクトリが作成できない

**解決方法**:
```bash
# 必要なディレクトリの手動作成
make create-dirs

# または手動作成
mkdir -p media/avatars media/post_images static staticfiles
sudo mkdir -p /var/log/kokkosofter /var/run/kokkosofter
sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
```

## 本番環境の問題

### 🔧 Gunicorn 起動エラー

**症状**: Gunicorn サービスが起動しない

**解決方法**:
```bash
# サービス状態確認
make service-status

# ログ確認
make service-logs

# デバッグモードで手動起動
make debug-gunicorn

# 設定ファイル確認
sudo systemctl cat kokkosofter.service

# サービス再起動
make service-restart
```

### 🌐 Static Files 問題

**症状**: CSS・JS・画像が読み込まれない

**解決方法**:
```bash
# 静的ファイルの収集
python manage.py collectstatic --noinput

# 権限設定
make fix-permissions

# Nginx設定確認
make nginx-test

# シンボリックリンク確認
ls -la /var/www/html/media
```

## Nginx・Webサーバーの問題

### 🌍 Nginx 設定エラー

**症状**: `nginx: [emerg] directive is duplicate` など

**解決方法**:
```bash
# Nginx 設定テスト
make nginx-test

# 設定ファイル確認
sudo nginx -T

# デフォルトサイト無効化
make nginx-disable-default

# 設定の再適用
make nginx-setup
```

### 🔗 502 Bad Gateway

**症状**: Webページにアクセスできない

**解決方法**:
```bash
# Gunicorn サービス確認
make service-status

# ログ確認
make service-logs

# ソケットファイル確認
ls -la /var/run/kokkosofter/

# 手動でGunicorn起動テスト
make debug-gunicorn
```

## CSRF・セキュリティの問題

### 🔐 CSRF verification failed

**症状**: `CSRF verification failed. Request aborted.`

**解決方法**:
```bash
# CSRF設定の確認
make check-csrf

# ドメイン設定の修正
make configure-domain

# CSRF設定の自動修正
make fix-csrf

# .env ファイル確認
grep -E "ALLOWED_HOSTS|CSRF_TRUSTED_ORIGINS" .env
```

### 🚫 DisallowedHost エラー

**症状**: `DisallowedHost at / Invalid HTTP_HOST header`

**解決方法**:
```bash
# ALLOWED_HOSTS 設定を更新
make configure-domain

# 手動で .env 編集
# ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com
```

## 🔍 一般的なデバッグ手順

### ログ確認方法
```bash
# Django ログ
tail -f django.log

# システムログ（Linux）
sudo journalctl -xeu kokkosofter.service

# Nginx ログ
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### 設定確認
```bash
# Django 設定チェック
python manage.py check --deploy

# システム情報
make help

# Python 環境
python manage.py shell
>>> import sys; print(sys.executable)
>>> import django; print(django.VERSION)
```

## 🆘 サポート

上記で解決しない場合:

1. [GitHub Issues](https://github.com/hatane-rgb/KokkoSofter/issues) で検索・報告
2. エラーメッセージ全体をコピー
3. 実行環境（OS、Pythonバージョンなど）を記載
4. 実行したコマンドと手順を明記

## 📞 緊急時の復旧手順

### 完全リセット（開発環境）
```bash
# 仮想環境・データベース・キャッシュをすべて削除
rm -rf venv db.sqlite3 node_modules package-lock.json
find . -name "__pycache__" -exec rm -rf {} +

# 最初からセットアップ
make full-setup
```

### 本番環境の復旧
```bash
# サービス停止
sudo systemctl stop kokkosofter

# バックアップからDB復旧（必要に応じて）
# バックアップがある場合の手順をここに記載

# 再デプロイ
./deploy.sh production
```

---

**🔧 問題が解決しない場合は、エラーメッセージとともに [Issues](https://github.com/hatane-rgb/KokkoSofter/issues) に報告してください。**
