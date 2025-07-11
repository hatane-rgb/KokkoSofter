# KokkoSofter PowerShellデプロイスクリプト
# Usage: .\deploy.ps1 [production|development]

param(
    [string]$Environment = "development"
)

# エラー時に停止
$ErrorActionPreference = "Stop"

# 色付きメッセージ用の関数
function Write-InfoMessage {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-SuccessMessage {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# OS検出
function Get-OperatingSystem {
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        return "windows"
    } elseif ($IsLinux) {
        return "linux"
    } elseif ($IsMacOS) {
        return "macos"
    } else {
        return "unknown"
    }
}

$OS_TYPE = Get-OperatingSystem
Write-InfoMessage "検出されたOS: $OS_TYPE"

# 現在のディレクトリを保存
$CURRENT_DIR = Get-Location

Write-InfoMessage "======================================"
Write-InfoMessage "🚀 KokkoSofter デプロイスクリプト"
Write-InfoMessage "======================================"
Write-InfoMessage "環境: $Environment"
Write-InfoMessage "作業ディレクトリ: $CURRENT_DIR"

# 必要なファイルのチェック
Write-InfoMessage "必要なファイルをチェック中..."

$REQUIRED_FILES = @("manage.py")
if (Test-Path "requirements-dev.txt") {
    $REQUIRED_FILES += "requirements-dev.txt"
} else {
    $REQUIRED_FILES += "requirements.txt"
}
$REQUIRED_FILES += "package.json"

$MISSING_FILES = @()

foreach ($file in $REQUIRED_FILES) {
    Write-InfoMessage "ファイル '$file' をチェック中..."
    if (Test-Path $file) {
        Write-SuccessMessage "✅ $file が見つかりました"
        Get-ChildItem $file | Format-Table -AutoSize
    } else {
        Write-WarningMessage "⚠️ $file が見つかりません"
        $MISSING_FILES += $file
    }
}

if ($MISSING_FILES.Count -gt 0) {
    Write-ErrorMessage "❌ 必要なファイルが見つかりません:"
    foreach ($file in $MISSING_FILES) {
        Write-ErrorMessage "  - $file"
    }
    Write-ErrorMessage "現在のディレクトリ: $(Get-Location)"
    Write-ErrorMessage "これはDjangoプロジェクトのルートディレクトリではない可能性があります"
    
    # 詳細なデバッグ情報
    Write-ErrorMessage "デバッグ情報:"
    Write-ErrorMessage "- 現在のディレクトリ: $(Get-Location)"
    Write-ErrorMessage "- ディレクトリ内容:"
    Get-ChildItem . | Format-Table -AutoSize
    
    exit 1
}

# Python環境の確認とセットアップ
Write-InfoMessage "======================================"
Write-InfoMessage "🐍 Python環境のセットアップ"
Write-InfoMessage "======================================"

# Pythonコマンドの確認
$PYTHON_CMD = $null
$PYTHON_COMMANDS = @("python", "python3", "py")

foreach ($cmd in $PYTHON_COMMANDS) {
    try {
        $version = & $cmd --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $PYTHON_CMD = $cmd
            Write-SuccessMessage "✅ Pythonコマンド見つかりました: $cmd ($version)"
            break
        }
    } catch {
        continue
    }
}

if (-not $PYTHON_CMD) {
    Write-ErrorMessage "❌ Pythonが見つかりません。Pythonをインストールしてください。"
    Write-ErrorMessage "Windows: https://www.python.org/downloads/"
    exit 1
}

# 仮想環境の作成・アクティベート
Write-InfoMessage "仮想環境をセットアップ中..."

if (-not (Test-Path "venv")) {
    Write-InfoMessage "仮想環境を作成中..."
    try {
        & $PYTHON_CMD -m venv venv
        Write-SuccessMessage "✅ 仮想環境が作成されました"
    } catch {
        Write-ErrorMessage "❌ 仮想環境の作成に失敗しました: $_"
        Write-ErrorMessage "トラブルシューティング:"
        Write-ErrorMessage "1. 管理者権限で実行してみてください"
        Write-ErrorMessage "2. ウイルス対策ソフトがブロックしていないか確認してください"
        Write-ErrorMessage "3. ディスク容量を確認してください"
        exit 1
    }
} else {
    Write-InfoMessage "✅ 仮想環境は既に存在します"
}

# 仮想環境のアクティベート
Write-InfoMessage "仮想環境をアクティベート中..."
$VENV_ACTIVATE = "venv\Scripts\Activate.ps1"

if (Test-Path $VENV_ACTIVATE) {
    try {
        & $VENV_ACTIVATE
        Write-SuccessMessage "✅ 仮想環境がアクティベートされました"
    } catch {
        Write-WarningMessage "⚠️ 仮想環境のアクティベートに失敗しました"
        Write-InfoMessage "手動でアクティベート: $VENV_ACTIVATE"
    }
} else {
    Write-ErrorMessage "❌ アクティベートスクリプトが見つかりません: $VENV_ACTIVATE"
    exit 1
}

# Pythonパッケージのインストール
Write-InfoMessage "======================================"
Write-InfoMessage "📦 Pythonパッケージのインストール"
Write-InfoMessage "======================================"

# requirements.txtの選択
$REQUIREMENTS_FILE = "requirements.txt"
if ($Environment -eq "development" -and $OS_TYPE -eq "windows") {
    if (Test-Path "requirements-dev.txt") {
        $REQUIREMENTS_FILE = "requirements-dev.txt"
        Write-InfoMessage "開発環境用requirements-dev.txtを使用します"
    }
}

Write-InfoMessage "パッケージをインストール中: $REQUIREMENTS_FILE"
try {
    & python -m pip install --upgrade pip
    & python -m pip install -r $REQUIREMENTS_FILE
    Write-SuccessMessage "✅ Pythonパッケージのインストール完了"
} catch {
    Write-ErrorMessage "❌ Pythonパッケージのインストールに失敗しました: $_"
    exit 1
}

# Node.js依存関係のインストール
Write-InfoMessage "======================================"
Write-InfoMessage "📦 Node.js依存関係のインストール"
Write-InfoMessage "======================================"

# npmの確認
try {
    $npm_version = & npm --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-SuccessMessage "✅ npm見つかりました: v$npm_version"
    } else {
        throw "npm not found"
    }
} catch {
    Write-ErrorMessage "❌ npmが見つかりません。Node.jsをインストールしてください。"
    Write-ErrorMessage "https://nodejs.org/"
    exit 1
}

Write-InfoMessage "Node.js依存関係をインストール中..."
try {
    & npm install
    Write-SuccessMessage "✅ Node.js依存関係のインストール完了"
} catch {
    Write-ErrorMessage "❌ Node.js依存関係のインストールに失敗しました: $_"
    exit 1
}

# TailwindCSSのビルド
Write-InfoMessage "======================================"
Write-InfoMessage "🎨 TailwindCSSのビルド"
Write-InfoMessage "======================================"

Write-InfoMessage "TailwindCSSをビルド中..."
try {
    & npm run build
    Write-SuccessMessage "✅ TailwindCSSビルド完了"
} catch {
    Write-WarningMessage "⚠️ TailwindCSSビルドに失敗しました - 手動で 'npm run build' を実行してください"
}

# Django設定
Write-InfoMessage "======================================"
Write-InfoMessage "⚙️ Djangoセットアップ"
Write-InfoMessage "======================================"

# データベースマイグレーション
Write-InfoMessage "データベースマイグレーションを実行中..."
try {
    & python manage.py makemigrations
    & python manage.py migrate
    Write-SuccessMessage "✅ データベースマイグレーション完了"
} catch {
    Write-ErrorMessage "❌ データベースマイグレーションに失敗しました: $_"
    exit 1
}

# 静的ファイルの収集
if ($Environment -eq "production") {
    Write-InfoMessage "静的ファイルを収集中..."
    try {
        & python manage.py collectstatic --noinput
        Write-SuccessMessage "✅ 静的ファイル収集完了"
    } catch {
        Write-ErrorMessage "❌ 静的ファイル収集に失敗しました: $_"
        exit 1
    }
}

# スーパーユーザー作成（開発環境のみ）
if ($Environment -eq "development") {
    Write-InfoMessage "スーパーユーザーを作成しますか？ (y/N)"
    $create_superuser = Read-Host
    if ($create_superuser -eq "y" -or $create_superuser -eq "Y") {
        try {
            & python manage.py createsuperuser
        } catch {
            Write-WarningMessage "⚠️ スーパーユーザー作成をスキップしました"
        }
    }
}

# 完了メッセージ
Write-InfoMessage "======================================"
Write-SuccessMessage "🎉 デプロイ完了！"
Write-InfoMessage "======================================"

if ($Environment -eq "development") {
    Write-InfoMessage "開発サーバーを起動するには:"
    Write-InfoMessage "  .\venv\Scripts\Activate.ps1"
    Write-InfoMessage "  python manage.py runserver"
    Write-InfoMessage ""
    Write-InfoMessage "または自動起動:"
    $auto_start = Read-Host "開発サーバーを今すぐ起動しますか？ (y/N)"
    if ($auto_start -eq "y" -or $auto_start -eq "Y") {
        Write-InfoMessage "開発サーバーを起動中..."
        & python manage.py runserver 0.0.0.0:8000
    }
} else {
    Write-InfoMessage "本番環境用の設定が完了しました。"
    Write-InfoMessage "Webサーバー（Apache/Nginx）の設定を行ってください。"
}
