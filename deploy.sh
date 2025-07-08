#!/bin/bash

# KokkoSofter デプロイスクリプト
# Usage: ./deploy.sh [production|development]

set -e  # エラー時に停止

# 色付きメッセージ用の関数
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
    print_info "  - IPアドレスのみ: 192.168.1.8"
    print_info "  - ドメインのみ: example.com"
    print_info "  - 複数: 192.168.1.8,example.com,www.example.com"
    echo
    
    read -p "ドメイン/IPアドレスを入力 (Enterでスキップ): " DOMAIN_INPUT
    
    if [ -z "$DOMAIN_INPUT" ]; then
        print_warning "ドメイン設定をスキップしました。後で 'make configure-domain' で設定できます。"
        return 0
    fi
    
    # ALLOWED_HOSTSを更新
    print_info "📝 .envファイルのALLOWED_HOSTSを更新中..."
    sed -i.bak "s/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=localhost,127.0.0.1,$DOMAIN_INPUT/" .env
    print_success "✅ .envファイルを更新しました"
    
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
    print_success "Nginx server_name: $DOMAIN_INPUT"
    print_success "================================"
    echo
}

# 環境変数の設定
ENVIRONMENT=${1:-development}
PROJECT_DIR="/var/www/kokkosofter"
VENV_DIR="$PROJECT_DIR/venv"

print_info "KokkoSofter デプロイを開始します..."
print_info "環境: $ENVIRONMENT"
print_info "プロジェクトディレクトリ: $PROJECT_DIR"

# Python バージョンの確認
if ! command -v python3 &> /dev/null; then
    print_error "Python3 がインストールされていません"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d " " -f 2)
print_info "Python バージョン: $PYTHON_VERSION"

# 仮想環境の作成
if [ ! -d "$VENV_DIR" ]; then
    print_info "仮想環境を作成中..."
    python3 -m venv $VENV_DIR
    print_success "仮想環境を作成しました"
else
    print_info "既存の仮想環境を使用します"
fi

# プロジェクトディレクトリに移動
cd $PROJECT_DIR

# 仮想環境の有効化
print_info "仮想環境を有効化中..."
source $VENV_DIR/bin/activate

# 依存関係のインストール
print_info "依存関係をインストール中..."
pip install --upgrade pip
pip install -r requirements.txt
print_success "依存関係のインストールが完了しました"

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

# 必要なディレクトリの作成
print_info "必要なディレクトリを作成中..."
sudo mkdir -p /var/log/kokkosofter /var/run/kokkosofter
sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
sudo chmod 755 /var/log/kokkosofter /var/run/kokkosofter

# プロジェクトディレクトリの所有者を設定
sudo chown -R www-data:www-data $PROJECT_DIR
sudo chmod -R 755 $PROJECT_DIR
sudo chmod -R 644 $PROJECT_DIR/static $PROJECT_DIR/media 2>/dev/null || true

print_success "ディレクトリの作成が完了しました"

# Django プロジェクトディレクトリに移動（すでにPROJECT_DIRにいるので不要）
# cd KokkoSofter

# データベースマイグレーション
print_info "データベースマイグレーションを実行中..."
python manage.py makemigrations
python manage.py migrate
print_success "データベースマイグレーションが完了しました"

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
if [ "$ENVIRONMENT" = "production" ]; then
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
elif [ "$ENVIRONMENT" = "development" ]; then
    print_success "開発環境のセットアップが完了しました！"
    print_info "開発サーバーを起動するには:"
    print_info "  python manage.py runserver 0.0.0.0:8000"
    print_info ""
    print_info "サーバーを今すぐ起動しますか？ [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_info "開発サーバーを起動中..."
        python manage.py runserver 0.0.0.0:8000
    fi
fi

print_success "デプロイスクリプトが正常に完了しました！"
