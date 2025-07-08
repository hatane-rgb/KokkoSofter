# KokkoSofter Makefile

# デフォルトのPythonバージョン
PYTHON := python3
PIP := pip3
VENV_DIR := /var/www/kokkosofter/venv
PROJECT_DIR := /var/www/kokkosofter

# 色付きヘルプメッセージ（Windows対応）
.DEFAULT_GOAL := help

.PHONY: help
help: ## ヘルプメッセージを表示
	@echo "KokkoSofter 管理コマンド"
	@echo "========================"
	@echo "dev-setup        開発環境をセットアップ"
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
	@echo "service-status   systemdサービスの状態を確認"
	@echo "service-logs     systemdサービスのログを表示"
	@echo "service-restart  systemdサービスを再起動"
	@echo "debug-gunicorn   デバッグモードでGunicornを起動"
	@echo "test-django      Django設定をテスト"
	@echo "generate-secret-key Django用のSECRET_KEYを生成"
	@echo "generate-secret-key  Django用のSECRET_KEYを生成"

.PHONY: install
install: ## 依存関係をインストール
	@echo "依存関係をインストール中..."
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_DIR)/bin/pip install --upgrade pip
	$(VENV_DIR)/bin/pip install -r $(PROJECT_DIR)/requirements.txt
	@echo "インストール完了！"

.PHONY: dev-setup
dev-setup: install ## 開発環境をセットアップ
	@echo "開発環境をセットアップ中..."
	@if [ ! -f $(PROJECT_DIR)/.env ]; then \
		echo ".envファイルを作成中..."; \
		cp $(PROJECT_DIR)/.env.example $(PROJECT_DIR)/.env; \
		echo "SECRET_KEYを自動生成中..."; \
		SECRET_KEY=$$(cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"); \
		sed -i "s/SECRET_KEY=your-secret-key-here-change-this-in-production/SECRET_KEY=$$SECRET_KEY/" $(PROJECT_DIR)/.env; \
		echo "新しいSECRET_KEYが設定されました"; \
	elif grep -q "SECRET_KEY=your-secret-key-here-change-this-in-production" $(PROJECT_DIR)/.env; then \
		echo "デフォルトのSECRET_KEYを新しいキーに更新中..."; \
		SECRET_KEY=$$(cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"); \
		sed -i "s/SECRET_KEY=your-secret-key-here-change-this-in-production/SECRET_KEY=$$SECRET_KEY/" $(PROJECT_DIR)/.env; \
		echo "新しいSECRET_KEYが設定されました"; \
	fi
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
	@SECRET_KEY=$$(cd $(PROJECT_DIR) && $(VENV_DIR)/bin/python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"); \
	sed -i "s/SECRET_KEY=your-secret-key-here-change-this-in-production/SECRET_KEY=$$SECRET_KEY/" $(PROJECT_DIR)/.env
	@echo "新しいSECRET_KEYが.envファイルに設定されました！"
	@echo "設定を確認するには: head -5 $(PROJECT_DIR)/.env"

.PHONY: start
start: ## 簡単な開発開始コマンド
	@echo "KokkoSofterを起動中..."
	@if [ ! -d $(VENV_DIR) ]; then $(MAKE) dev-setup; fi
	$(MAKE) run
