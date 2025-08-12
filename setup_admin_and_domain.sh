#!/bin/bash

# 管理者アカウント作成とドメイン設定を一括実行するスクリプト

set -e

# 色付きメッセージ関数
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

PROJECT_DIR="/var/www/kokkosofter"

# プロジェクトディレクトリに移動
cd "$PROJECT_DIR"

print_info "========================================"
print_info "🔐 管理者アカウントの作成"
print_info "========================================"
print_info "KokkoSofterにログインするための管理者アカウントを作成します。"
echo

read -p "管理者アカウントを作成しますか？ [Y/n]: " CREATE_ADMIN

if [[ "$CREATE_ADMIN" =~ ^([nN][oO]|[nN])$ ]]; then
    print_warning "管理者アカウントの作成をスキップしました。"
else
    print_info "管理者アカウントを作成中..."
    source venv/bin/activate
    python manage.py createsuperuser
    print_success "✅ 管理者アカウントの作成が完了しました"
fi

echo
print_info "========================================"
print_info "🌐 ドメイン設定"
print_info "========================================"
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
    print_warning "ドメイン設定をスキップしました。"
    print_warning "後で以下の手順で設定してください："
    print_warning "  1. cd /var/www/kokkosofter"
    print_warning "  2. make configure-domain"
else
    print_info "📝 .envファイルのALLOWED_HOSTSを更新中..."
    
    # .envファイルが存在しない場合は作成
    if [ ! -f .env ]; then
        print_info ".envファイルが存在しないため、.env.exampleからコピーします..."
        cp .env.example .env
    fi
    
    # ALLOWED_HOSTSを更新
    sed -i.bak "s/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=localhost,127.0.0.1,$DOMAIN_INPUT/" .env
    print_success "✅ .envファイルのALLOWED_HOSTSを更新しました"
    
    # CSRF_TRUSTED_ORIGINSを設定
    print_info "🔧 CSRF_TRUSTED_ORIGINSを設定中..."
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
    print_success "✅ CSRF_TRUSTED_ORIGINSを設定しました"
    
    # Nginx設定を更新
    print_info "🔧 Nginx設定ファイルのserver_nameを更新中..."
    ALL_DOMAINS=$(echo "$DOMAIN_INPUT" | sed 's/,/ /g')
    sed -i.bak "0,/server_name .*/s//server_name $ALL_DOMAINS;/" nginx_kokkosofter.conf
    print_success "✅ Nginx設定ファイルを更新しました"
    
    # 設定をコピーしてNginxをリロード
    print_info "🔧 Nginx設定を適用中..."
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
        exit 1
    fi
    
    # サービス再起動
    print_info "🔄 KokkoSofterサービスを再起動中..."
    sudo systemctl restart kokkosofter
    print_success "✅ KokkoSofterサービスの再起動が完了しました"
    
    print_info ""
    print_info "📋 設定内容確認:"
    print_info "================================"
    print_info "ALLOWED_HOSTS: localhost,127.0.0.1,$DOMAIN_INPUT"
    print_info "Nginx server_name: $ALL_DOMAINS"
    grep "CSRF_TRUSTED_ORIGINS=" .env | head -1 || echo "CSRF_TRUSTED_ORIGINS: 設定なし"
    print_info "================================"
fi

print_info ""
print_info "🎉 セットアップが完了しました！"
print_info ""
print_info "📊 サービス状態を確認:"
print_info "  sudo systemctl status kokkosofter"
print_info "  sudo systemctl status nginx"
print_info ""
print_info "📋 ログの確認:"
print_info "  sudo journalctl -u kokkosofter -f"
print_info "  sudo journalctl -u nginx -f"
