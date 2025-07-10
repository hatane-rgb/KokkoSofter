# 🚀 KokkoSofter

モダンでスタイリッシュなチーム向けソーシャル投稿プラットフォーム

![Django](https://img.shields.io/badge/Django-5.2.4-green)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-4.1.11-blue)
![DaisyUI](https://img.shields.io/badge/DaisyUI-5.0.46-green)
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

## 🚀 クイックスタート

### 必要な環境
- Python 3.8+
- Node.js 18+ (TailwindCSS用)
- Git

### 📦 必要なアプリケーションのインストール

#### Windows
```powershell
# Python（Microsoft Store または python.org から）
winget install Python.Python.3.12

# Node.js
winget install OpenJS.NodeJS

# Git
winget install Git.Git

# または Chocolatey を使用
choco install python nodejs git
```

#### Ubuntu/Debian
```bash
# システムの更新
sudo apt update && sudo apt upgrade -y

# Python 3.8+ とpip
sudo apt install python3 python3-pip python3-venv -y

# Node.js 18+ (NodeSourceリポジトリから)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y

# Git
sudo apt install git -y

# 必要に応じて追加パッケージ
sudo apt install build-essential -y
```

#### CentOS/RHEL/Fedora
```bash
# Python 3.8+
sudo dnf install python3 python3-pip python3-venv -y

# Node.js 18+
sudo dnf install nodejs npm -y

# Git
sudo dnf install git -y
```

#### macOS
```bash
# Homebrew を使用
brew install python@3.12 node git

# または MacPorts
sudo port install python312 nodejs18 git
```

### 🎯 自動セットアップ（推奨）

#### 開発環境
```bash
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 自動セットアップ（Python + Node.js + CSS + DB）
make full-setup

# 開発サーバーを起動
make run
```

#### 本番環境（Ubuntu/Linux）
```bash
# リポジトリをクローン
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter

# 実行権限を付与
chmod +x deploy.sh

# 本番環境デプロイ（完全自動化）
./deploy.sh production
```

### 🔧 手動セットアップ

```bash
# Python仮想環境を作成・有効化
python -m venv venv
# Windows
venv\Scripts\activate
# Mac/Linux  
source venv/bin/activate

# Python依存関係をインストール
pip install -r requirements.txt

# Node.js依存関係をインストール（TailwindCSS・DaisyUI自動導入）
npm install

# TailwindCSSのビルド
npm run build

# データベースのマイグレーション
python manage.py migrate

# スーパーユーザーを作成
python manage.py createsuperuser

# 開発サーバーを起動
python manage.py runserver
```

### 📦 利用可能なコマンド

#### 🚀 セットアップ・開発
```bash
make full-setup       # 完全セットアップ（推奨）
make dev-setup        # 開発環境セットアップ
make build-css        # TailwindCSS監視モード
make build-css-prod   # TailwindCSS本番ビルド
```

#### 🔧 日常的な開発
```bash
make run              # 開発サーバー起動
make migrate          # DBマイグレーション
make superuser        # スーパーユーザー作成
make test             # テスト実行
```

## ⚠️ トラブルシューティング

### 権限エラー（Permission Denied）
```bash
# deploy.shに実行権限を付与
chmod +x deploy.sh

# Linux/macOSでの権限エラー
sudo chown -R $USER:$USER .
```

### Python/Node.js が見つからない
```bash
# Pythonバージョン確認
python3 --version
python --version

# Node.jsバージョン確認  
node --version
npm --version

# PATH設定（.bashrc または .zshrc に追加）
export PATH="/usr/local/bin:$PATH"
```

### 仮想環境の問題
```bash
# 仮想環境を削除して再作成
rm -rf venv
python3 -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

### TailwindCSS ビルドエラー
```bash
# Node.js依存関係を再インストール
rm -rf node_modules package-lock.json
npm install

# TailwindCSSビルド
npm run build
```

アプリケーションは http://127.0.0.1:8000/ でアクセス可能です。

## 📚 ドキュメント

詳細な情報は以下のドキュメントを参照してください：

- [📖 機能詳細](docs/FEATURES.md) - 全機能の詳細説明
- [🛠️ セットアップガイド](docs/SETUP.md) - 詳細なセットアップ手順  
- [🚀 デプロイメント](docs/DEPLOYMENT.md) - 本番環境への導入方法
- [🔧 開発ガイド](docs/DEVELOPMENT.md) - 開発者向け情報
- [🎨 UI/UXガイド](docs/UI_GUIDE.md) - デザインシステム・カスタマイズ

## 📋 主な機能

### 👤 ユーザー機能
- アカウント登録・ログイン・プロフィール管理
- 投稿作成（テキスト・画像）・いいね機能
- アバター設定・自己紹介編集

### 👑 管理者機能  
- ダッシュボード・統計表示
- ユーザー管理（作成・編集・権限設定）
- 投稿管理・不適切投稿削除

## 🛡️ セキュリティ

- CSRF保護・セキュアなセッション管理
- パスワードハッシュ化・入力値検証
- 権限ベースアクセス制御

## 🤝 コントリビューション

1. リポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスです。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙋‍♂️ サポート

問題が発生した場合は、[Issues](https://github.com/hatane-rgb/KokkoSofter/issues) で報告してください。

---

**KokkoSofter** - チームのコミュニケーションをより豊かに 🌟
