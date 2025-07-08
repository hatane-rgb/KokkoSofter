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
PROJECT_DIR=$(pwd)
VENV_DIR="venv"

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

# 仮想環境の有効化
print_info "仮想環境を有効化中..."
source $VENV_DIR/bin/activate

# 依存関係のインストール
print_info "依存関係をインストール中..."
pip install --upgrade pip
pip install -r requirements.txt
print_success "依存関係のインストールが完了しました"

# 環境変数ファイルの確認
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        print_warning ".env ファイルが見つかりません。.env.example をコピーします"
        cp .env.example .env
        print_warning "!!! .env ファイルを編集して適切な値を設定してください !!!"
    else
        print_error ".env.example ファイルが見つかりません"
        exit 1
    fi
fi

# Django プロジェクトディレクトリに移動
cd KokkoSofter

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
    print_info "  gunicorn --bind 0.0.0.0:8000 KokkoSofter.wsgi:application"
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
