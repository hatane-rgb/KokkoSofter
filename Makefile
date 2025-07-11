# KokkoSofter Makefile

# デフォルトのPythonバージョン
PYTHON := python3
PIP := pip3
VENV_DIR := /var/www/kokkosofter/venv
PROJECT_DIR := /var/www/kokkosofter

# OS検出（Windows対応）
ifeq ($(OS),Windows_NT)
    PYTHON := python
    PIP := pip
    VENV_DIR := venv
    PROJECT_DIR := .
    POWERSHELL := powershell
endif

# 色付きヘルプメッセージ（Windows対応）
.DEFAULT_GOAL := help

.PHONY: help
help: ## ヘルプメッセージを表示
	@echo "KokkoSofter 管理コマンド"
	@echo "========================"
	@echo "🚀 セットアップ・開発"
	@echo "dev-setup        開発環境をセットアップ（Python+Node.js+CSS）"
	@echo "install          依存関係をインストール"
	@echo "npm-install      Node.js依存関係をインストール"
	@echo "build-css        TailwindCSSをビルド（開発用・監視）"
	@echo "build-css-prod   TailwindCSSをビルド（本番用・最適化）"
	@echo "full-setup       完全セットアップ（依存関係+CSS+DB）"
	@echo ""
	@echo "🔧 開発・テスト"
	@echo "run              開発サーバーを起動"
	@echo "migrate          データベースマイグレーションを実行"
	@echo "superuser        スーパーユーザーを作成"
	@echo "static           静的ファイルを収集"
	@echo "test             テストを実行"
	@echo "check            Djangoのシステムチェックを実行"
	@echo "shell            Django shellを起動"
	@echo "clean            一時ファイルを削除"
	@echo "requirements     requirements.txtを更新"
	@echo "backup-db        データベースをバックアップ"
	@echo "git-init         Gitリポジトリを初期化"
	@echo ""
	@echo "🌐 本番環境・サービス管理"
	@echo "service-status   systemdサービスの状態を確認"
	@echo "service-logs     systemdサービスのログを表示"
	@echo "service-restart  systemdサービスを再起動"
	@echo "debug-gunicorn   デバッグモードでGunicornを起動"
	@echo "test-django      Django設定をテスト"
	@echo "generate-secret-key Django用のSECRET_KEYを生成"
	@echo "create-dirs      必要なディレクトリを作成"
	@echo "fix-permissions  ファイル権限を修正"
	@echo "configure-domain ドメイン名を設定してNginx/envに適用"
	@echo "quick-domain-setup ドメイン設定→Nginx適用→再起動を一括実行"
	@echo "nginx-setup      Nginx設定をセットアップ"
	@echo "nginx-test       Nginx設定をテスト"
	@echo "nginx-status     Nginxの状態を確認"
	@echo "nginx-disable-default Nginxデフォルトサイトを無効化"
	@echo "fix-csrf         CSRF検証エラーを修正"
	@echo "check-csrf       CSRF関連設定を確認"
	@echo "debug-enable     デバッグモード有効化（一時的）"
	@echo "debug-disable    デバッグモード無効化"
	@echo "fix-git-owner    Git所有者問題を修正"
	@echo "git-pull         最新のコードを取得"
	@echo "fix-media        メディアファイルの権限を修正"
	@echo "check-media      メディアファイル設定を確認"

.PHONY: install
install: ## 依存関係をインストール
	@echo "依存関係をインストール中..."
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -r $(PROJECT_DIR)/requirements.txt
	@echo "インストール完了！"

.PHONY: npm-install
npm-install: ## Node.js依存関係をインストール
	@echo "Node.js依存関係をインストール中..."
	@if command -v npm >/dev/null 2>&1; then \
		cd $(PROJECT_DIR) && npm install; \
		echo "Node.js依存関係のインストール完了！"; \
	else \
		echo "❌ npmが見つかりません。Node.js 18+をインストールしてください"; \
		exit 1; \
	fi

.PHONY: build-css
build-css: npm-install ## TailwindCSSをビルド（開発用・監視）
	@echo "TailwindCSSをビルド中（開発用・監視モード）..."
	cd $(PROJECT_DIR) && npm run dev

.PHONY: build-css-prod
build-css-prod: npm-install ## TailwindCSSをビルド（本番用・最適化）
	@echo "TailwindCSSをビルド中（本番用・最適化）..."
	cd $(PROJECT_DIR) && npm run build

.PHONY: full-setup
full-setup: install npm-install build-css-prod ## 完全セットアップ（依存関係+CSS+DB）
	@echo "完全セットアップを実行中..."
	$(MAKE) dev-setup
	@echo "完全セットアップ完了！"

.PHONY: dev-setup
dev-setup: install npm-install ## 開発環境をセットアップ
	@echo "開発環境をセットアップ中..."
	@if [ ! -f $(PROJECT_DIR)/.env ]; then \
		echo ".envファイルを作成中..."; \
		cp $(PROJECT_DIR)/.env.example $(PROJECT_DIR)/.env; \
		echo "SECRET_KEYを自動生成中..."; \
		cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "\
import re; \
from django.core.management.utils import get_random_secret_key; \
with open('.env', 'r') as f: content = f.read(); \
new_key = get_random_secret_key(); \
content = re.sub(r'^SECRET_KEY=.*$$', f'SECRET_KEY={new_key}', content, flags=re.MULTILINE); \
with open('.env', 'w') as f: f.write(content); \
print('新しいSECRET_KEYが設定されました')"; \
	elif grep -q "SECRET_KEY=your-secret-key-here-change-this-in-production" $(PROJECT_DIR)/.env; then \
		echo "デフォルトのSECRET_KEYを新しいキーに更新中..."; \
		cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "\
import re; \
from django.core.management.utils import get_random_secret_key; \
with open('.env', 'r') as f: content = f.read(); \
new_key = get_random_secret_key(); \
content = re.sub(r'^SECRET_KEY=.*$$', f'SECRET_KEY={new_key}', content, flags=re.MULTILINE); \
with open('.env', 'w') as f: f.write(content); \
print('新しいSECRET_KEYが設定されました')"; \
	fi
	@echo "TailwindCSSをビルド中..."
	cd $(PROJECT_DIR) && npm run build 2>/dev/null || echo "⚠️ TailwindCSSビルドに失敗（手動でnpm run buildを実行してください）"
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py makemigrations
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py migrate
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py collectstatic --noinput
	@echo "開発環境のセットアップ完了！"

.PHONY: run
run: ## 開発サーバーを起動
	@echo "開発サーバーを起動中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py runserver 0.0.0.0:8000

.PHONY: migrate
migrate: ## データベースマイグレーションを実行
	@echo "マイグレーションを実行中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py makemigrations
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py migrate
	@echo "マイグレーション完了！"

.PHONY: superuser
superuser: ## スーパーユーザーを作成
	@echo "スーパーユーザーを作成中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py createsuperuser

.PHONY: static
static: ## 静的ファイルを収集
	@echo "静的ファイルを収集中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py collectstatic --noinput
	@echo "静的ファイル収集完了！"

.PHONY: test
test: ## テストを実行
	@echo "テストを実行中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py test

.PHONY: clean
clean: ## 一時ファイルを削除
	@echo "一時ファイルを削除中..."
	cd $(PROJECT_DIR) && find . -type d -name "__pycache__" -exec rm -rf {} +
	cd $(PROJECT_DIR) && find . -name "*.pyc" -delete
	cd $(PROJECT_DIR) && find . -name "*.pyo" -delete
	@echo "クリーンアップ完了！"

.PHONY: check
check: ## Djangoのシステムチェックを実行
	@echo "システムチェックを実行中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py check

.PHONY: shell
shell: ## Django shellを起動
	@echo "Django shellを起動中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py shell

.PHONY: requirements
requirements: ## requirements.txtを更新
	@echo "requirements.txtを更新中..."
	$(VENV_DIR)/bin/pip freeze > $(PROJECT_DIR)/requirements.txt
	@echo "requirements.txt更新完了！"

.PHONY: backup-db
backup-db: ## データベースをバックアップ
	@echo "データベースをバックアップ中..."
	@mkdir -p $(PROJECT_DIR)/backups
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py dumpdata --natural-foreign --natural-primary > backups/backup_$(shell date +%Y%m%d_%H%M%S).json
	@echo "バックアップ完了！"

.PHONY: production-setup
production-setup: ## 本番環境をセットアップ
	@echo "本番環境をセットアップ中..."
	$(PROJECT_DIR)/deploy.sh production

.PHONY: start-gunicorn
start-gunicorn: ## Gunicornでサーバーを起動
	@echo "Gunicornでサーバーを起動中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/gunicorn --config gunicorn_config.py KokkoSofter.wsgi:application

.PHONY: git-init
git-init: ## Gitリポジトリを初期化
	@echo "Gitリポジトリを初期化中..."
	cd $(PROJECT_DIR) && git init
	cd $(PROJECT_DIR) && git add .
	cd $(PROJECT_DIR) && git commit -m "Initial commit: KokkoSofter project setup"
	@echo "Gitリポジトリ初期化完了！"
	@echo "次のステップ:"
	@echo "1. GitHubでリポジトリを作成"
	@echo "2. git remote add origin <your-repository-url>"
	@echo "3. git push -u origin main"

.PHONY: service-status
service-status: ## systemdサービスの状態を確認
	@echo "KokkoSofterサービスの状態を確認中..."
	@sudo systemctl status kokkosofter.service

.PHONY: service-logs
service-logs: ## systemdサービスのログを表示
	@echo "KokkoSofterサービスのログを表示中..."
	@sudo journalctl -xeu kokkosofter.service --no-pager

.PHONY: service-restart
service-restart: ## systemdサービスを再起動
	@echo "KokkoSofterサービスを再起動中..."
	@sudo systemctl daemon-reload
	@sudo systemctl restart kokkosofter.service
	@sudo systemctl status kokkosofter.service

.PHONY: debug-gunicorn
debug-gunicorn: ## デバッグモードでGunicornを起動
	@echo "デバッグモードでGunicornを起動中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/gunicorn \
		--bind 0.0.0.0:8000 \
		--workers 1 \
		--timeout 30 \
		--log-level debug \
		--access-logfile - \
		--error-logfile - \
		KokkoSofter.wsgi:application

.PHONY: test-django
test-django: ## Django設定をテスト
	@echo "Django設定をテスト中..."
	cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python manage.py check --deploy

.PHONY: generate-secret-key
generate-secret-key: ## Django用のSECRET_KEYを生成して.envに設定
	@echo "SECRET_KEYを生成して.envファイルに設定中..."
	@if [ ! -f $(PROJECT_DIR)/.env ]; then \
		echo ".envファイルが存在しないため、.env.exampleからコピーします..."; \
		cp $(PROJECT_DIR)/.env.example $(PROJECT_DIR)/.env; \
	fi
	@cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "\
import re; \
from django.core.management.utils import get_random_secret_key; \
with open('.env', 'r') as f: content = f.read(); \
new_key = get_random_secret_key(); \
content = re.sub(r'^SECRET_KEY=.*$$', f'SECRET_KEY={new_key}', content, flags=re.MULTILINE); \
with open('.env', 'w') as f: f.write(content); \
print(f'SECRET_KEY updated: {new_key[:10]}...')"
	@echo "新しいSECRET_KEYが.envファイルに設定されました！"

.PHONY: nginx-setup
nginx-setup: ## Nginx設定をセットアップ
	@echo "Nginx設定をセットアップ中..."
	@echo "デフォルトNginxサイトを無効化中..."
	@sudo rm -f /etc/nginx/sites-enabled/default
	@sudo rm -f /etc/nginx/sites-enabled/000-default
	@echo "KokkoSofter設定をコピー中..."
	@sudo cp $(PROJECT_DIR)/nginx_kokkosofter.conf /etc/nginx/sites-available/kokkosofter
	@sudo ln -sf /etc/nginx/sites-available/kokkosofter /etc/nginx/sites-enabled/
	@echo "Nginx設定をテスト中..."
	@sudo nginx -t
	@echo "Nginx設定をリロード中..."
	@sudo systemctl reload nginx
	@echo "✅ Nginx設定が完了しました"
	@echo "📋 有効なサイト:"
	@sudo ls -la /etc/nginx/sites-enabled/

.PHONY: nginx-test
nginx-test: ## Nginx設定をテスト
	@echo "Nginx設定をテスト中..."
	@sudo nginx -t

.PHONY: nginx-status
nginx-status: ## Nginxの状態を確認
	@echo "Nginxの状態を確認中..."
	@sudo systemctl status nginx

.PHONY: create-dirs
create-dirs: ## 必要なディレクトリを作成
	@echo "必要なディレクトリを作成中..."
	@sudo mkdir -p /var/log/kokkosofter
	@sudo mkdir -p /var/run/kokkosofter
	@sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
	@sudo chmod 755 /var/log/kokkosofter /var/run/kokkosofter
	@sudo chown -R www-data:www-data $(PROJECT_DIR)
	@sudo chmod -R 755 $(PROJECT_DIR)
	@echo "ディレクトリ作成完了！"

.PHONY: fix-permissions
fix-permissions: ## ファイル権限を修正
	@echo "ファイル権限を修正中..."
	@sudo chown -R www-data:www-data $(PROJECT_DIR)
	@sudo chown -R www-data:www-data /var/log/kokkosofter /var/run/kokkosofter
	@sudo chmod -R 755 $(PROJECT_DIR)
	@sudo chmod 755 /var/log/kokkosofter /var/run/kokkosofter
	@echo "静的ファイルとメディアファイルの権限を設定中..."
	@sudo mkdir -p $(PROJECT_DIR)/static $(PROJECT_DIR)/media $(PROJECT_DIR)/staticfiles
	@sudo chown -R www-data:www-data $(PROJECT_DIR)/static $(PROJECT_DIR)/media $(PROJECT_DIR)/staticfiles
	@sudo chmod -R 755 $(PROJECT_DIR)/static $(PROJECT_DIR)/media $(PROJECT_DIR)/staticfiles
	@sudo find $(PROJECT_DIR)/media -type f -exec chmod 644 {} \; 2>/dev/null || true
	@sudo find $(PROJECT_DIR)/media -type d -exec chmod 755 {} \; 2>/dev/null || true
	@if [ -f "$(PROJECT_DIR)/db.sqlite3" ]; then \
		sudo chown www-data:www-data $(PROJECT_DIR)/db.sqlite3; \
		sudo chmod 664 $(PROJECT_DIR)/db.sqlite3; \
	fi
	@echo "✅ 権限修正完了！"

.PHONY: start
start: ## 簡単な開発開始コマンド
	@echo "KokkoSofterを起動中..."
	@if [ ! -d $(VENV_DIR) ]; then $(MAKE) dev-setup; fi
	$(MAKE) run

.PHONY: configure-domain
configure-domain: ## ドメイン名を対話式で設定してNginx/envに適用
	@echo "======================================"
	@echo "🌐 ドメイン/IPアドレス設定"
	@echo "======================================"
	@echo ""
	@echo "アクセス可能にしたいドメイン名やIPアドレスを入力してください。"
	@echo "複数ある場合はカンマ区切りで入力してください。"
	@echo ""
	@echo "例："
	@echo "  - IPアドレスのみ: 192.168.x.x"
	@echo "  - ドメインのみ: example.com"
	@echo "  - 複数: 192.168.x.x,example.com,www.example.com"
	@echo ""
	@read -p "ドメイン/IPアドレスを入力: " DOMAIN_INPUT; \
	if [ -z "$$DOMAIN_INPUT" ]; then \
		echo "❌ ドメイン/IPアドレスが入力されていません"; \
		exit 1; \
	fi; \
	echo ""; \
	echo "✅ 入力されたドメイン/IPアドレス: $$DOMAIN_INPUT"; \
	echo ""; \
	echo "🔧 設定を適用中..."; \
	$(MAKE) _apply-domain DOMAIN="$$DOMAIN_INPUT"

.PHONY: _apply-domain
_apply-domain: ## 内部用：ドメインを実際に適用
	@echo "📝 .envファイルのALLOWED_HOSTSを更新中..."
	@if [ ! -f $(PROJECT_DIR)/.env ]; then \
		echo ".envファイルが存在しないため、.env.exampleからコピーします..."; \
		cp $(PROJECT_DIR)/.env.example $(PROJECT_DIR)/.env; \
	fi
	@sed -i.bak "s/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=localhost,127.0.0.1,$(DOMAIN)/" $(PROJECT_DIR)/.env
	@echo "✅ .envファイルのALLOWED_HOSTSを更新しました"
	@echo ""
	@echo "🔧 CSRF_TRUSTED_ORIGINSを設定中..."
	@CSRF_ORIGINS=""; \
	OLD_IFS=$$IFS; IFS=','; \
	for domain in $(DOMAIN); do \
		domain=$$(echo "$$domain" | sed 's/^[ \t]*//;s/[ \t]*$$//'); \
		case "$$domain" in \
			*[0-9].[0-9].[0-9].[0-9]*) \
				CSRF_ORIGINS="$${CSRF_ORIGINS}http://$$domain,"; \
				;; \
			*) \
				CSRF_ORIGINS="$${CSRF_ORIGINS}https://$$domain,http://$$domain,"; \
				;; \
		esac; \
	done; \
	IFS=$$OLD_IFS; \
	CSRF_ORIGINS=$$(echo "$$CSRF_ORIGINS" | sed 's/,$$//'); \
	if grep -q "^CSRF_TRUSTED_ORIGINS=" $(PROJECT_DIR)/.env; then \
		sed -i.bak "s|^CSRF_TRUSTED_ORIGINS=.*|CSRF_TRUSTED_ORIGINS=$$CSRF_ORIGINS|" $(PROJECT_DIR)/.env; \
	else \
		echo "CSRF_TRUSTED_ORIGINS=$$CSRF_ORIGINS" >> $(PROJECT_DIR)/.env; \
	fi
	@echo "✅ CSRF_TRUSTED_ORIGINSを設定しました"
	@echo ""
	@echo "🔧 Nginx設定ファイルのserver_nameを更新中..."
	@FIRST_DOMAIN=$$(echo "$(DOMAIN)" | cut -d',' -f1); \
	ALL_DOMAINS=$$(echo "$(DOMAIN)" | sed 's/,/ /g'); \
	sed -i.bak "0,/server_name .*/s//server_name $$ALL_DOMAINS;/" $(PROJECT_DIR)/nginx_kokkosofter.conf; \
	sed -i "s/#     server_name .*/#     server_name $$ALL_DOMAINS;/" $(PROJECT_DIR)/nginx_kokkosofter.conf
	@echo "✅ Nginx設定ファイル（HTTP/HTTPS）を更新しました"
	@echo ""
	@echo "📋 設定内容を確認:"
	@echo "================================"
	@echo "ALLOWED_HOSTS: localhost,127.0.0.1,$(DOMAIN)"
	@echo "Nginx server_name: $(DOMAIN)"
	@grep "CSRF_TRUSTED_ORIGINS=" $(PROJECT_DIR)/.env | head -1 || echo "CSRF_TRUSTED_ORIGINS: 設定なし"
	@echo "================================"
	@echo ""
	@echo "🚀 次のステップ:"
	@echo "1. make nginx-setup    (Nginx設定を適用)"
	@echo "2. make service-restart (サービス再起動)"
	@echo ""

.PHONY: quick-domain-setup
quick-domain-setup: ## ドメイン設定→Nginx適用→サービス再起動を一括実行
	@echo "======================================"
	@echo "🚀 クイックドメインセットアップ"
	@echo "======================================"
	$(MAKE) configure-domain
	@echo ""
	@echo "🔧 Nginx設定を適用中..."
	$(MAKE) nginx-setup
	@echo ""
	@echo "🔄 サービスを再起動中..."
	$(MAKE) service-restart
	@echo ""
	@echo "✅ ドメイン設定完了！"
	@echo ""
	@echo "🌐 以下のURLでアクセス可能です:"
	@grep "ALLOWED_HOSTS=" $(PROJECT_DIR)/.env | sed 's/ALLOWED_HOSTS=//' | tr ',' '\n' | grep -v localhost | grep -v 127.0.0.1 | sed 's/^/  http:\/\//' | sed 's/$/:8000/'

.PHONY: nginx-disable-default
nginx-disable-default: ## Nginxのデフォルトサイトを無効化
	@echo "Nginxデフォルトサイトを無効化中..."
	@sudo rm -f /etc/nginx/sites-enabled/default
	@sudo rm -f /etc/nginx/sites-enabled/000-default
	@echo "✅ デフォルトサイトを無効化しました"
	@echo "📋 有効なサイト:"
	@sudo ls -la /etc/nginx/sites-enabled/ || echo "  (サイトが見つかりません)"

.PHONY: fix-csrf
fix-csrf: ## CSRF検証エラーを修正
	@echo "CSRF検証エラーを修正中..."
	@echo "📝 ALLOWED_HOSTSを更新中..."
	@read -p "ドメイン名を入力 (例: example.com): " DOMAIN; \
	if [ ! -z "$$DOMAIN" ]; then \
		sed -i.bak "s/^ALLOWED_HOSTS=.*/ALLOWED_HOSTS=localhost,127.0.0.1,$$DOMAIN/" $(PROJECT_DIR)/.env; \
		echo "✅ ALLOWED_HOSTSを更新しました"; \
		echo "🔧 CSRF_TRUSTED_ORIGINSを設定中..."; \
		if ! grep -q "CSRF_TRUSTED_ORIGINS" $(PROJECT_DIR)/.env; then \
			echo "CSRF_TRUSTED_ORIGINS=https://$$DOMAIN,http://$$DOMAIN" >> $(PROJECT_DIR)/.env; \
		else \
			sed -i.bak "s|^CSRF_TRUSTED_ORIGINS=.*|CSRF_TRUSTED_ORIGINS=https://$$DOMAIN,http://$$DOMAIN|" $(PROJECT_DIR)/.env; \
		fi; \
		echo "✅ CSRF_TRUSTED_ORIGINSを設定しました"; \
	fi
	@echo "🔧 CSRF設定を調整中..."
	@if ! grep -q "CSRF_COOKIE_SECURE" $(PROJECT_DIR)/.env; then \
		echo "CSRF_COOKIE_SECURE=False" >> $(PROJECT_DIR)/.env; \
		echo "SESSION_COOKIE_SECURE=False" >> $(PROJECT_DIR)/.env; \
		echo "✅ CSRF設定を追加しました"; \
	fi
	@echo "🔄 サービスを再起動中..."
	$(MAKE) service-restart
	@echo "✅ CSRF検証エラーの修正完了！"

.PHONY: debug-enable
debug-enable: ## デバッグモードを一時的に有効化（問題解決後は必ず無効化すること）
	@echo "⚠️  WARNING: デバッグモードを有効化します（セキュリティリスク）"
	@echo "問題解決後は必ず 'make debug-disable' を実行してください"
	@sed -i.bak 's/DEBUG=False/DEBUG=True/' $(PROJECT_DIR)/.env
	$(MAKE) service-restart
	@echo "🐛 デバッグモードが有効化されました"

.PHONY: debug-disable
debug-disable: ## デバッグモードを無効化
	@echo "🔒 デバッグモードを無効化中..."
	@sed -i 's/DEBUG=True/DEBUG=False/' $(PROJECT_DIR)/.env
	$(MAKE) service-restart
	@echo "✅ デバッグモードが無効化されました"

.PHONY: check-csrf
check-csrf: ## CSRF関連設定を確認
	@echo "🔍 CSRF関連設定を確認中..."
	@echo "================================"
	@echo "ALLOWED_HOSTS:"
	@grep "ALLOWED_HOSTS" $(PROJECT_DIR)/.env || echo "  設定なし"
	@echo ""
	@echo "CSRF_TRUSTED_ORIGINS:"
	@grep "CSRF_TRUSTED_ORIGINS" $(PROJECT_DIR)/.env || echo "  設定なし"
	@echo ""
	@echo "DEBUG:"
	@grep "DEBUG" $(PROJECT_DIR)/.env || echo "  設定なし"
	@echo ""
	@echo "CSRF設定:"
	@grep -E "CSRF_COOKIE_SECURE|SESSION_COOKIE_SECURE" $(PROJECT_DIR)/.env || echo "  設定なし"
	@echo "================================"

.PHONY: fix-git-owner
fix-git-owner: ## Git所有者問題を修正
	@echo "🔧 Git所有者問題を修正中..."
	@if [ -d $(PROJECT_DIR)/.git ]; then \
		git config --global --add safe.directory $(PROJECT_DIR); \
		echo "✅ Git safe.directory設定を追加しました"; \
	else \
		echo "❌ Gitリポジトリが見つかりません"; \
	fi

.PHONY: git-pull
git-pull: fix-git-owner ## 最新のコードを取得
	@echo "📥 最新のコードを取得中..."
	@cd $(PROJECT_DIR) && git pull origin main
	@echo "✅ 最新のコードを取得しました"

.PHONY: fix-media
fix-media: ## メディアファイルの権限を修正
	@echo "🖼️ メディアファイルの権限を修正中..."
	@sudo mkdir -p $(PROJECT_DIR)/media/avatars $(PROJECT_DIR)/media/post_images $(PROJECT_DIR)/staticfiles
	@sudo chown -R www-data:www-data $(PROJECT_DIR)/media $(PROJECT_DIR)/staticfiles
	@sudo chmod -R 755 $(PROJECT_DIR)/media $(PROJECT_DIR)/staticfiles
	@sudo find $(PROJECT_DIR)/media -type f -exec chmod 644 {} \; 2>/dev/null || true
	@sudo find $(PROJECT_DIR)/media -type d -exec chmod 755 {} \; 2>/dev/null || true
	
	@echo "📋 シンボリックリンク確認と作成..."
	@if [ ! -L "/var/www/html/media" ]; then \
		sudo ln -sf $(PROJECT_DIR)/media /var/www/html/media; \
		echo "✅ メディアディレクトリのシンボリックリンクを作成しました"; \
	else \
		echo "✓ メディアディレクトリのシンボリックリンクは既に存在します"; \
	fi
	
	@echo "🧪 SELinuxコンテキスト設定..."
	@if command -v restorecon > /dev/null; then \
		sudo restorecon -R $(PROJECT_DIR)/media 2>/dev/null || echo "SELinuxコンテキスト設定をスキップ"; \
	fi
	
	@echo "✅ メディアファイルの権限を修正しました"
	@echo ""
	@echo "📂 メディアディレクトリ一覧:"
	@ls -la $(PROJECT_DIR)/media/ 2>/dev/null || echo "  メディアディレクトリが空です"
	@echo ""
	@echo "📝 メディア設定確認:"
	@grep "MEDIA" $(PROJECT_DIR)/KokkoSofter/settings.py

.PHONY: check-media
check-media: ## メディアファイルの設定を確認
	@echo "🔍 メディアファイル設定を確認中..."
	@echo "=========================="
	@echo "📂 メディアディレクトリのパーミッション:"
	@ls -la $(PROJECT_DIR)/media/ 2>/dev/null || echo "  メディアディレクトリが存在しません"
	@echo ""
	@echo "📄 Nginx設定内のメディアパス:"
	@grep -A 3 "location /media/" /etc/nginx/sites-available/kokkosofter || echo "  設定が見つかりません"
	@echo ""
	@echo "🔗 シンボリックリンク状態:"
	@ls -la /var/www/html/media 2>/dev/null || echo "  シンボリックリンクが存在しません"
	@echo ""
	@echo "⚙️ settings.pyのメディア設定:"
	@grep "MEDIA" $(PROJECT_DIR)/KokkoSofter/settings.py
	@echo ""
	@echo "📊 メディアファイル数:"
	@find $(PROJECT_DIR)/media -type f | wc -l

.PHONY: windows-setup
windows-setup: ## Windows環境向け自動セットアップ（PowerShell）
ifeq ($(OS),Windows_NT)
	@echo "Windows環境でPowerShellセットアップを実行中..."
	@if exist deploy.ps1 ( \
		powershell -ExecutionPolicy Bypass -File deploy.ps1 development \
	) else ( \
		echo "❌ deploy.ps1が見つかりません" \
	)
else
	@echo "❌ この機能はWindows専用です。Linux/macOSでは 'make full-setup' を使用してください"
endif

.PHONY: powershell-deploy
powershell-deploy: ## PowerShellデプロイスクリプトを実行（引数: env=development|production）
ifeq ($(OS),Windows_NT)
	@echo "PowerShellデプロイスクリプトを実行中..."
	@set env=$(if $(env),$(env),development) && \
	if exist deploy.ps1 ( \
		powershell -ExecutionPolicy Bypass -File deploy.ps1 $(env) \
	) else ( \
		echo "❌ deploy.ps1が見つかりません" \
	)
else
	@echo "❌ この機能はWindows専用です"
endif