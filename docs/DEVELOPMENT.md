# 🔧 開発ガイド

KokkoSofterの開発に参加する際のガイドです。

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

#### 開発用サーバー起動
```bash
# 開発設定で起動
python manage.py runserver --settings=KokkoSofter.settings_dev

# または環境変数で設定
export DJANGO_SETTINGS_MODULE=KokkoSofter.settings_dev
python manage.py runserver
```

### 2. Git ワークフロー

#### ブランチ戦略
```bash
# 機能開発
git checkout -b feature/new-feature
git commit -m "feat: 新機能の追加"

# バグ修正
git checkout -b fix/bug-description
git commit -m "fix: バグの修正"

# ドキュメント
git checkout -b docs/update-readme
git commit -m "docs: READMEの更新"
```

#### コミットメッセージ規約
```
feat: 新機能
fix: バグ修正
docs: ドキュメント
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
