# 🛠️ セットアップガイド

KokkoSofterの詳細なセットアップ手順です。

## 📋 前提条件

### 必須要件
- **Python**: 3.8以上（推奨: 3.11+）
- **Node.js**: 18.0以上（推奨: 20.0+）
- **Git**: 最新版
- **データベース**: SQLite（開発）/ PostgreSQL（本番）

### 推奨環境
- **OS**: Windows 10+, macOS 12+, Ubuntu 20.04+
- **メモリ**: 4GB以上
- **ストレージ**: 1GB以上の空き容量
- **ブラウザ**: Chrome 90+, Firefox 88+, Safari 14+

## 🚀 インストール手順

### 1. リポジトリの準備

```bash
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter/KokkoSofter

# ブランチ確認
git branch -a
git checkout main
```

### 2. Python環境の構築

#### 仮想環境の作成
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate

# 仮想環境の確認
which python  # macOS/Linux
where python   # Windows
```

#### Pythonパッケージのインストール
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
