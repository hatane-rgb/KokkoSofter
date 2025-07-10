#!/bin/bash

# KokkoSofter デプロイスクリプト
# Usage: ./deploy.sh [production|development]

set -e  # エラー時に停止

# 色付きメッセージ用の関数（最初に定義）
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

# OS検出
detect_os() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)
print_info "検出されたOS: $OS_TYPE"

# ドメイン/IPアドレス設定用の関数
configure_domain() {
    echo
    print_info "======================================"
    print_info "🌐 ドメイン/IPアドレス設定"
    print_info "======================================"
    echo
    print_info "アクセス可能にしたいドメイン名やIPアドレスを入力してください。"
    print_info "複数ある場合はカンマ区切りで入力してください。"
    echo
    print_info "例："
    print_info "  - IPアドレスのみ: 192.168.x.x"
    print_info "  - ドメインのみ: example.com"
    print_info "  - 複数: 192.168.x.x,example.com,www.example.com"
    echo
    
    read -p "ドメイン/IPアドレスを入力 (Enterでスキップ): " DOMAIN_INPUT
    
    if [ -z "$DOMAIN_INPUT" ]; then
        print_warning "ドメイン設定をスキップしました。後で 'make configure-domain' で設定できます。"
        return 0
    fi
    
    # ALLOWED_HOSTSを更新
    print_info "📝 .envファイルのALLOWED_HOSTSを更新中..."
    sed -i.bak "s/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=localhost,127.0.0.1,$DOMAIN_INPUT/" .env
    
    # CSRF_TRUSTED_ORIGINSを設定
    print_info "🔧 CSRF_TRUSTED_ORIGINSを設定中..."
    # ドメインからHTTPS/HTTPのオリジンを生成
    CSRF_ORIGINS=""
    OLD_IFS=$IFS
    IFS=','
    for domain in $DOMAIN_INPUT; do
        domain=$(echo "$domain" | sed 's/^[ \t]*//;s/[ \t]*$//')  # 空白削除
        case "$domain" in
            *[0-9].[0-9].[0-9].[0-9]*)
                # IPアドレスの場合はHTTPのみ
                CSRF_ORIGINS="${CSRF_ORIGINS}http://${domain},"
                ;;
            *)
                # ドメインの場合はHTTPS/HTTP両方
                CSRF_ORIGINS="${CSRF_ORIGINS}https://${domain},http://${domain},"
                ;;
        esac
    done
    IFS=$OLD_IFS
    # 最後のカンマを削除
    CSRF_ORIGINS=$(echo "$CSRF_ORIGINS" | sed 's/,$//')
    
    # CSRF_TRUSTED_ORIGINS設定を更新または追加
    if grep -q "^CSRF_TRUSTED_ORIGINS=" .env; then
        sed -i.bak "s|^CSRF_TRUSTED_ORIGINS=.*|CSRF_TRUSTED_ORIGINS=$CSRF_ORIGINS|" .env
    else
        echo "CSRF_TRUSTED_ORIGINS=$CSRF_ORIGINS" >> .env
    fi
    
    print_success "✅ .envファイルとCSRF設定を更新しました"
    
    # Nginx設定を更新
    print_info "🔧 Nginx設定ファイルのserver_nameを更新中..."
    FIRST_DOMAIN=$(echo "$DOMAIN_INPUT" | cut -d',' -f1)
    ALL_DOMAINS=$(echo "$DOMAIN_INPUT" | sed 's/,/ /g')
    
    # HTTP設定のserver_nameを更新
    sed -i.bak "0,/server_name .*/s//server_name $ALL_DOMAINS;/" nginx_kokkosofter.conf
    
    # HTTPS設定のserver_name（コメントアウト部分）も更新
    sed -i "s/#     server_name .*/#     server_name $ALL_DOMAINS;/" nginx_kokkosofter.conf
    
    print_success "✅ Nginx設定ファイル（HTTP/HTTPS）を更新しました"
    
    echo
    print_success "📋 設定内容:"
    print_success "================================"
    print_success "ALLOWED_HOSTS: localhost,127.0.0.1,$DOMAIN_INPUT"
    print_success "CSRF_TRUSTED_ORIGINS: $CSRF_ORIGINS"
    print_success "Nginx server_name: $DOMAIN_INPUT"
    print_success "================================"
    echo
}

# 環境変数の設定
ENVIRONMENT=${1:-development}

# 環境に応じてプロジェクトディレクトリを設定
if [ "$ENVIRONMENT" = "production" ]; then
    PROJECT_DIR="/var/www/kokkosofter"
else
    PROJECT_DIR="$(pwd)"  # 開発環境では現在のディレクトリを使用
fi

VENV_DIR="$PROJECT_DIR/venv"

print_info "KokkoSofter デプロイを開始します..."
print_info "環境: $ENVIRONMENT"
print_info "プロジェクトディレクトリ: $PROJECT_DIR"

# Git所有者問題の解決
print_info "Git設定を確認中..."
if [ -d "$PROJECT_DIR/.git" ]; then
    # safe.directoryに追加してdubious ownership警告を解決
    git config --global --add safe.directory $PROJECT_DIR 2>/dev/null || true
    print_success "✅ Git safe.directory設定を追加しました"
    
    # 本番環境でのみ最新のコードを取得
    if [ "$ENVIRONMENT" = "production" ]; then
        print_info "最新のコードを取得中..."
        cd $PROJECT_DIR
        git pull origin main
        print_success "✅ 最新のコードを取得しました"
    else
        print_info "開発環境では現在のコードを使用します"
        cd $PROJECT_DIR
    fi
else
    cd $PROJECT_DIR
fi

# Python バージョンの確認
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    if command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>&1 | grep -E "Python 3\.[8-9]|Python 3\.1[0-9]")
        if [ -n "$PYTHON_VERSION" ]; then
            PYTHON_CMD="python"
            print_info "Python3が見つかりません。pythonコマンドを使用します"
        else
            print_error "Python 3.8+ がインストールされていません"
            print_error "インストール方法: https://www.python.org/downloads/"
            exit 1
        fi
    else
        print_error "Pythonがインストールされていません"
        print_error "インストール方法: https://www.python.org/downloads/"
        exit 1
    fi
fi

PYTHON_VERSION=$($PYTHON_CMD --version | cut -d " " -f 2)
print_info "Python バージョン: $PYTHON_VERSION"

# 仮想環境の作成
if [ ! -d "$VENV_DIR" ]; then
    print_info "仮想環境を作成中..."
    $PYTHON_CMD -m venv $VENV_DIR
    print_success "仮想環境を作成しました"
else
    print_info "既存の仮想環境を使用します"
fi

# プロジェクトディレクトリに移動
cd $PROJECT_DIR

# 仮想環境の有効化（OS別）
print_info "仮想環境を有効化中..."
if [ "$OS_TYPE" = "windows" ]; then
    source $VENV_DIR/Scripts/activate
else
    source $VENV_DIR/bin/activate
fi

# 依存関係のインストール
print_info "Python依存関係をインストール中..."
pip install --upgrade pip

# 環境とOSに応じたrequirementsファイルの選択
if [ "$ENVIRONMENT" = "development" ] || [ "$OS_TYPE" = "windows" ]; then
    if [ -f "requirements-dev.txt" ]; then
        print_info "開発環境用依存関係（PostgreSQLなし）をインストール中..."
        pip install -r requirements-dev.txt
    else
        print_warning "requirements-dev.txt が見つかりません。通常版を使用します。"
        pip install -r requirements.txt
    fi
else
    print_info "本番環境用依存関係をインストール中..."
    pip install -r requirements.txt
fi

print_success "Python依存関係のインストールが完了しました"

# Node.js環境の確認とセットアップ
print_info "Node.js環境を確認中..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_info "Node.js バージョン: $NODE_VERSION"
    
    # npm依存関係のインストール
    print_info "TailwindCSS・DaisyUI依存関係をインストール中..."
    npm install
    print_success "Node.js依存関係のインストールが完了しました"
    
    # TailwindCSSのビルド
    print_info "TailwindCSSをビルド中..."
    if [ "$ENVIRONMENT" = "production" ]; then
        npm run build-css-prod 2>/dev/null || print_warning "TailwindCSS本番ビルドに失敗（手動でnpm run build-css-prodを実行してください）"
    else
        npm run build-css-prod 2>/dev/null || print_warning "TailwindCSSビルドに失敗（手動でnpm run devを実行してください）"
    fi
    print_success "TailwindCSSビルドが完了しました"
else
    print_warning "Node.jsが見つかりません。TailwindCSS・DaisyUIは手動でセットアップしてください："
    print_warning "  1. Node.js 18+をインストール"
    print_warning "  2. npm install"
    print_warning "  3. npm run build-css-prod"
fi

# 環境変数ファイルの確認と設定
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        print_warning ".env ファイルが見つかりません。.env.example をコピーします"
        cp .env.example .env
        
        # SECRET_KEYを自動生成
        print_info "SECRET_KEYを自動生成中..."
        python -c "
import re
from django.core.management.utils import get_random_secret_key
with open('.env', 'r') as f:
    content = f.read()
new_key = get_random_secret_key()
content = re.sub(r'^SECRET_KEY=.*$', f'SECRET_KEY={new_key}', content, flags=re.MULTILINE)
with open('.env', 'w') as f:
    f.write(content)
print('新しいSECRET_KEYが生成されました')
"
        print_success "新しいSECRET_KEYが生成されました"
        
        print_warning "!!! .env ファイルの他の設定も確認して必要に応じて編集してください !!!"
    else
        print_error ".env.example ファイルが見つかりません"
        exit 1
    fi
else
    # .envファイルが存在する場合、SECRET_KEYがデフォルトのままかチェック
    if grep -q "SECRET_KEY=your-secret-key-here-change-this-in-production" .env; then
        print_warning "デフォルトのSECRET_KEYが検出されました。新しいキーを生成します..."
        python -c "
import re
from django.core.management.utils import get_random_secret_key
with open('.env', 'r') as f:
    content = f.read()
new_key = get_random_secret_key()
content = re.sub(r'^SECRET_KEY=.*$', f'SECRET_KEY={new_key}', content, flags=re.MULTILINE)
with open('.env', 'w') as f:
    f.write(content)
print('新しいSECRET_KEYが生成されました')
"
        print_success "新しいSECRET_KEYが生成されました"
    fi
fi

# ドメイン/IPアドレス設定
if [ "$ENVIRONMENT" = "production" ]; then
    configure_domain
fi

# 必要なディレクトリの作成（本番環境のLinux/Unixのみ）
if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
    print_info "必要なディレクトリを作成中..."
    sudo mkdir -p /var/log/kokkosofter /var/run/kokkosofter
    sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
    sudo chmod 755 /var/log/kokkosofter /var/run/kokkosofter

    # プロジェクトディレクトリの所有者を設定
    sudo chown -R www-data:www-data $PROJECT_DIR
    sudo chmod -R 755 $PROJECT_DIR

    # 静的ファイルとメディアファイルの権限を特別に設定
    print_info "静的ファイルとメディアファイルの権限を設定中..."
    sudo mkdir -p $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    sudo mkdir -p $PROJECT_DIR/media/avatars $PROJECT_DIR/media/post_images
    sudo chown -R www-data:www-data $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    sudo chmod -R 755 $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles

    # メディアファイル内のファイルに読み取り権限を付与
    sudo find $PROJECT_DIR/media -type f -exec chmod 644 {} \; 2>/dev/null || true
    sudo find $PROJECT_DIR/media -type d -exec chmod 755 {} \; 2>/dev/null || true

    # シンボリックリンク作成（Nginxが直接アクセスできない場合の対策）
    print_info "メディアディレクトリのシンボリックリンクを確認..."
    if [ ! -L "/var/www/html/media" ]; then
        sudo ln -sf $PROJECT_DIR/media /var/www/html/media
        print_success "✅ メディアディレクトリのシンボリックリンクを作成しました"
    fi

    print_success "✅ 静的ファイルとメディアファイルの権限を設定しました"

    # データベースファイルの権限を特別に設定
    print_info "データベースファイルの権限を設定中..."
    if [ -f "$PROJECT_DIR/db.sqlite3" ]; then
        sudo chown www-data:www-data $PROJECT_DIR/db.sqlite3
        sudo chmod 664 $PROJECT_DIR/db.sqlite3
        print_success "✅ データベースファイルの権限を設定しました"
    else
        print_warning "⚠️ データベースファイルが見つかりません（マイグレーション後に作成されます）"
    fi

    # プロジェクトディレクトリ自体の書き込み権限を確保（SQLite用）
    sudo chmod 775 $PROJECT_DIR

    print_success "ディレクトリとファイル権限の設定が完了しました"
else
    print_info "開発環境またはWindowsでは権限設定をスキップします"
    # 開発環境用のディレクトリ作成
    mkdir -p $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    mkdir -p $PROJECT_DIR/media/avatars $PROJECT_DIR/media/post_images
fi

# Django プロジェクトディレクトリに移動（すでにPROJECT_DIRにいるので不要）
# cd KokkoSofter

# データベースマイグレーション
print_info "データベースマイグレーションを実行中..."
python manage.py makemigrations
python manage.py migrate
print_success "データベースマイグレーションが完了しました"

# マイグレーション後にデータベースファイルの権限を再設定（本番環境のLinux/Unixのみ）
if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
    print_info "マイグレーション後のデータベース権限を設定中..."
    if [ -f "$PROJECT_DIR/db.sqlite3" ]; then
        sudo chown www-data:www-data $PROJECT_DIR/db.sqlite3
        sudo chmod 664 $PROJECT_DIR/db.sqlite3
        print_success "✅ データベースファイルの権限を再設定しました"
    fi
fi

# 静的ファイルの収集
print_info "静的ファイルを収集中..."
python manage.py collectstatic --noinput
print_success "静的ファイルの収集が完了しました"

# スーパーユーザーの作成（開発環境のみ）
if [ "$ENVIRONMENT" = "development" ]; then
    print_info "スーパーユーザーを作成しますか？ [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        python manage.py createsuperuser
    fi
fi

# サーバー起動の準備
if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
    print_info "本番環境のNginx設定を適用中..."
    
    # Nginxデフォルトサイトを無効化
    print_info "Nginxデフォルトサイトを無効化中..."
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo rm -f /etc/nginx/sites-enabled/000-default
    
    # KokkoSofter設定をコピー
    print_info "KokkoSofter Nginx設定をコピー中..."
    sudo cp nginx_kokkosofter.conf /etc/nginx/sites-available/kokkosofter
    sudo ln -sf /etc/nginx/sites-available/kokkosofter /etc/nginx/sites-enabled/
    
    # Nginx設定テスト
    if sudo nginx -t; then
        print_success "✅ Nginx設定テストが成功しました"
        print_info "Nginxをリロード中..."
        sudo systemctl reload nginx
        print_success "✅ Nginx設定が適用されました"
    else
        print_error "❌ Nginx設定にエラーがあります"
        print_warning "手動で 'sudo nginx -t' を実行して確認してください"
    fi
    
    # systemdサービス設定
    print_info "systemdサービスを設定中..."
    sudo cp kokkosofter.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable kokkosofter
    sudo systemctl start kokkosofter
    
    print_success "本番環境のデプロイが完了しました！"
    print_info ""
    print_info "🎉 次のコマンドでサービス状態を確認してください:"
    print_info "  sudo systemctl status kokkosofter"
    print_info "  sudo systemctl status nginx"
    print_info ""
    print_info "📋 ログの確認:"
    print_info "  sudo journalctl -u kokkosofter -f"
    print_info "  sudo journalctl -u nginx -f"
elif [ "$ENVIRONMENT" = "development" ] || [ "$OS_TYPE" = "windows" ]; then
    print_success "開発環境のセットアップが完了しました！"
    print_info "開発サーバーを起動するには:"
    if [ "$OS_TYPE" = "windows" ]; then
        print_info "  venv\\Scripts\\activate && python manage.py runserver 0.0.0.0:8000"
    else
        print_info "  source venv/bin/activate && python manage.py runserver 0.0.0.0:8000"
    fi
    print_info ""
    print_info "サーバーを今すぐ起動しますか？ [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_info "開発サーバーを起動中..."
        python manage.py runserver 0.0.0.0:8000
    fi
fi

print_success "デプロイスクリプトが正常に完了しました！"
