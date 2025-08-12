#!/bin/bash

# データベースファイルの存在確認とパーミッション修正スクリプト

echo "=== データベースファイルの状況確認 ==="
ls -la /var/www/kokkosofter/db.sqlite3

echo -e "\n=== プロジェクトディレクトリの権限確認 ==="
ls -la /var/www/kokkosofter/

echo -e "\n=== データベースファイルの権限修正 ==="
# www-dataユーザーがデータベースにアクセスできるように修正
sudo chown www-data:www-data /var/www/kokkosofter/db.sqlite3
sudo chmod 664 /var/www/kokkosofter/db.sqlite3

# データベースが格納されているディレクトリの権限も修正
sudo chown www-data:www-data /var/www/kokkosofter/
sudo chmod 755 /var/www/kokkosofter/

echo -e "\n=== 修正後の権限確認 ==="
ls -la /var/www/kokkosofter/db.sqlite3

echo -e "\n=== データベースファイルが存在しない場合は作成 ==="
if [ ! -f /var/www/kokkosofter/db.sqlite3 ]; then
    echo "データベースファイルが存在しません。作成します..."
    cd /var/www/kokkosofter/
    source venv/bin/activate
    python manage.py migrate
    sudo chown www-data:www-data /var/www/kokkosofter/db.sqlite3
    sudo chmod 664 /var/www/kokkosofter/db.sqlite3
fi

echo -e "\n=== サービス再起動 ==="
sudo systemctl restart kokkosofter
sudo systemctl status kokkosofter

echo -e "\n=== Nginx再起動 ==="
sudo systemctl restart nginx
sudo systemctl status nginx

echo -e "\n=== 修復完了 ==="
echo "ブラウザでサイトにアクセスして確認してください"
