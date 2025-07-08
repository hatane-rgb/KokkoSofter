from django.contrib.auth.views import LoginView
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth.models import User
from django.db.models import Count
from .models import UserProfile
from .forms import UserProfileForm, UserUpdateForm

class CustomLoginView(LoginView):
    template_name = 'home.html'

@login_required
def profile_settings(request):
    """プロフィール設定ページ"""
    # ユーザープロフィールを取得または作成
    profile, created = UserProfile.objects.get_or_create(user=request.user)
    
    if request.method == 'POST':
        user_form = UserUpdateForm(request.POST, instance=request.user)
        profile_form = UserProfileForm(request.POST, request.FILES, instance=profile)
        
        if user_form.is_valid() and profile_form.is_valid():
            user_form.save()
            profile_form.save()
            messages.success(request, 'プロフィールが更新されました。')
            return redirect('accounts:profile_settings')
    else:
        user_form = UserUpdateForm(instance=request.user)
        profile_form = UserProfileForm(instance=profile)
    
    context = {
        'user_form': user_form,
        'profile_form': profile_form,
        'profile': profile,
    }
    return render(request, 'accounts/profile_settings.html', context)

@staff_member_required
def admin_dashboard(request):
    """管理者用ダッシュボード"""
    # 統計情報を取得
    total_users = User.objects.count()
    active_users = User.objects.filter(is_active=True).count()
    staff_users = User.objects.filter(is_staff=True).count()
    superusers = User.objects.filter(is_superuser=True).count()
    
    # 投稿数も取得（postsアプリが存在する場合）
    try:
        from posts.models import Post
        total_posts = Post.objects.count()
        recent_posts = Post.objects.order_by('-created_at')[:5]
    except ImportError:
        total_posts = 0
        recent_posts = []
    
    # 最近登録されたユーザー
    recent_users = User.objects.order_by('-date_joined')[:5]
    
    context = {
        'total_users': total_users,
        'active_users': active_users,
        'staff_users': staff_users,
        'superusers': superusers,
        'total_posts': total_posts,
        'recent_posts': recent_posts,
        'recent_users': recent_users,
    }
    return render(request, 'accounts/admin_dashboard.html', context)

@staff_member_required
def admin_users(request):
    """管理者用ユーザー管理ページ"""
    users = User.objects.annotate(
        post_count=Count('post')
    ).order_by('-date_joined')
    
    context = {
        'users': users,
    }
    return render(request, 'accounts/admin_users.html', context)