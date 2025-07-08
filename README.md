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

## 🎯 本番環境運用（推奨）

本プロジェクトは本番環境での安全な運用を重視して設計されています。

### 📋 前提条件

- **OS**: Ubuntu 20.04 LTS / 22.04 LTS 推奨
- **Python**: 3.8以上
- **Web Server**: Nginx + Gunicorn
- **Process Manager**: systemd

## 🚀 本番環境セットアップ（完全自動化）

### 1. サーバー準備

```bash
# システムの更新と必要パッケージのインストール
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-venv python3-pip nginx git -y
```

### 2. プロジェクトのクローン

```bash
# プロジェクトディレクトリを作成
sudo mkdir -p /var/www/kokkosofter
sudo chown $USER:$USER /var/www/kokkosofter

# プロジェクトをクローン
cd /var/www/kokkosofter
git clone https://github.com/hatane-rgb/KokkoSofter.git .
```

### 3. 自動デプロイ実行

```bash
# デプロイスクリプトの実行権限を付与
chmod +x deploy.sh

# 本番環境のセットアップ（完全自動化）
./deploy.sh production
```

**このコマンド一発で以下が自動実行されます:**
- Python仮想環境の構築
- 依存関係のインストール
- `.env`ファイルの自動生成とSECRET_KEY設定
- **ドメイン/IPアドレスの対話式設定**
- データベースマイグレーション
- 静的ファイル収集
- systemdサービス登録・起動
- Nginx設定の適用

### 4. 起動確認

```bash
# サービス状態の確認
make service-status
make nginx-status

# ログの確認
make service-logs
```

## 🛠️ 運用コマンド（Makefile）

本番環境での日常運用に便利なコマンドが用意されています：

### 📋 ヘルプ・状態確認
```bash
make help                # 利用可能なコマンド一覧表示
make service-status      # systemdサービス状態確認
make service-logs        # systemdサービスログ表示
make nginx-status        # Nginx状態確認
make check-csrf          # CSRF関連設定確認
```

### 🚀 サービス管理
```bash
make service-restart     # systemdサービス再起動
make nginx-setup         # Nginx設定セットアップ
make nginx-test          # Nginx設定テスト
make nginx-disable-default # Nginxデフォルトサイト無効化
```

### 🌐 ドメイン・ネットワーク設定
```bash
make configure-domain    # ドメイン/IPアドレスを対話式で設定
make quick-domain-setup  # ドメイン設定→Nginx適用→再起動を一括実行
make fix-csrf           # CSRF検証エラーを修正（対話式）
```

### 🔧 開発・メンテナンス
```bash
make dev-setup          # 開発環境セットアップ
make run                # 開発サーバー起動
make migrate            # データベースマイグレーション
make static             # 静的ファイル収集
make superuser          # スーパーユーザー作成
make shell              # Django shell起動
```

### 🔒 セキュリティ・権限
```bash
make generate-secret-key # Django用SECRET_KEY生成
make fix-permissions    # ファイル権限修正
make create-dirs        # 必要なディレクトリ作成
make test-django        # Django設定テスト（セキュリティチェック含む）
```

### 🐛 デバッグ・トラブルシューティング
```bash
make debug-enable       # デバッグモード有効化（一時的・セキュリティリスク）
make debug-disable      # デバッグモード無効化
make debug-gunicorn     # デバッグモードでGunicorn起動
make check              # Djangoシステムチェック
```

### 🧹 メンテナンス・バックアップ
```bash
make clean              # 一時ファイル削除
make backup-db          # データベースバックアップ
make requirements       # requirements.txt更新
make test               # テスト実行
```

### 📦 初期化・Git管理
```bash
make install            # 依存関係インストール
make git-init           # Gitリポジトリ初期化
make start              # 簡単開発開始（環境構築+サーバー起動）
```

### 💡 よく使用するコマンド組み合わせ

**CSRF/アクセスエラー解決:**
```bash
make fix-csrf           # 対話式でドメイン設定
make check-csrf         # 設定確認
make service-restart    # 反映
```

**新しいドメイン追加:**
```bash
make quick-domain-setup # 全自動（推奨）
# または
make configure-domain && make nginx-setup && make service-restart
```

**問題発生時の確認:**
```bash
make service-logs       # エラーログ確認
make nginx-test         # Nginx設定確認
make test-django        # Django設定確認
```

**権限エラー解決:**
```bash
make fix-permissions    # ファイル権限修正
make create-dirs        # ディレクトリ再作成
make service-restart    # サービス再起動
```

## ⚙️ 設定ファイル

### 環境変数（.env）

本番環境では以下の設定が重要です：

```bash
# セキュリティ
SECRET_KEY=自動生成されます
DEBUG=False

# ホスト設定
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.8,your-domain.com

# データベース（SQLite使用、PostgreSQLも対応）
DATABASE_URL=sqlite:///db.sqlite3

# HTTPS設定（SSL証明書取得前は無効）
SECURE_SSL_REDIRECT=False
SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False
```

**重要**: `deploy.sh`実行時に`SECRET_KEY`は自動生成されます。

### ALLOWED_HOSTS設定（自動化対応）

**推奨方法（対話式設定）:**
```bash
# ドメイン/IPアドレスを対話式で設定
make configure-domain

# または一括設定（設定→適用→再起動）
make quick-domain-setup
```

**手動設定:**
アクセス可能なホストを.envファイルで手動設定：

```bash
# 例: IPアドレスとドメイン名
ALLOWED_HOSTS=192.168.1.8,er.kokkosoft.com,www.er.kokkosoft.com

# 注意: ポート番号は含めない（正しい）
ALLOWED_HOSTS=192.168.1.8

# 間違い: ポート番号を含む
ALLOWED_HOSTS=192.168.1.8:8000  # これは間違い
```

## 🔐 SSL/HTTPS設定

### HTTP運用（初期設定）

現在の設定はHTTP運用用に最適化されています：

- **HTTPSリダイレクトは無効** （`SECURE_SSL_REDIRECT=False`）
- **Nginx設定でHTTPSリダイレクトはコメントアウト**
- **IPアドレスでのアクセスを優先**

### HTTPS対応の手順

SSL証明書を取得してHTTPS運用に移行する場合：

#### 1. SSL証明書の取得（Let's Encrypt推奨）

```bash
# Certbotのインストール
sudo apt install certbot python3-certbot-nginx -y

# SSL証明書の取得（ドメイン名が必要）
sudo certbot --nginx -d er.kokkosoft.com -d www.er.kokkosoft.com
```

#### 2. Django設定でHTTPSリダイレクトを有効化

```bash
# .envファイルでHTTPS設定を有効化
echo "SECURE_SSL_REDIRECT=True" >> /var/www/kokkosofter/.env
echo "SESSION_COOKIE_SECURE=True" >> /var/www/kokkosofter/.env
echo "CSRF_COOKIE_SECURE=True" >> /var/www/kokkosofter/.env

# HSTSの有効化（推奨）
echo "SECURE_HSTS_SECONDS=31536000" >> /var/www/kokkosofter/.env
echo "SECURE_HSTS_INCLUDE_SUBDOMAINS=True" >> /var/www/kokkosofter/.env
echo "SECURE_HSTS_PRELOAD=True" >> /var/www/kokkosofter/.env
```

#### 3. Nginx設定でHTTPSリダイレクトを有効化

```bash
# nginx_kokkosofter.confのHTTPSリダイレクトを有効化
sudo nano /etc/nginx/sites-available/kokkosofter

# 以下の行のコメントを外す:
# return 301 https://$server_name$request_uri;

# Nginx設定をリロード
sudo nginx -t
sudo systemctl reload nginx
```

#### 4. Django サービス再起動

```bash
make service-restart
```

### HTTPS転送の制御

**無効化（HTTP運用）:**
```bash
# Django側（.env）
SECURE_SSL_REDIRECT=False

# Nginx側（nginx_kokkosofter.conf）
# return 301 https://$server_name$request_uri;  # コメントアウト
```

**有効化（HTTPS運用）:**
```bash
# Django側（.env）
SECURE_SSL_REDIRECT=True

# Nginx側（nginx_kokkosofter.conf）
return 301 https://$server_name$request_uri;  # コメント解除
```

### SSL証明書の自動更新

```bash
# Crontabに追加（月2回更新チェック）
sudo crontab -e

# 以下を追加:
0 12 * * 0 certbot renew --quiet && systemctl reload nginx
```

## 🔧 トラブルシューティング

### よくある問題と解決方法

#### 1. "Welcome to nginx" が表示される

**原因**: Nginx設定が適用されていない

**解決方法**:
```bash
make nginx-setup
make service-restart
```

#### 2. Server Error (500)

**原因**: アプリケーションエラー

**解決方法**:
```bash
# ログの確認
make service-logs
sudo tail -50 /var/log/kokkosofter/gunicorn_error.log

# 一般的な解決方法
make fix-permissions
make migrate
make static
make service-restart
```

#### 3. PR_END_OF_FILE_ERROR

**原因**: SSL/TLS設定またはプロキシ設定の問題

**解決方法**:
```bash
# サービス状態確認
make service-status
make nginx-status

# ログ確認
make service-logs
sudo journalctl -u nginx -f
```

#### 4. DisallowedHost エラー

**原因**: ALLOWED_HOSTSにアクセス元が含まれていない

**解決方法**:
```bash
# 対話式で設定
make configure-domain

# または手動で.envファイルを編集
nano /var/www/kokkosofter/.env
# ALLOWED_HOSTSにIPアドレス/ドメイン名を追加

# サービス再起動
make service-restart
```

#### 5. 権限エラー（OperationalError: attempt to write a readonly database）

**原因**: データベースファイルの権限問題

**解決方法**:
```bash
# データベースファイルの権限修正
sudo chown www-data:www-data /var/www/kokkosofter/db.sqlite3
sudo chmod 664 /var/www/kokkosofter/db.sqlite3

# プロジェクト全体の権限修正
make fix-permissions
make service-restart
```

#### 6. サービスが起動しない

**原因**: 設定ファイルやパスの問題

**解決方法**:
```bash
# 詳細ログ確認
sudo journalctl -xeu kokkosofter.service

# デバッグモードで起動
make debug-gunicorn

# 設定チェック
make test-django
```

### ログの確認方法

```bash
# アプリケーションログ
sudo journalctl -u kokkosofter -f

# Nginxログ
sudo journalctl -u nginx -f
sudo tail -f /var/log/nginx/error.log

# アプリケーション固有ログ
sudo tail -f /var/log/kokkosofter/django.log
sudo tail -f /var/log/kokkosofter/gunicorn_error.log
```

## 🔄 更新・メンテナンス

### アプリケーションの更新

```bash
# 最新コードを取得
cd /var/www/kokkosofter
git pull origin main

# 依存関係とデータベースの更新
make migrate
make static

# サービス再起動
make service-restart
```

### バックアップ

```bash
# データベースバックアップ
make backup-db

# ファイルバックアップ（必要に応じて）
sudo tar -czf /backup/kokkosofter_$(date +%Y%m%d).tar.gz /var/www/kokkosofter
```

## 💻 開発環境

開発用の簡易セットアップ：

```bash
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 開発環境セットアップ（SECRET_KEY自動生成）
make dev-setup

# 開発サーバー起動
make run
```

## 📁 プロジェクト構成

```
/var/www/kokkosofter/        # 本番環境パス
├── KokkoSofter/             # Django設定
├── accounts/                # 認証システム
├── core/                    # コア機能
├── posts/                   # 投稿機能
├── templates/               # HTMLテンプレート
├── static/                  # 静的ファイル
├── media/                   # アップロードファイル
├── venv/                    # Python仮想環境
├── .env                     # 環境設定（自動生成）
├── deploy.sh               # デプロイスクリプト
├── Makefile               # 運用コマンド
├── gunicorn_config.py     # Gunicorn設定
├── nginx_kokkosofter.conf # Nginx設定
└── kokkosofter.service    # systemdサービス
```

## 🔒 セキュリティ機能

- ✅ **SECRET_KEY自動生成**: セキュアなランダムキー
- ✅ **CSRF保護**: クロスサイトリクエストフォージェリ対策
- ✅ **XSS保護**: クロスサイトスクリプティング対策  
- ✅ **セキュリティヘッダー**: Nginx経由で適用
- ✅ **ファイルアップロード制限**: サイズと種類の制限
- ✅ **HTTPS対応**: SSL証明書設定（コメントアウト済み）
- ✅ **HSTS対応**: HTTP Strict Transport Security
- ✅ **環境別セキュリティ設定**: 開発・本番環境の自動切り替え

## 🆘 サポート

問題が発生した場合：

1. **ログ確認**: `make service-logs`
2. **サービス状態**: `make service-status`
3. **Issue作成**: [GitHub Issues](https://github.com/hatane-rgb/KokkoSofter/issues)

## 📝 ライセンス

このプロジェクトはMITライセンスです。

---

**🎯 本番運用を重視した設計**  
**Made with ❤️ by KokkoSoft Team**
