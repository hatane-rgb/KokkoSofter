# 🚀 デプロイメントガイド

KokkoSofterの本番環境への導入方法を詳しく説明します。

## 🏗️ 本番環境アーキテクチャ

### 推奨構成
```
[ユーザー] → [Cloudflare/CDN] → [Nginx] → [Gunicorn] → [Django] → [PostgreSQL]
                                      ↓
                               [Static Files]
                               [Media Files]
```

### 技術スタック
- **Webサーバー**: Nginx
- **WSGIサーバー**: Gunicorn
- **データベース**: PostgreSQL
- **キャッシュ**: Redis
- **プロキシ**: Cloudflare（推奨）
- **OS**: Ubuntu 22.04 LTS（推奨）

## 🖥️ サーバー準備

### VPS/クラウドサーバー要件
- **CPU**: 2コア以上
- **メモリ**: 2GB以上（推奨: 4GB）
- **ストレージ**: 20GB以上
- **帯域**: 100Mbps以上

### 基本セットアップ（Ubuntu）

#### 1. システム更新
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl wget git
```

#### 2. Python環境
```bash
# Python 3.11 インストール
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# pipenv インストール（推奨）
pip3 install pipenv
```

#### 3. Node.js環境
```bash
# Node.js 20.x インストール
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# yarn インストール（任意）
npm install -g yarn
```

#### 4. データベース（PostgreSQL）
```bash
# PostgreSQL インストール
sudo apt install -y postgresql postgresql-contrib

# データベース作成
sudo -u postgres createdb kokkosofter
sudo -u postgres createuser kokkosofter_user -P
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE kokkosofter TO kokkosofter_user;"
```

#### 5. Redis（キャッシュ用）
```bash
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## 📁 アプリケーションデプロイ

### 1. コードのデプロイ

```bash
# 本番用ディレクトリ作成
sudo mkdir -p /var/www/kokkosofter
sudo chown $USER:$USER /var/www/kokkosofter

# リポジトリクローン
cd /var/www/kokkosofter
git clone https://github.com/hatane-rgb/KokkoSofter.git .
cd KokkoSofter
```

### 2. Python環境構築

```bash
# 仮想環境作成
python3.11 -m venv venv
source venv/bin/activate

# 依存関係インストール
pip install -r requirements.txt
pip install gunicorn psycopg2-binary
```

### 3. Node.js環境構築

```bash
# パッケージインストール
npm install

# 本番用CSSビルド
npm run build-css-prod
```

### 4. 環境設定

#### .env ファイル作成
```bash
cat > .env << 'EOF'
DEBUG=False
SECRET_KEY=your-super-secret-key-here
ALLOWED_HOSTS=your-domain.com,www.your-domain.com

DATABASE_URL=postgresql://kokkosofter_user:password@localhost/kokkosofter

# Redis設定
REDIS_URL=redis://localhost:6379/0

# メール設定
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password

# セキュリティ設定
SECURE_SSL_REDIRECT=True
SECURE_BROWSER_XSS_FILTER=True
SECURE_CONTENT_TYPE_NOSNIFF=True
SECURE_HSTS_SECONDS=31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS=True
SECURE_HSTS_PRELOAD=True
EOF
```

#### 本番用 settings.py 調整
```python
# settings.py の最後に追加
if not DEBUG:
    # 静的ファイル設定
    STATIC_ROOT = '/var/www/kokkosofter/static/'
    STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'
    
    # セキュリティ設定
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    
    # ログ設定
    LOGGING = {
        'version': 1,
        'disable_existing_loggers': False,
        'handlers': {
            'file': {
                'level': 'WARNING',
                'class': 'logging.handlers.RotatingFileHandler',
                'filename': '/var/log/kokkosofter/django.log',
                'maxBytes': 1024*1024*15,  # 15MB
                'backupCount': 10,
            },
        },
        'root': {
            'handlers': ['file'],
        },
    }
```

### 5. データベース初期化

```bash
# マイグレーション実行
python manage.py makemigrations
python manage.py migrate

# 静的ファイル収集
python manage.py collectstatic --noinput

# スーパーユーザー作成
python manage.py createsuperuser
```

## 🔧 Webサーバー設定

### Gunicorn設定

#### gunicorn_config.py 作成
```python
# /var/www/kokkosofter/KokkoSofter/gunicorn_config.py
import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 100
preload_app = True
timeout = 30
keepalive = 2

# ログ設定
accesslog = "/var/log/kokkosofter/gunicorn_access.log"
errorlog = "/var/log/kokkosofter/gunicorn_error.log"
loglevel = "info"

# プロセス設定
user = "www-data"
group = "www-data"
pidfile = "/var/run/kokkosofter.pid"

# セキュリティ
limit_request_line = 8190
limit_request_fields = 100
limit_request_field_size = 8190
```

#### systemdサービス作成
```bash
sudo tee /etc/systemd/system/kokkosofter.service > /dev/null << 'EOF'
[Unit]
Description=KokkoSofter Gunicorn daemon
Requires=kokkosofter.socket
After=network.target

[Service]
Type=notify
User=www-data
Group=www-data
RuntimeDirectory=kokkosofter
WorkingDirectory=/var/www/kokkosofter/KokkoSofter
ExecStart=/var/www/kokkosofter/KokkoSofter/venv/bin/gunicorn \
          --config /var/www/kokkosofter/KokkoSofter/gunicorn_config.py \
          KokkoSofter.wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
```

#### socketファイル作成
```bash
sudo tee /etc/systemd/system/kokkosofter.socket > /dev/null << 'EOF'
[Unit]
Description=KokkoSofter socket

[Socket]
ListenStream=/run/kokkosofter.sock
SocketUser=www-data

[Install]
WantedBy=sockets.target
EOF
```

### Nginx設定

```bash
sudo tee /etc/nginx/sites-available/kokkosofter > /dev/null << 'EOF'
upstream kokkosofter {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL設定（Let's Encrypt）
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;

    # セキュリティヘッダー
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";

    # ログ設定
    access_log /var/log/nginx/kokkosofter_access.log;
    error_log /var/log/nginx/kokkosofter_error.log;

    # 静的ファイル
    location /static/ {
        alias /var/www/kokkosofter/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # メディアファイル
    location /media/ {
        alias /var/www/kokkosofter/media/;
        expires 7d;
        add_header Cache-Control "public";
    }

    # アプリケーション
    location / {
        proxy_pass http://kokkosofter;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # タイムアウト設定
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 最大アップロードサイズ
    client_max_body_size 50M;
}
EOF

# サイト有効化
sudo ln -s /etc/nginx/sites-available/kokkosofter /etc/nginx/sites-enabled/
sudo nginx -t
```

## 🔐 SSL証明書（Let's Encrypt）

```bash
# Certbot インストール
sudo apt install -y certbot python3-certbot-nginx

# SSL証明書取得
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 自動更新設定
sudo crontab -e
# 以下を追加
0 12 * * * /usr/bin/certbot renew --quiet
```

## 🚀 サービス起動

```bash
# ログディレクトリ作成
sudo mkdir -p /var/log/kokkosofter
sudo chown www-data:www-data /var/log/kokkosofter

# 権限設定
sudo chown -R www-data:www-data /var/www/kokkosofter
sudo chmod -R 755 /var/www/kokkosofter

# サービス起動
sudo systemctl daemon-reload
sudo systemctl enable kokkosofter.socket
sudo systemctl start kokkosofter.socket
sudo systemctl enable kokkosofter.service
sudo systemctl start kokkosofter.service

# Nginx起動
sudo systemctl enable nginx
sudo systemctl restart nginx

# 状態確認
sudo systemctl status kokkosofter
sudo systemctl status nginx
```

## 📊 監視・メンテナンス

### ログ監視

```bash
# Gunicornログ監視
sudo tail -f /var/log/kokkosofter/gunicorn_error.log

# Nginxログ監視
sudo tail -f /var/log/nginx/kokkosofter_error.log

# Djangoログ監視
sudo tail -f /var/log/kokkosofter/django.log
```

### パフォーマンス監視

```bash
# プロセス監視
ps aux | grep gunicorn
ps aux | grep nginx

# リソース使用量
htop
df -h
free -h
```

### 定期バックアップ

```bash
# バックアップスクリプト作成
sudo tee /usr/local/bin/kokkosofter_backup.sh > /dev/null << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/kokkosofter"
DATE=$(date +%Y%m%d_%H%M%S)

# ディレクトリ作成
mkdir -p $BACKUP_DIR

# データベースバックアップ
pg_dump kokkosofter > $BACKUP_DIR/db_$DATE.sql

# メディアファイルバックアップ
tar -czf $BACKUP_DIR/media_$DATE.tar.gz /var/www/kokkosofter/media/

# 古いバックアップ削除（7日以上古い）
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

sudo chmod +x /usr/local/bin/kokkosofter_backup.sh

# 自動バックアップ設定（毎日午前2時）
sudo crontab -e
# 以下を追加
0 2 * * * /usr/local/bin/kokkosofter_backup.sh
```

## 🔄 アップデート手順

```bash
# アプリケーション更新
cd /var/www/kokkosofter/KokkoSofter
git pull origin main

# 仮想環境に入る
source venv/bin/activate

# 依存関係更新
pip install -r requirements.txt

# Node.jsパッケージ更新
npm install
npm run build-css-prod

# データベースマイグレーション
python manage.py migrate

# 静的ファイル再収集
python manage.py collectstatic --noinput

# サービス再起動
sudo systemctl restart kokkosofter
sudo systemctl reload nginx
```

## 🛡️ セキュリティ強化

### ファイアウォール設定
```bash
# UFW設定
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
```

### 追加セキュリティ
```bash
# Fail2ban インストール
sudo apt install -y fail2ban

# SSH設定強化
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

## 📈 スケーリング

### 水平スケーリング
- **ロードバランサー**: Nginx + 複数のGunicornインスタンス
- **データベース**: PostgreSQL マスター・スレーブ構成
- **キャッシュ**: Redis Cluster
- **ファイルストレージ**: AWS S3, Google Cloud Storage

### 縦スケーリング
- **CPU・メモリ増強**
- **SSD使用**
- **データベース最適化**

---

[← READMEに戻る](../README.md) | [← セットアップガイド](SETUP.md) | [開発ガイド →](DEVELOPMENT.md)
