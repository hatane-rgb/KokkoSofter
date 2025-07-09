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
- 👑 **管理者ダッシュボード** - ユーザー・投稿管理
- 🗑️ **投稿削除機能** - 権限に応じた削除制御
- ⚙️ **権限管理システム** - スタッフ・アクティブ状態切り替え

## 🎮 主な機能

### 👤 ユーザー機能
- **アカウント登録・ログイン**: セキュアな認証システム
- **プロフィール管理**: アバター画像・自己紹介の設定
- **投稿作成**: テキスト・画像投稿
- **いいね機能**: 投稿への反応
- **投稿削除**: 自分の投稿のみ削除可能

### 👑 管理者機能
- **管理ダッシュボード**: システム統計・概要表示
- **ユーザー管理**: 
  - 新規ユーザー作成（権限設定含む）
  - ユーザー情報編集
  - アクティブ/非アクティブ切り替え
  - スタッフ権限の付与・削除
  - ユーザー削除（安全な削除制御）
- **投稿管理**:
  - 全投稿の一覧・詳細表示
  - 不適切投稿の削除
  - 投稿統計の確認
- **システム管理**: Django管理画面へのアクセス

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
make fix-media          # メディアファイル権限修正
make check-media        # メディアファイル設定確認
```

### 📦 初期化・Git管理
```bash
make install            # 依存関係インストール
make git-init           # Gitリポジトリ初期化
make fix-git-owner      # Git所有者問題修正
make git-pull           # 最新コード取得
make start              # 簡単開発開始（環境構築+サーバー起動）
```

### 👑 管理者向け機能

**ユーザー管理:**
- 管理ダッシュボード: `/accounts/admin-dashboard/`
- ユーザー一覧: `/accounts/admin-users/`
- ユーザー作成: `/accounts/admin-create-user/`
- ユーザー編集: `/accounts/admin-edit-user/<user_id>/`

**投稿管理:**
- 投稿管理画面: `/posts/admin-posts/`
- 投稿削除: Ajax対応の確認モーダル

**権限制御:**
- 管理者: 全投稿削除・全ユーザー管理可能
- 一般ユーザー: 自分の投稿のみ削除可能
- アクティブ/非アクティブ切り替え
- スタッフ権限の付与・削除

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
ALLOWED_HOSTS=localhost,127.0.0.1,192.168.x.x,your-domain.com

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

#### 7. 管理画面にアクセスできない

**原因**: スタッフ権限が付与されていない

**解決方法**:
```bash
# スーパーユーザーを作成
make superuser

# または既存ユーザーにスタッフ権限を付与
# Django管理画面でユーザー編集
```

#### 8. 投稿削除ボタンが表示されない

**原因**: 権限不足または投稿作成者不一致

**確認方法**:
- 自分の投稿かどうか確認
- 管理者権限があるかどうか確認
- JavaScript エラーがないかブラウザコンソール確認

#### 9. Ajax削除が失敗する

**原因**: CSRF トークンまたは権限の問題

**解決方法**:
```bash
# CSRF設定確認
make check-csrf

# ブラウザでCSRFトークンが正しく送信されているか確認
# 開発者ツール > Network タブで確認
```

#### 10. メディアファイルが表示されない

**原因**: ファイル権限またはNginx設定の問題

**解決方法**:
```bash
# メディアファイル権限修正
make fix-media

# メディア設定確認
make check-media

# Nginx設定確認
sudo nginx -t
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
│   ├── views.py            # 管理者ダッシュボード・ユーザー管理
│   ├── forms.py            # 管理者用フォーム
│   └── urls.py             # 管理者用URL
├── core/                    # コア機能
├── posts/                   # 投稿機能
│   ├── views.py            # 投稿削除・管理機能
│   └── urls.py             # 投稿管理URL
├── templates/               # HTMLテンプレート
│   ├── base.html           # ベーステンプレート（管理者メニュー含む）
│   ├── home.html           # ホーム画面（投稿削除機能含む）
│   ├── accounts/           # アカウント関連テンプレート
│   │   ├── admin_dashboard.html    # 管理者ダッシュボード
│   │   ├── admin_users.html        # ユーザー管理画面
│   │   ├── admin_create_user.html  # ユーザー作成画面
│   │   └── admin_edit_user.html    # ユーザー編集画面
│   └── posts/              # 投稿関連テンプレート
│       └── admin_posts.html        # 投稿管理画面
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
- ✅ **権限ベースアクセス制御**: `@staff_member_required`デコレータ
- ✅ **投稿削除権限制御**: 作成者・管理者のみ削除可能
- ✅ **ユーザー管理権限**: スーパーユーザーのみスタッフ権限変更可能
- ✅ **Ajax CSRF保護**: 非同期リクエストのセキュリティ
- ✅ **安全な削除確認**: モーダル確認・二重削除防止

## 🛡️ 権限システム

### ユーザー種別
1. **一般ユーザー** (`is_active=True, is_staff=False`)
   - 投稿作成・いいね
   - 自分の投稿削除のみ
   - プロフィール編集

2. **スタッフユーザー** (`is_staff=True`)
   - 管理ダッシュボードアクセス
   - 全投稿の削除・管理
   - ユーザー一覧・編集
   - アクティブ状態切り替え

3. **スーパーユーザー** (`is_superuser=True`)
   - Django管理画面フルアクセス
   - スタッフ権限の付与・削除
   - システム全体の管理

### 安全性対策
- **自己削除防止**: 自分自身のユーザー削除不可
- **スーパーユーザー保護**: 一般スタッフによる変更不可
- **段階的権限**: 必要最小限の権限付与
- **監査ログ**: Django管理画面での変更履歴

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
