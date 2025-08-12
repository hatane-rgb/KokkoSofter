# 🔧 開発ガイド

KokkoSofterの開発に参加する際のガイドと利用可能なMakeコマンドの詳細説明です。

## 📋 目次

- [プロジェクト構造](#プロジェクト構造)
- [Makeコマンド完全ガイド](#makeコマンド完全ガイド)
- [開発環境セットアップ](#開発環境セットアップ)
- [開発ワークフロー](#開発ワークフロー)
- [コーディング規約](#コーディング規約)
- [テスト・デバッグ](#テスト・デバッグ)

## 🏗️ プロジェクト構造

```
KokkoSofter/
├── KokkoSofter/              # メインプロジェクト
│   ├── settings.py           # Django設定
│   ├── urls.py              # URLルーティング
│   └── wsgi.py              # WSGIエントリーポイント
├── accounts/                # ユーザー認証・管理
│   ├── models.py            # ユーザーモデル
│   ├── views.py             # ビューロジック
│   ├── forms.py             # フォーム定義
│   └── urls.py              # URL設定
├── posts/                   # 投稿機能
│   ├── models.py            # 投稿モデル
│   ├── views.py             # ビューロジック
│   └── forms.py             # フォーム定義
├── core/                    # 共通機能
│   ├── views.py             # 共通ビュー
│   ├── middleware.py        # カスタムミドルウェア
│   └── weather.py           # 天気API
├── static/                  # 静的ファイル
│   ├── css/                 # スタイルシート
│   ├── js/                  # JavaScript
│   └── images/              # 画像ファイル
├── templates/               # テンプレート
│   ├── base.html            # ベーステンプレート
│   ├── accounts/            # アカウント関連
│   └── posts/               # 投稿関連
├── media/                   # ユーザーアップロード
│   ├── avatars/             # アバター画像
│   └── post_images/         # 投稿画像
└── docs/                    # ドキュメント
```

## ⚡ Makeコマンド完全ガイド

### � ヘルプ・概要

#### `make help`
```bash
make help
```
**説明**: 利用可能なすべてのコマンドの一覧とカテゴリ別説明を表示

**出力例**:
```
KokkoSofter 管理コマンド
========================
🚀 セットアップ・開発
🔧 開発・テスト  
🌐 本番環境・サービス管理
```

---

### 🚀 セットアップ・開発コマンド

#### `make full-setup`
```bash
make full-setup
```
**説明**: 完全自動セットアップ（初回導入時推奨）  
**処理内容**:
1. Python仮想環境作成
2. pip依存関係インストール
3. Node.js依存関係インストール  
4. TailwindCSS本番ビルド
5. データベースマイグレーション
6. 静的ファイル収集

**使用タイミング**: プロジェクト初回セットアップ時

#### `make dev-setup`
```bash
make dev-setup
```
**説明**: 開発環境セットアップ  
**処理内容**:
1. Python仮想環境作成・依存関係インストール
2. Node.js依存関係インストール
3. .envファイル作成・SECRET_KEY自動生成
4. TailwindCSSビルド
5. データベースマイグレーション
6. 静的ファイル収集

**使用タイミング**: 開発環境の初期構築時

#### `make install`
```bash
make install
```
**説明**: Python依存関係のみをインストール  
**処理内容**:
1. Python仮想環境作成（venv/）
2. pip のアップグレード
3. requirements.txt からパッケージインストール

**使用タイミング**: Python依存関係のみ更新したい場合

#### `make npm-install`
```bash
make npm-install
```
**説明**: Node.js依存関係のインストール  
**処理内容**:
1. npm の確認
2. package.json からパッケージインストール（TailwindCSS、DaisyUI等）

**使用タイミング**: フロントエンド依存関係を更新する場合

---

### 🎨 フロントエンド・CSS関連

#### `make build-css`
```bash
make build-css
```
**説明**: TailwindCSS開発用ビルド（監視モード）  
**処理内容**:
1. npm-install の実行
2. `npm run dev` 実行（ファイル変更監視）

**使用タイミング**: 開発中にCSSを自動コンパイルしたい場合  
**注意**: このコマンドは継続実行されます（Ctrl+Cで停止）

#### `make build-css-prod`
```bash
make build-css-prod
```
**説明**: TailwindCSS本番用ビルド（最適化）  
**処理内容**:
1. npm-install の実行
2. `npm run build` 実行（本番用最適化）

**使用タイミング**: 本番デプロイ前、または最適化されたCSSが必要な場合

---

### 🔧 開発・テストコマンド

#### `make run`
```bash
make run
```
**説明**: Django開発サーバーを起動  
**処理内容**:
1. 仮想環境で `python manage.py runserver 0.0.0.0:8000` 実行

**使用タイミング**: 開発中のアプリケーション起動  
**アクセス**: http://127.0.0.1:8000/

#### `make migrate`
```bash
make migrate
```
**説明**: データベースマイグレーションを実行  
**処理内容**:
1. `python manage.py makemigrations`
2. `python manage.py migrate`

**使用タイミング**: モデル変更後、新しいモデル作成後

#### `make superuser`
```bash
make superuser
```
**説明**: Django管理者ユーザーを作成  
**処理内容**:
1. `python manage.py createsuperuser` 実行（対話式）

**使用タイミング**: 初回セットアップ後、管理者ユーザーが必要な場合

#### `make static`
```bash
make static
```
**説明**: 静的ファイルを収集  
**処理内容**:
1. `python manage.py collectstatic --noinput`

**使用タイミング**: 本番デプロイ前、静的ファイル更新後

#### `make test`
```bash
make test
```
**説明**: Djangoテストスイートを実行  
**処理内容**:
1. `python manage.py test`

**使用タイミング**: コード変更後の動作確認

#### `make check`
```bash
make check
```
**説明**: Djangoシステムチェックを実行  
**処理内容**:
1. `python manage.py check`

**使用タイミング**: 設定やコードの問題を確認したい場合

#### `make shell`
```bash
make shell
```
**説明**: Django対話式シェルを起動  
**処理内容**:
1. `python manage.py shell`

**使用タイミング**: データベース操作、デバッグ作業時

---

### 🧹 メンテナンス・ユーティリティ

#### `make clean`
```bash
make clean
```
**説明**: 一時ファイル・キャッシュを削除  
**処理内容**:
1. `__pycache__` ディレクトリ削除
2. `.pyc`, `.pyo` ファイル削除

**使用タイミング**: クリーンな状態にリセットしたい場合

#### `make requirements`
```bash
make requirements
```
**説明**: requirements.txtを現在の環境に更新  
**処理内容**:
1. `pip freeze > requirements.txt`

**使用タイミング**: 新しいパッケージを追加した後

#### `make backup-db`
```bash
make backup-db
```
**説明**: データベースをバックアップ  
**処理内容**:
1. `backups/` ディレクトリ作成
2. `python manage.py dumpdata` でJSONバックアップ作成

**使用タイミング**: 重要な変更前、定期バックアップ

#### `make git-init`
```bash
make git-init
```
**説明**: Gitリポジトリを初期化  
**処理内容**:
1. `git init`
2. 全ファイルをステージング
3. 初回コミット作成

**使用タイミング**: 新しいプロジェクトでGit管理を開始する場合

---

### 🌐 本番環境・サービス管理

#### `make service-status`
```bash
make service-status
```
**説明**: systemdサービスの状態を確認  
**処理内容**:
1. `sudo systemctl status kokkosofter.service`

**使用タイミング**: 本番環境でサービスの動作状況を確認

#### `make service-logs`
```bash
make service-logs
```
**説明**: systemdサービスのログを表示  
**処理内容**:
1. `sudo journalctl -xeu kokkosofter.service --no-pager`

**使用タイミング**: サービスのエラーやログを確認

#### `make service-restart`
```bash
make service-restart
```
**説明**: systemdサービスを再起動  
**処理内容**:
1. `sudo systemctl daemon-reload`
2. `sudo systemctl restart kokkosofter.service`
3. ステータス確認

**使用タイミング**: 設定変更後、コード更新後

#### `make debug-gunicorn`
```bash
make debug-gunicorn
```
**説明**: デバッグモードでGunicornを起動  
**処理内容**:
1. デバッグ設定でGunicorn起動
2. ログレベル: debug
3. ワーカー数: 1

**使用タイミング**: 本番環境で詳細なデバッグが必要な場合

---

### 🔧 Nginx・Webサーバー管理

#### `make nginx-setup`
```bash
make nginx-setup
```
**説明**: Nginx設定をセットアップ  
**処理内容**:
1. デフォルトサイト無効化
2. KokkoSofter設定ファイルコピー
3. シンボリックリンク作成
4. Nginx設定テスト・リロード

**使用タイミング**: 初回本番環境構築時、設定変更時

#### `make nginx-test`
```bash
make nginx-test
```
**説明**: Nginx設定をテスト  
**処理内容**:
1. `sudo nginx -t`

**使用タイミング**: 設定変更後の確認

#### `make nginx-status`
```bash
make nginx-status
```
**説明**: Nginxサービスの状態を確認  
**処理内容**:
1. `sudo systemctl status nginx`

**使用タイミング**: Nginxの動作状況確認

#### `make nginx-disable-default`
```bash
make nginx-disable-default
```
**説明**: Nginxデフォルトサイトを無効化  
**処理内容**:
1. `/etc/nginx/sites-enabled/default` 削除
2. `/etc/nginx/sites-enabled/000-default` 削除

**使用タイミング**: 他のサイトと競合を避けたい場合

---

### 🌍 ドメイン・CSRF管理

#### `make configure-domain`
```bash
make configure-domain
```
**説明**: ドメイン名を対話式で設定  
**処理内容**:
1. ドメイン名の入力受付
2. .env の ALLOWED_HOSTS 更新
3. CSRF_TRUSTED_ORIGINS 設定
4. Nginx設定のserver_name更新

**使用タイミング**: 新しいドメインでアクセス可能にする場合

#### `make quick-domain-setup`
```bash
make quick-domain-setup
```
**説明**: ドメイン設定→Nginx適用→サービス再起動を一括実行  
**処理内容**:
1. `make configure-domain`
2. `make nginx-setup`
3. `make service-restart`

**使用タイミング**: ドメイン設定を完全に適用したい場合

#### `make fix-csrf`
```bash
make fix-csrf
```
**説明**: CSRF検証エラーを修正  
**処理内容**:
1. ドメイン名入力受付
2. ALLOWED_HOSTS, CSRF_TRUSTED_ORIGINS更新
3. CSRF設定調整
4. サービス再起動

**使用タイミング**: CSRF関連エラーが発生した場合

#### `make check-csrf`
```bash
make check-csrf
```
**説明**: CSRF関連設定を確認  
**処理内容**:
1. ALLOWED_HOSTS表示
2. CSRF_TRUSTED_ORIGINS表示
3. DEBUG設定表示
4. CSRF Cookie設定表示

**使用タイミング**: CSRF設定の確認

---

### 🔒 権限・セキュリティ管理

#### `make create-dirs`
```bash
make create-dirs
```
**説明**: 必要なディレクトリを作成  
**処理内容**:
1. `/var/log/kokkosofter`, `/var/run/kokkosofter` 作成
2. 所有者を www-data に設定
3. 適切な権限設定

**使用タイミング**: 本番環境初期構築時

#### `make fix-permissions`
```bash
make fix-permissions
```
**説明**: ファイル権限を修正  
**処理内容**:
1. プロジェクトディレクトリの所有者設定
2. static, media ディレクトリの権限設定
3. SQLiteデータベースファイルの権限設定

**使用タイミング**: 権限エラーが発生した場合

#### `make fix-media`
```bash
make fix-media
```
**説明**: メディアファイルの権限を修正  
**処理内容**:
1. メディアディレクトリ作成・権限設定
2. シンボリックリンク作成
3. SELinuxコンテキスト設定（該当環境）

**使用タイミング**: 画像アップロード・表示に問題がある場合

#### `make check-media`
```bash
make check-media
```
**説明**: メディアファイル設定を確認  
**処理内容**:
1. メディアディレクトリの権限確認
2. Nginx設定内のメディアパス確認
3. シンボリックリンク状態確認
4. settings.pyのメディア設定表示

**使用タイミング**: メディアファイル関連の問題診断

---

### 🐛 デバッグ・開発支援

#### `make debug-enable`
```bash
make debug-enable
```
**説明**: デバッグモードを一時的に有効化  
**処理内容**:
1. .env の DEBUG=True に変更
2. サービス再起動

**使用タイミング**: 本番環境で一時的にデバッグが必要な場合  
**⚠️ 注意**: セキュリティリスクがあるため、問題解決後は必ず無効化

#### `make debug-disable`
```bash
make debug-disable
```
**説明**: デバッグモードを無効化  
**処理内容**:
1. .env の DEBUG=False に変更
2. サービス再起動

**使用タイミング**: デバッグ作業完了後

#### `make test-django`
```bash
make test-django
```
**説明**: Django設定をテスト（本番環境用）  
**処理内容**:
1. `python manage.py check --deploy`

**使用タイミング**: 本番環境での設定検証

#### `make generate-secret-key`
```bash
make generate-secret-key
```
**説明**: Django用のSECRET_KEYを生成  
**処理内容**:
1. .envファイル作成（存在しない場合）
2. 新しいSECRET_KEY生成・設定

**使用タイミング**: セキュリティ向上のためのキー更新

---

### 🔄 Git・コード管理

#### `make fix-git-owner`
```bash
make fix-git-owner
```
**説明**: Git所有者問題を修正  
**処理内容**:
1. `git config --global --add safe.directory` 設定

**使用タイミング**: Git権限エラーが発生した場合

#### `make git-pull`
```bash
make git-pull
```
**説明**: 最新のコードを取得  
**処理内容**:
1. Git所有者問題修正
2. `git pull origin main`

**使用タイミング**: 最新のコード変更を取得

---

### 🪟 Windows専用コマンド

#### `make windows-setup` (Windows環境のみ)
```powershell
make windows-setup
```
**説明**: Windows環境向け自動セットアップ  
**処理内容**:
1. deploy.ps1 の実行権限確認
2. PowerShellスクリプト実行

**使用タイミング**: WindowsでMakeが利用可能な場合

#### `make powershell-deploy` (Windows環境のみ)
```powershell
make powershell-deploy env=development
```
**説明**: PowerShellデプロイスクリプトを実行  
**パラメータ**: `env=development` または `env=production`  
**使用タイミング**: WindowsでのPowerShellベースデプロイ

---

## 💡 使用例・シナリオ

### 🚀 初回セットアップ
```bash
# すべて自動で行う場合
make full-setup

# 段階的に行う場合
make install        # Python環境
make npm-install    # Node.js環境  
make build-css-prod # CSS構築
make migrate        # DB設定
make superuser      # 管理者作成
```

### 🔧 日常の開発作業
```bash
# 開発サーバー起動
make run

# CSS変更時（別ターミナル）
make build-css

# モデル変更後
make migrate

# テスト実行
make test
```

### 🌐 本番環境デプロイ
```bash
# ドメイン設定
make quick-domain-setup

# サービス管理
make service-restart
make service-status
make service-logs
```

### 🐛 トラブルシューティング
```bash
# 権限問題
make fix-permissions

# CSRF問題
make fix-csrf

# メディア問題  
make fix-media
```

---

## 🛠️ 開発環境セットアップ

### 1. 開発用設定

#### settings_dev.py 作成
```python
# KokkoSofter/settings_dev.py
from .settings import *

DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '0.0.0.0']

# 開発用データベース
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db_dev.sqlite3',
    }
}

# 開発用メール設定
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# デバッグツールバー（任意）
if 'debug_toolbar' in INSTALLED_APPS:
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
    INTERNAL_IPS = ['127.0.0.1']
```
style: コードスタイル
refactor: リファクタリング
test: テスト
chore: その他
```

## 🧪 テスト

### テストの実行

```bash
# 全テスト実行
python manage.py test

# 特定アプリのテスト
python manage.py test accounts
python manage.py test posts

# カバレッジ計測
coverage run --source='.' manage.py test
coverage report
coverage html
```

### テスト作成例

```python
# accounts/tests.py
from django.test import TestCase, Client
from django.contrib.auth.models import User
from django.urls import reverse

class UserAuthTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username='testuser',
            email='test@example.com',
            password='testpass123'
        )
    
    def test_login_success(self):
        response = self.client.post(reverse('accounts:login'), {
            'username': 'testuser',
            'password': 'testpass123'
        })
        self.assertEqual(response.status_code, 302)
    
    def test_profile_view(self):
        self.client.login(username='testuser', password='testpass123')
        response = self.client.get(reverse('accounts:profile'))
        self.assertEqual(response.status_code, 200)
```

## 🎨 フロントエンド開発

### TailwindCSS開発

#### 設定ファイル（tailwind.config.js）
```javascript
module.exports = {
  content: [
    './templates/**/*.html',
    './static/js/**/*.js',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a',
        }
      }
    },
  },
  plugins: [
    require('daisyui'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
  daisyui: {
    themes: ['light', 'dark', 'cupcake'],
  }
}
```

#### 開発用ビルド
```bash
# ウォッチモード（開発中）
npm run build-css

# 本番用ビルド
npm run build-css-prod
```

### JavaScript開発

#### モジュール構造
```javascript
// static/js/components/sidebar.js
export class Sidebar {
  constructor(element) {
    this.element = element;
    this.init();
  }
  
  init() {
    this.bindEvents();
    this.loadState();
  }
  
  bindEvents() {
    // イベントリスナー設定
  }
}

// static/js/main.js
import { Sidebar } from './components/sidebar.js';

document.addEventListener('DOMContentLoaded', () => {
  const sidebar = new Sidebar(document.querySelector('.sidebar'));
});
```

## 🗃️ データベース開発

### モデル設計

```python
# posts/models.py
from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_published = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['created_at']),
            models.Index(fields=['author', 'is_published']),
        ]
    
    def __str__(self):
        return self.title
    
    def get_absolute_url(self):
        return reverse('posts:detail', kwargs={'pk': self.pk})
```

### マイグレーション

```bash
# マイグレーション作成
python manage.py makemigrations

# マイグレーション確認
python manage.py showmigrations

# マイグレーション実行
python manage.py migrate

# 手動マイグレーション作成
python manage.py makemigrations --empty posts
```

### カスタムマイグレーション例

```python
# posts/migrations/0002_add_indexes.py
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('posts', '0001_initial'),
    ]

    operations = [
        migrations.RunSQL(
            "CREATE INDEX CONCURRENTLY idx_posts_content_search ON posts_post USING gin(to_tsvector('english', content));",
            reverse_sql="DROP INDEX idx_posts_content_search;",
        ),
    ]
```

## 🔧 カスタムコンポーネント開発

### ビュー開発

```python
# posts/views.py
from django.shortcuts import render, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from .models import Post
from .forms import PostForm

@login_required
def create_post(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()
            return JsonResponse({'success': True, 'post_id': post.id})
        else:
            return JsonResponse({'success': False, 'errors': form.errors})
    else:
        form = PostForm()
    
    return render(request, 'posts/create.html', {'form': form})

@require_http_methods(["POST"])
def like_post(request, post_id):
    post = get_object_or_404(Post, id=post_id)
    liked = post.likes.filter(user=request.user).exists()
    
    if liked:
        post.likes.filter(user=request.user).delete()
        liked = False
    else:
        post.likes.create(user=request.user)
        liked = True
    
    return JsonResponse({
        'liked': liked,
        'like_count': post.likes.count()
    })
```

### フォーム開発

```python
# posts/forms.py
from django import forms
from .models import Post

class PostForm(forms.ModelForm):
    class Meta:
        model = Post
        fields = ['title', 'content', 'image']
        widgets = {
            'title': forms.TextInput(attrs={
                'class': 'input input-bordered w-full',
                'placeholder': 'タイトルを入力...'
            }),
            'content': forms.Textarea(attrs={
                'class': 'textarea textarea-bordered w-full',
                'rows': 6,
                'placeholder': '内容を入力...'
            }),
            'image': forms.FileInput(attrs={
                'class': 'file-input file-input-bordered w-full',
                'accept': 'image/*'
            })
        }
    
    def clean_image(self):
        image = self.cleaned_data.get('image')
        if image:
            if image.size > 5 * 1024 * 1024:  # 5MB
                raise forms.ValidationError('画像サイズは5MB以下にしてください。')
        return image
```

### テンプレート開発

```html
<!-- templates/posts/create.html -->
{% extends 'base.html' %}
{% load static %}

{% block title %}新規投稿 - {{ block.super }}{% endblock %}

{% block content %}
<div class="container mx-auto px-4 py-8">
    <div class="max-w-2xl mx-auto">
        <h1 class="text-3xl font-bold mb-6">新規投稿</h1>
        
        <form id="post-form" method="post" enctype="multipart/form-data" 
              class="space-y-6">
            {% csrf_token %}
            
            <div class="form-control">
                <label class="label">
                    <span class="label-text">タイトル</span>
                </label>
                {{ form.title }}
                {% if form.title.errors %}
                    <div class="text-error text-sm mt-1">
                        {{ form.title.errors.0 }}
                    </div>
                {% endif %}
            </div>
            
            <div class="form-control">
                <label class="label">
                    <span class="label-text">内容</span>
                </label>
                {{ form.content }}
                {% if form.content.errors %}
                    <div class="text-error text-sm mt-1">
                        {{ form.content.errors.0 }}
                    </div>
                {% endif %}
            </div>
            
            <div class="form-control">
                <label class="label">
                    <span class="label-text">画像（任意）</span>
                </label>
                {{ form.image }}
            </div>
            
            <div class="flex gap-4">
                <button type="submit" class="btn btn-primary flex-1">
                    投稿する
                </button>
                <a href="{% url 'posts:list' %}" class="btn btn-outline">
                    キャンセル
                </a>
            </div>
        </form>
    </div>
</div>
{% endblock %}

{% block extra_js %}
<script src="{% static 'js/post-form.js' %}"></script>
{% endblock %}
```

## 📊 パフォーマンス最適化

### データベース最適化

```python
# クエリ最適化例
from django.db import models

class PostQuerySet(models.QuerySet):
    def with_author(self):
        return self.select_related('author')
    
    def with_likes(self):
        return self.prefetch_related('likes')
    
    def published(self):
        return self.filter(is_published=True)

class PostManager(models.Manager):
    def get_queryset(self):
        return PostQuerySet(self.model, using=self._db)
    
    def published_with_details(self):
        return self.get_queryset().published().with_author().with_likes()

class Post(models.Model):
    # フィールド定義...
    
    objects = PostManager()
```

### キャッシュ活用

```python
# views.py
from django.core.cache import cache
from django.views.decorators.cache import cache_page

@cache_page(60 * 15)  # 15分キャッシュ
def post_list(request):
    posts = Post.objects.published_with_details()
    return render(request, 'posts/list.html', {'posts': posts})

def get_popular_posts():
    cache_key = 'popular_posts'
    posts = cache.get(cache_key)
    
    if posts is None:
        posts = Post.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=7)
        ).annotate(
            like_count=models.Count('likes')
        ).order_by('-like_count')[:10]
        
        cache.set(cache_key, posts, 60 * 60)  # 1時間キャッシュ
    
    return posts
```

## 🔒 セキュリティ開発

### 入力検証

```python
# forms.py
import bleach
from django import forms

class PostForm(forms.ModelForm):
    def clean_content(self):
        content = self.cleaned_data['content']
        
        # HTMLサニタイズ
        allowed_tags = ['p', 'br', 'strong', 'em', 'u', 'ol', 'ul', 'li']
        content = bleach.clean(content, tags=allowed_tags, strip=True)
        
        # 長さ制限
        if len(content) > 10000:
            raise forms.ValidationError('投稿は10,000文字以内で入力してください。')
        
        return content
```

### 権限チェック

```python
# decorators.py
from functools import wraps
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404

def post_owner_required(view_func):
    @wraps(view_func)
    def wrapper(request, post_id, *args, **kwargs):
        post = get_object_or_404(Post, id=post_id)
        if post.author != request.user and not request.user.is_staff:
            return HttpResponseForbidden('この投稿を編集する権限がありません。')
        return view_func(request, post_id, *args, **kwargs)
    return wrapper

# views.py
@login_required
@post_owner_required
def edit_post(request, post_id):
    # 編集処理
    pass
```

## 🐛 デバッグ

### ログ設定

```python
# settings_dev.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
        },
        'posts': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

### デバッグツール

```python
# Django Debug Toolbar（開発時のみ）
pip install django-debug-toolbar

# settings_dev.py
INSTALLED_APPS += ['debug_toolbar']
MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
INTERNAL_IPS = ['127.0.0.1']

# urls.py
if settings.DEBUG:
    import debug_toolbar
    urlpatterns = [
        path('__debug__/', include(debug_toolbar.urls)),
    ] + urlpatterns
```

## 📦 パッケージ管理

### requirements.txt 管理

```bash
# 本番用
pip freeze > requirements.txt

# 開発用
pip freeze > requirements-dev.txt

# 分離管理
echo "Django>=4.2,<5.0" > requirements/base.txt
echo "-r base.txt\ndjango-debug-toolbar" > requirements/dev.txt
echo "-r base.txt\ngunicorn\npsycopg2-binary" > requirements/prod.txt
```

### 仮想環境管理

```bash
# pipenv使用（推奨）
pipenv install django
pipenv install --dev django-debug-toolbar
pipenv shell

# poetry使用
poetry init
poetry add django
poetry add --group dev django-debug-toolbar
poetry shell
```

---

[← READMEに戻る](../README.md) | [← デプロイメント](DEPLOYMENT.md) | [UI/UXガイド →](UI_GUIDE.md)
