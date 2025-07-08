# KokkoSofter Makefile

# デフォルトのPythonバージョン
PYTHON := python
PIP := pip
VENV_DIR := ..\venv

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

.PHONY: install
install: ## 依存関係をインストール
	@echo "依存関係をインストール中..."
	$(PYTHON) -m venv $(VENV_DIR)
	$(VENV_DIR)\Scripts\pip install --upgrade pip
	$(VENV_DIR)\Scripts\pip install -r ..\requirements.txt
	@echo "インストール完了！"

.PHONY: dev-setup
dev-setup: install ## 開発環境をセットアップ
	@echo "開発環境をセットアップ中..."
	@if not exist ..\.env copy ..\.env.example ..\.env
	$(VENV_DIR)\Scripts\python manage.py makemigrations
	$(VENV_DIR)\Scripts\python manage.py migrate
	$(VENV_DIR)\Scripts\python manage.py collectstatic --noinput
	@echo "開発環境のセットアップ完了！"

.PHONY: run
run: ## 開発サーバーを起動
	@echo "開発サーバーを起動中..."
	$(VENV_DIR)\Scripts\python manage.py runserver 0.0.0.0:8000

.PHONY: migrate
migrate: ## データベースマイグレーションを実行
	@echo "マイグレーションを実行中..."
	$(VENV_DIR)\Scripts\python manage.py makemigrations
	$(VENV_DIR)\Scripts\python manage.py migrate
	@echo "マイグレーション完了！"

.PHONY: superuser
superuser: ## スーパーユーザーを作成
	@echo "スーパーユーザーを作成中..."
	$(VENV_DIR)\Scripts\python manage.py createsuperuser

.PHONY: static
static: ## 静的ファイルを収集
	@echo "静的ファイルを収集中..."
	$(VENV_DIR)\Scripts\python manage.py collectstatic --noinput
	@echo "静的ファイル収集完了！"

.PHONY: test
test: ## テストを実行
	@echo "テストを実行中..."
	$(VENV_DIR)\Scripts\python manage.py test

.PHONY: clean
clean: ## 一時ファイルを削除
	@echo "一時ファイルを削除中..."
	@for /r %%i in (__pycache__) do @if exist "%%i" rmdir /s /q "%%i"
	@for /r %%i in (*.pyc) do @if exist "%%i" del "%%i"
	@for /r %%i in (*.pyo) do @if exist "%%i" del "%%i"
	@echo "クリーンアップ完了！"

.PHONY: check
check: ## Djangoのシステムチェックを実行
	@echo "システムチェックを実行中..."
	$(VENV_DIR)\Scripts\python manage.py check

.PHONY: shell
shell: ## Django shellを起動
	@echo "Django shellを起動中..."
	$(VENV_DIR)\Scripts\python manage.py shell

.PHONY: requirements
requirements: ## requirements.txtを更新
	@echo "requirements.txtを更新中..."
	$(VENV_DIR)\Scripts\pip freeze > ..\requirements.txt
	@echo "requirements.txt更新完了！"

.PHONY: backup-db
backup-db: ## データベースをバックアップ
	@echo "データベースをバックアップ中..."
	@if not exist ..\backups mkdir ..\backups
	$(VENV_DIR)\Scripts\python manage.py dumpdata --natural-foreign --natural-primary > ..\backups\backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.json
	@echo "バックアップ完了！"

.PHONY: production-setup
production-setup: ## 本番環境をセットアップ
	@echo "本番環境をセットアップ中..."
	..\deploy.sh production

.PHONY: start-gunicorn
start-gunicorn: ## Gunicornでサーバーを起動
	@echo "Gunicornでサーバーを起動中..."
	$(VENV_DIR)\Scripts\gunicorn --config ..\gunicorn_config.py KokkoSofter.wsgi:application

.PHONY: git-init
git-init: ## Gitリポジトリを初期化
	@echo "Gitリポジトリを初期化中..."
	cd .. && git init
	cd .. && git add .
	cd .. && git commit -m "Initial commit: KokkoSofter project setup"
	@echo "Gitリポジトリ初期化完了！"
	@echo "次のステップ:"
	@echo "1. GitHubでリポジトリを作成"
	@echo "2. git remote add origin <your-repository-url>"
	@echo "3. git push -u origin main"

.PHONY: start
start: ## 簡単な開発開始コマンド
	@echo "KokkoSofterを起動中..."
	@if not exist $(VENV_DIR) $(MAKE) dev-setup
	$(MAKE) run
