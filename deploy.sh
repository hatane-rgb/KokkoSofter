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
        SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
        sed -i "s/SECRET_KEY=your-secret-key-here-change-this-in-production/SECRET_KEY=$SECRET_KEY/" .env
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
        SECRET_KEY=$(python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
        sed -i "s/SECRET_KEY=your-secret-key-here-change-this-in-production/SECRET_KEY=$SECRET_KEY/" .env
        print_success "新しいSECRET_KEYが生成されました"
    fi
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
    print_success "本番環境のデプロイが完了しました！"
    print_info "Gunicorn でサーバーを起動するには:"
    print_info "  $VENV_DIR/bin/gunicorn --config $PROJECT_DIR/gunicorn_config.py KokkoSofter.wsgi:application"
    print_info ""
    print_info "または systemd サービスとして起動してください"
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
