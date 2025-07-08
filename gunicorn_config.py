# Gunicorn 設定ファイル
# gunicorn_config.py

import multiprocessing

# サーバーソケット
bind = "0.0.0.0:8000"
backlog = 2048

# ワーカープロセス
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# リソース制限
max_requests = 1000
max_requests_jitter = 50
preload_app = True

# ログ設定
accesslog = "/var/log/kokkosofter/gunicorn_access.log"
errorlog = "/var/log/kokkosofter/gunicorn_error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# プロセス管理
pidfile = "/var/run/kokkosofter/gunicorn.pid"
user = "www-data"
group = "www-data"
daemon = False

# セキュリティ
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# 作業ディレクトリの設定
chdir = "/var/www/kokkosofter"
