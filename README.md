# 🚀 KokkoSofter

**モダンでスタイリッシュなチーム向けソーシャル投稿プラットフォーム**

KokkoSofterは、チームメンバー間のコミュニケーションを活性化させる美しいWebアプリケーションです。DjangoとTailwind CSSで構築され、直感的なUIと豊富な機能を提供します。

![Django](https://img.shields.io/badge/Django-5.2.4-green)
![Python](https://img.shields.io/badge/Python-3.8+-blue)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-4.1.11-blue)
![DaisyUI](https://img.shields.io/badge/DaisyUI-5.0.46-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ 主な特徴

- 🎨 **モダンなUI**: DaisyUI + Tailwind CSS による美しいデザイン
- 📱 **レスポンシブ**: すべてのデバイスで最適な表示
- 🌙 **テーマ切替**: ダーク/ライトモード対応
- �️ **メディア対応**: 画像アップロード・表示機能
- 👥 **ユーザー管理**: プロフィール・権限管理
- 🌤️ **ウィジェット**: 天気情報・時計表示
- 🔒 **セキュリティ**: 堅牢な認証・認可システム
- 👑 **管理機能**: 包括的な管理者ダッシュボード

## 🚀 ワンコマンド本番デプロイ

**本番環境に即座にデプロイ**（Linux/Ubuntu/CentOS対応）：

```bash
curl -sSL https://raw.githubusercontent.com/hatane-rgb/KokkoSofter/main/deploy.sh | sudo bash -s production
```

⚡ **これだけで完了！**
- 自動でGitクローン
- 依存関係インストール
- データベース初期化
- Nginx + Gunicorn設定
- systemdサービス登録・起動

**アクセス**: http://your-server-ip/

---

## 💻 開発環境セットアップ

**Windows**:
```powershell
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter
.\deploy.ps1 development
```

**Linux/macOS**:
```bash
git clone https://github.com/hatane-rgb/KokkoSofter.git
cd KokkoSofter
make full-setup && make run
```

**アクセス**: http://127.0.0.1:8000/

---

## 📋 手動デプロイ（詳細制御が必要な場合）

```bash
# 1. クローン & セットアップ
git clone https://github.com/hatane-rgb/KokkoSofter.git /var/www/kokkosofter
cd /var/www/kokkosofter
chmod +x deploy.sh

# 2. 本番デプロイ実行
./deploy.sh production
```

## ⚡ Makeコマンド一覧

開発・運用で使用できるMakeコマンドの概要（詳細は [開発ガイド](docs/DEVELOPMENT.md) 参照）:

### 🚀 セットアップ
- `make full-setup` - 完全自動セットアップ（初回推奨）
- `make dev-setup` - 開発環境セットアップ
- `make install` - Python依存関係インストール

### 🔧 開発
- `make run` - 開発サーバー起動
- `make migrate` - データベースマイグレーション
- `make superuser` - 管理者ユーザー作成
- `make test` - テスト実行

### 🎨 フロントエンド
- `make build-css` - TailwindCSS監視モード
- `make build-css-prod` - TailwindCSS本番ビルド
- `make static` - 静的ファイル収集

### 🌐 本番環境
- `make nginx-setup` - Nginx設定適用
- `make service-restart` - サービス再起動
- `make fix-permissions` - 権限修正
- `make configure-domain` - ドメイン設定

すべてのコマンド一覧: `make help`

## 📚 詳細ドキュメント

| ドキュメント | 内容 | 対象者 |
|-------------|------|--------|
| [�️ セットアップガイド](docs/SETUP.md) | Windows/Linux詳細セットアップ | 初回導入時 |
| [🔧 開発ガイド](docs/DEVELOPMENT.md) | 開発環境・コーディング | 開発者 |
| [🚀 デプロイメント](docs/DEPLOYMENT.md) | 本番環境構築・運用 | インフラ担当者 |
| [📖 機能一覧](docs/FEATURES.md) | 全機能詳細説明 | 利用者・企画者 |
| [🎨 UI/UXガイド](docs/UI_GUIDE.md) | デザイン・カスタマイズ | デザイナー |
| [🆘 トラブルシューティング](docs/TROUBLESHOOTING.md) | 問題解決・FAQ | 管理者・ユーザー |

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add: amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

詳細は [開発ガイド](docs/DEVELOPMENT.md) を参照してください。

## 🆘 サポート・トラブルシューティング

### よくある問題
- **セットアップエラー**: [セットアップガイド](docs/SETUP.md)
- **権限エラー**: `make fix-permissions`
- **CSRF エラー**: `make fix-csrf`  
- **CSS ビルドエラー**: `make build-css-prod`
- **詳細な問題解決**: [トラブルシューティング](docs/TROUBLESHOOTING.md)

### 問題報告
問題が発生した場合は、以下の情報とともに [Issues](https://github.com/hatane-rgb/KokkoSofter/issues) で報告してください：

1. **エラーメッセージ** の全文
2. **実行環境**（OS、Python/Node.jsバージョン）
3. **実行したコマンド** と手順
4. **期待される動作** と実際の動作

## 📄 ライセンス

このプロジェクトは MIT ライセンスです。詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

<div align="center">

**🌟 KokkoSofter - チームのコミュニケーションをより豊かに**

[![GitHub Stars](https://img.shields.io/github/stars/hatane-rgb/KokkoSofter?style=social)](https://github.com/hatane-rgb/KokkoSofter)
[![GitHub Forks](https://img.shields.io/github/forks/hatane-rgb/KokkoSofter?style=social)](https://github.com/hatane-rgb/KokkoSofter)

[🚀 クイックスタート](#クイックスタート) • [📖 ドキュメント](#詳細ドキュメント) • [� サポート](#サポート・トラブルシューティング)

</div>
