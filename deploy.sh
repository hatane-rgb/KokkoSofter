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

# 仮想環境のトラブルシューティング用関数
troubleshoot_venv() {
    print_error "仮想環境のトラブルシューティング:"
    print_error "======================================"
    print_error "1. Pythonが正しくインストールされているか確認:"
    print_error "   python --version または python3 --version"
    print_error ""
    print_error "2. venvモジュールがインストールされているか確認:"
    if [ "$OS_TYPE" = "linux" ]; then
        print_error "   Ubuntu/Debian: sudo apt install python3-venv"
        print_error "   CentOS/RHEL/Fedora: sudo dnf install python3-venv"
    elif [ "$OS_TYPE" = "macos" ]; then
        print_error "   brew install python (Homebrewを使用)"
    elif [ "$OS_TYPE" = "windows" ]; then
        print_error "   Python for Windowsを公式サイトからダウンロード"
    fi
    print_error ""
    print_error "3. 手動で仮想環境を作成:"
    print_error "   python -m venv venv"
    print_error "   または python3 -m venv venv"
    print_error ""
    print_error "4. ディスク容量と権限を確認"
    print_error "======================================"
}

# OS検出
detect_os() {
    # より詳細なOS検出
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OS" == "Windows_NT" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        # 追加の検出ロジック
        if [[ -f "/proc/version" ]]; then
            if grep -q "Microsoft\|WSL" /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
        elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
            # VS Code統合ターミナルの場合、環境変数をチェック
            if [[ -n "$PROCESSOR_IDENTIFIER" ]]; then
                echo "windows"
            else
                echo "unknown"
            fi
        else
            echo "unknown"
        fi
    fi
}

OS_TYPE=$(detect_os)
print_info "検出されたOS: $OS_TYPE"
print_info "OSTYPE: $OSTYPE"
print_info "OS環境変数: $OS"

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

# 現在のディレクトリを取得
CURRENT_DIR="$(pwd)"

# 環境に応じてプロジェクトディレクトリを設定
if [ "$ENVIRONMENT" = "production" ]; then
    # 本番環境では適切なプロジェクトディレクトリを決定
    if [ "$OS_TYPE" = "windows" ]; then
        # Windowsでは現在のディレクトリを使用
        PROJECT_DIR="$CURRENT_DIR"
    else
        # Linux/Unix本番環境では /var/www/kokkosofter を使用
        PROJECT_DIR="/var/www/kokkosofter"
        
        # プロジェクトディレクトリが存在しない場合は作成してコピー
        if [ ! -d "$PROJECT_DIR" ]; then
            print_info "本番環境用プロジェクトディレクトリを作成中..."
            sudo mkdir -p "$PROJECT_DIR"
            
            print_info "プロジェクトファイルをコピー中..."
            print_info "コピー元: $CURRENT_DIR"
            print_info "コピー先: $PROJECT_DIR"
            
            # 隠しファイルも含めてコピー
            if sudo cp -r "$CURRENT_DIR/"* "$PROJECT_DIR/" && sudo cp -r "$CURRENT_DIR/".* "$PROJECT_DIR/" 2>/dev/null; then
                print_success "✅ プロジェクトファイルのコピーが完了しました"
            else
                print_warning "⚠️ 一部のファイルコピーに失敗した可能性があります"
            fi
            
            sudo chown -R $(whoami):$(whoami) "$PROJECT_DIR"
            print_success "✅ ディレクトリの所有者を設定しました"
            
            # コピー後の確認
            print_info "コピー後のファイル確認:"
            ls -la "$PROJECT_DIR" | head -10
            
        else
            print_info "既存の本番環境ディレクトリを使用します: $PROJECT_DIR"
            
            # 既存ディレクトリの内容確認
            print_info "既存ディレクトリの内容:"
            ls -la "$PROJECT_DIR" | head -10
        fi
    fi
else
    PROJECT_DIR="$CURRENT_DIR"  # 開発環境では現在のディレクトリを使用
fi

VENV_DIR="$PROJECT_DIR/venv"

print_info "KokkoSofter デプロイを開始します..."
print_info "環境: $ENVIRONMENT"
print_info "プロジェクトディレクトリ: $PROJECT_DIR"
print_info "現在のディレクトリ: $(pwd)"

# Git所有者問題の解決
print_info "Git設定を確認中..."
print_info "プロジェクトディレクトリ移動前: $(pwd)"

cd "$PROJECT_DIR"
print_info "プロジェクトディレクトリに移動しました: $(pwd)"

# ディレクトリ移動の検証
if [ "$(pwd)" != "$PROJECT_DIR" ]; then
    print_error "❌ ディレクトリ移動に失敗しました"
    print_error "期待: $PROJECT_DIR"
    print_error "実際: $(pwd)"
    exit 1
fi

# 必要なファイルの存在確認
print_info "必要なファイルの存在確認中..."
print_info "現在のディレクトリ: $(pwd)"
print_info "ディレクトリ内のファイル一覧:"
ls -la | head -20  # 最初の20行のみ表示

REQUIRED_FILES=("manage.py")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    print_info "ファイル '$file' をチェック中..."
    
    # より詳細なファイル存在チェック
    if [ -f "$file" ]; then
        print_success "✅ $file が見つかりました"
        # ファイルの詳細情報も表示
        ls -la "$file" 2>/dev/null || stat "$file" 2>/dev/null || echo "ファイル情報の取得に失敗"
    elif [ -e "$file" ]; then
        print_warning "⚠️ $file は存在しますが、通常ファイルではありません"
        ls -la "$file" 2>/dev/null || stat "$file" 2>/dev/null || echo "ファイル情報の取得に失敗"
    else
        print_warning "⚠️ $file が見つかりません"
        MISSING_FILES+=("$file")
        
        # より詳細なファイル検索
        print_info "$file の類似ファイルを検索中..."
        find . -maxdepth 2 -name "*${file%.*}*" -type f 2>/dev/null || print_info "類似ファイルが見つかりません"
        
        # Windows環境での代替チェック
        if [ "$OS_TYPE" = "windows" ]; then
            print_info "Windows環境での代替チェック..."
            if command -v ls.exe >/dev/null 2>&1; then
                ls.exe -la "$file" 2>/dev/null && print_info "ls.exeで検出されました" || print_info "ls.exeでも見つかりません"
            fi
        fi
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    print_error "❌ 必要なファイルが見つかりません:"
    for file in "${MISSING_FILES[@]}"; do
        print_error "  - $file"
    done
    print_error "現在のディレクトリ: $(pwd)"
    print_error "これはDjangoプロジェクトのルートディレクトリではない可能性があります"
    
    # より詳細なデバッグ情報
    print_error "デバッグ情報:"
    print_error "- PWD環境変数: $PWD"
    print_error "- cd結果: $(pwd)"
    print_error "- 実際のディレクトリ内容:"
    ls -la . 2>/dev/null || print_error "ディレクトリの読み取りに失敗"
    
    # manage.pyを探す最後の試み
    print_error "manage.pyを広範囲で検索中..."
    find /var/www -name "manage.py" -type f 2>/dev/null | head -5 || print_error "manage.pyが見つかりません"
    
    # 本番環境の場合は、元のディレクトリを確認
    if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
        print_warning "本番環境でファイルが見つかりません。元のディレクトリを確認します..."
        print_info "元のディレクトリ: $CURRENT_DIR"
        
        if [ -f "$CURRENT_DIR/manage.py" ]; then
            print_warning "⚠️ 元のディレクトリにmanage.pyが存在します。再コピーを試行します..."
            
            # 既存のディレクトリを削除して再作成
            sudo rm -rf "$PROJECT_DIR"
            sudo mkdir -p "$PROJECT_DIR"
            
            # ファイルコピーを再実行
            print_info "プロジェクトファイルを再コピー中..."
            cd "$CURRENT_DIR"
            sudo cp -r ./* "$PROJECT_DIR/"
            sudo cp -r ./.[^.]* "$PROJECT_DIR/" 2>/dev/null || true
            sudo chown -R $(whoami):$(whoami) "$PROJECT_DIR"
            
            # 再度プロジェクトディレクトリに移動して確認
            cd "$PROJECT_DIR"
            if [ -f "manage.py" ]; then
                print_success "✅ 再コピー後にmanage.pyが見つかりました"
                # ファイルが見つかったので継続
            else
                print_error "❌ 再コピー後もmanage.pyが見つかりませんでした"
                exit 1
            fi
        else
            print_error "❌ 元のディレクトリでもmanage.pyが見つかりませんでした"
            exit 1
        fi
    else
        print_error "❌ 元のディレクトリが存在しませんでした"
        exit 1
    fi
else
    print_success "✅ 必要なファイルがすべて見つかりました"
fi

if [ -d ".git" ]; then
    # safe.directoryに追加してdubious ownership警告を解決
    git config --global --add safe.directory "$PROJECT_DIR" 2>/dev/null || true
    print_success "✅ Git safe.directory設定を追加しました"
    
    # 本番環境でのみ最新のコードを取得
    if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
        print_info "最新のコードを取得中..."
        
        # Gitの状態を確認
        if git diff --quiet && git diff --cached --quiet; then
            # 変更がない場合は通常のpull
            git pull origin main
            print_success "✅ 最新のコードを取得しました"
        else
            # ローカル変更がある場合は強制更新
            print_warning "ローカル変更が検出されました。最新版で強制更新します..."
            git fetch origin
            git reset --hard origin/main
            print_success "✅ 最新のコードで強制更新しました"
        fi
    else
        print_info "開発環境では現在のコードを使用します"
    fi
else
    print_warning "Gitリポジトリが見つかりません。現在のファイルを使用します。"
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
print_info "仮想環境ディレクトリ: $VENV_DIR"
if [ ! -d "$VENV_DIR" ]; then
    print_info "仮想環境を作成中..."
    
    # venvモジュールが利用可能か確認
    if ! $PYTHON_CMD -m venv --help >/dev/null 2>&1; then
        print_error "Python venvモジュールが利用できません"
        print_error "以下のコマンドでvenvモジュールをインストールしてください:"
        if [ "$OS_TYPE" = "linux" ]; then
            print_error "  sudo apt install python3-venv  # Ubuntu/Debian"
            print_error "  sudo dnf install python3-venv  # CentOS/RHEL/Fedora"
        fi
        exit 1
    fi
    
    # 仮想環境作成を実行
    if $PYTHON_CMD -m venv "$VENV_DIR"; then
        print_success "✅ 仮想環境を作成しました: $VENV_DIR"
    else
        print_error "❌ 仮想環境の作成に失敗しました"
        troubleshoot_venv
        exit 1
    fi
    
    # 仮想環境が正常に作成されたか確認
    if [ ! -d "$VENV_DIR" ]; then
        print_error "❌ 仮想環境ディレクトリが作成されませんでした"
        exit 1
    fi
    
    # アクティベーションスクリプトの存在確認
    if [ "$OS_TYPE" = "windows" ]; then
        ACTIVATE_SCRIPT="$VENV_DIR/Scripts/activate"
    else
        ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"
    fi
    
    if [ ! -f "$ACTIVATE_SCRIPT" ]; then
        print_error "❌ 仮想環境のアクティベーションスクリプトが見つかりません: $ACTIVATE_SCRIPT"
        print_error "仮想環境の作成が不完全です。再試行してください。"
        rm -rf "$VENV_DIR"  # 不完全な仮想環境を削除
        exit 1
    fi
    
else
    print_info "既存の仮想環境を使用します: $VENV_DIR"
    
    # 既存の仮想環境の健全性チェック
    if [ "$OS_TYPE" = "windows" ]; then
        ACTIVATE_SCRIPT="$VENV_DIR/Scripts/activate"
        PYTHON_EXE="$VENV_DIR/Scripts/python.exe"
    else
        ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"
        PYTHON_EXE="$VENV_DIR/bin/python"
    fi
    
    if [ ! -f "$ACTIVATE_SCRIPT" ] || [ ! -f "$PYTHON_EXE" ]; then
        print_warning "⚠️ 既存の仮想環境が破損している可能性があります"
        print_info "仮想環境を再作成します..."
        rm -rf "$VENV_DIR"
        
        if $PYTHON_CMD -m venv "$VENV_DIR"; then
            print_success "✅ 仮想環境を再作成しました"
        else
            print_error "❌ 仮想環境の再作成に失敗しました"
            troubleshoot_venv
            exit 1
        fi
    fi
fi

# 仮想環境の有効化（OS別）
print_info "仮想環境を有効化中..."
if [ "$OS_TYPE" = "windows" ]; then
    ACTIVATE_SCRIPT="$VENV_DIR/Scripts/activate"
    if [ ! -f "$ACTIVATE_SCRIPT" ]; then
        print_error "❌ Windowsの仮想環境アクティベーションスクリプトが見つかりません: $ACTIVATE_SCRIPT"
        exit 1
    fi
    source "$ACTIVATE_SCRIPT"
else
    ACTIVATE_SCRIPT="$VENV_DIR/bin/activate"
    if [ ! -f "$ACTIVATE_SCRIPT" ]; then
        print_error "❌ 仮想環境アクティベーションスクリプトが見つかりません: $ACTIVATE_SCRIPT"
        exit 1
    fi
    source "$ACTIVATE_SCRIPT"
fi

# 仮想環境が正常に有効化されたか確認
if [ -z "$VIRTUAL_ENV" ]; then
    print_warning "⚠️ 仮想環境の有効化に失敗した可能性があります"
    print_info "手動で仮想環境を有効化してください:"
    if [ "$OS_TYPE" = "windows" ]; then
        print_info "  $VENV_DIR\\Scripts\\activate"
    else
        print_info "  source $VENV_DIR/bin/activate"
    fi
else
    print_success "✅ 仮想環境が正常に有効化されました: $VIRTUAL_ENV"
fi

# 依存関係のインストール
print_info "Python依存関係をインストール中..."
print_info "現在のディレクトリ: $(pwd)"
print_info "利用可能なrequirementsファイル:"
ls -la requirements*.txt 2>/dev/null || print_warning "requirements*.txtファイルが見つかりません"

pip install --upgrade pip

# 環境とOSに応じたrequirementsファイルの選択
if [ "$ENVIRONMENT" = "development" ] || [ "$OS_TYPE" = "windows" ]; then
    if [ -f "requirements-dev.txt" ]; then
        print_info "開発環境用依存関係（PostgreSQLなし）をインストール中..."
        if pip install -r requirements-dev.txt; then
            print_success "✅ 開発環境用依存関係のインストールが完了しました"
        else
            print_error "❌ requirements-dev.txt からの依存関係インストールに失敗しました"
            exit 1
        fi
    elif [ -f "requirements.txt" ]; then
        print_warning "requirements-dev.txt が見つかりません。requirements.txt を使用します。"
        if pip install -r requirements.txt; then
            print_success "✅ 依存関係のインストールが完了しました"
        else
            print_error "❌ requirements.txt からの依存関係インストールに失敗しました"
            exit 1
        fi
    else
        print_error "❌ requirements-dev.txt も requirements.txt も見つかりません"
        print_error "以下のファイルのいずれかが必要です:"
        print_error "  - requirements-dev.txt (開発環境用)"
        print_error "  - requirements.txt (本番環境用)"
        print_error "現在のディレクトリ: $(pwd)"
        print_error "ファイル一覧:"
        ls -la *.txt 2>/dev/null || print_error "  txtファイルが見つかりません"
        exit 1
    fi
else
    if [ -f "requirements.txt" ]; then
        print_info "本番環境用依存関係をインストール中..."
        if pip install -r requirements.txt; then
            print_success "✅ 本番環境用依存関係のインストールが完了しました"
        else
            print_error "❌ requirements.txt からの依存関係インストールに失敗しました"
            exit 1
        fi
    else
        print_error "❌ requirements.txt が見つかりません"
        print_error "本番環境では requirements.txt が必要です"
        print_error "現在のディレクトリ: $(pwd)"
        print_error "ファイル一覧:"
        ls -la *.txt 2>/dev/null || print_error "  txtファイルが見つかりません"
        exit 1
    fi
fi

print_success "Python依存関係のインストールが完了しました"

# 本番環境では早期に権限設定を行う
if [ "$ENVIRONMENT" = "production" ] && [ "$OS_TYPE" != "windows" ]; then
    print_info "必要なディレクトリを作成中..."
    sudo mkdir -p /var/log/kokkosofter /var/run/kokkosofter
    sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
    sudo chmod 755 /var/log/kokkosofter /var/run/kokkosofter

    # プロジェクトディレクトリの所有者を設定
    print_info "プロジェクトディレクトリの権限を設定中..."
    sudo chown -R www-data:www-data $PROJECT_DIR
    sudo chmod -R 755 $PROJECT_DIR

    # 静的ファイルとメディアファイルの権限を事前設定
    sudo mkdir -p $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    sudo mkdir -p $PROJECT_DIR/media/avatars $PROJECT_DIR/media/post_images
    sudo chown -R www-data:www-data $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    sudo chmod -R 755 $PROJECT_DIR/static $PROJECT_DIR/media $PROJECT_DIR/staticfiles
    
    print_success "✅ 権限設定が完了しました"
fi

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
