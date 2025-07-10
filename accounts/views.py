from django.contrib.auth.views import LoginView
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from django.db.models import Count
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from functools import wraps
from .models import UserProfile
from .forms import UserProfileForm, UserUpdateForm, AdminUserCreateForm, AdminUserEditForm, AdminUserProfileForm

def role_management_required(view_func):
    """ロール管理権限が必要なビューのデコレーター"""
    @wraps(view_func)
    def wrapped_view(request, *args, **kwargs):
        if not request.user.is_authenticated:
            return redirect('login')
        
        # プロフィールがない場合は作成
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        
        # 管理者権限またはロール管理権限をチェック
        if not (request.user.is_staff or profile.can_manage_users()):
            messages.error(request, 'この機能を利用する権限がありません。')
            return redirect('/')
        
        return view_func(request, *args, **kwargs)
    return wrapped_view

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

@role_management_required
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

@role_management_required
def admin_users(request):
    """管理者用ユーザー管理ページ"""
    users = User.objects.annotate(
        post_count=Count('post')
    ).order_by('-date_joined')
    
    context = {
        'users': users,
        'role_choices': UserProfile.ROLE_CHOICES,
    }
    return render(request, 'accounts/admin_users.html', context)

@role_management_required
def admin_create_user(request):
    """管理者用ユーザー作成ページ"""
    if request.method == 'POST':
        form = AdminUserCreateForm(request.POST)
        if form.is_valid():
            user = form.save()
            messages.success(request, f'ユーザー「{user.username}」を作成しました。')
            return redirect('accounts:admin_users')
    else:
        form = AdminUserCreateForm()
    
    context = {
        'form': form,
    }
    return render(request, 'accounts/admin_create_user.html', context)

@staff_member_required
def admin_toggle_user_status(request, user_id):
    """管理者用ユーザー状態切り替え（アクティブ/非アクティブ）"""
    user = get_object_or_404(User, id=user_id)
    
    # スーパーユーザーの場合は変更を制限
    if user.is_superuser and not request.user.is_superuser:
        messages.error(request, 'スーパーユーザーの状態は変更できません。')
        return redirect('accounts:admin_users')
    
    user.is_active = not user.is_active
    user.save()
    
    status = "有効" if user.is_active else "無効"
    messages.success(request, f'ユーザー「{user.username}」を{status}にしました。')
    return redirect('accounts:admin_users')

@staff_member_required
def admin_toggle_staff_status(request, user_id):
    """管理者用スタッフ権限切り替え"""
    if not request.user.is_superuser:
        messages.error(request, 'スーパーユーザーのみスタッフ権限を変更できます。')
        return redirect('accounts:admin_users')
    
    user = get_object_or_404(User, id=user_id)
    
    if user.is_superuser:
        messages.error(request, 'スーパーユーザーのスタッフ権限は変更できません。')
        return redirect('accounts:admin_users')
    
    user.is_staff = not user.is_staff
    user.save()
    
    status = "付与" if user.is_staff else "削除"
    messages.success(request, f'ユーザー「{user.username}」のスタッフ権限を{status}しました。')
    return redirect('accounts:admin_users')

@role_management_required
def admin_edit_user(request, user_id):
    """管理者用ユーザー編集ページ"""
    edit_user = get_object_or_404(User, id=user_id)
    
    # ユーザープロフィールを取得または作成
    profile, created = UserProfile.objects.get_or_create(user=edit_user)
    
    # スーパーユーザーの編集は制限
    if edit_user.is_superuser and not request.user.is_superuser:
        messages.error(request, 'スーパーユーザーの編集権限がありません。')
        return redirect('accounts:admin_users')
    
    if request.method == 'POST':
        form = AdminUserEditForm(request.POST, instance=edit_user)
        profile_form = AdminUserProfileForm(request.POST, request.FILES, instance=profile)
        
        if form.is_valid() and profile_form.is_valid():
            form.save()
            profile_form.save()
            messages.success(request, f'ユーザー「{edit_user.username}」を更新しました。')
            return redirect('accounts:admin_users')
    else:
        form = AdminUserEditForm(instance=edit_user)
        profile_form = AdminUserProfileForm(instance=profile)
    
    context = {
        'form': form,
        'profile_form': profile_form,
        'edit_user': edit_user,
    }
    return render(request, 'accounts/admin_edit_user.html', context)

@role_management_required
@require_POST
def admin_delete_user(request, user_id):
    """管理者用ユーザー削除（Ajax）"""
    try:
        delete_user = get_object_or_404(User, id=user_id)
        
        # 自分自身やスーパーユーザーの削除は制限
        if delete_user == request.user:
            return JsonResponse({'success': False, 'error': '自分自身は削除できません。'}, status=400)
        
        if delete_user.is_superuser and not request.user.is_superuser:
            return JsonResponse({'success': False, 'error': 'スーパーユーザーの削除権限がありません。'}, status=403)
        
        username = delete_user.username
        delete_user.delete()
        
        return JsonResponse({'success': True, 'message': f'ユーザー「{username}」を削除しました。'})
    
    except Exception as e:
        return JsonResponse({'success': False, 'error': '削除に失敗しました。'}, status=500)

@role_management_required
@require_POST
def admin_change_user_role(request, user_id):
    """管理者用ユーザーロール変更（Ajax）"""
    try:
        target_user = get_object_or_404(User, id=user_id)
        new_role = request.POST.get('role')
        
        # プロフィールを取得または作成
        profile, created = UserProfile.objects.get_or_create(user=target_user)
        
        # ロールの妥当性チェック
        valid_roles = [choice[0] for choice in UserProfile.ROLE_CHOICES]
        if new_role not in valid_roles:
            return JsonResponse({'success': False, 'error': '無効なロールです。'}, status=400)
        
        # オーナーロールの制限（現在のユーザーがオーナーでない場合）
        current_user_profile, _ = UserProfile.objects.get_or_create(user=request.user)
        if new_role == 'owner' and current_user_profile.role != 'owner' and not request.user.is_superuser:
            return JsonResponse({'success': False, 'error': 'オーナーロールの設定権限がありません。'}, status=403)
        
        # 自分自身のロールを下げることの防止
        if target_user == request.user and new_role == 'member':
            return JsonResponse({'success': False, 'error': '自分自身のロールを下げることはできません。'}, status=400)
        
        # ロール変更
        old_role = profile.get_role_display_with_icon()
        profile.role = new_role
        profile.save()
        
        new_role_display = profile.get_role_display_with_icon()
        
        return JsonResponse({
            'success': True, 
            'message': f'{target_user.username}のロールを「{old_role}」から「{new_role_display}」に変更しました。',
            'new_role_display': new_role_display,
            'new_role_class': profile.get_role_badge_class()
        })
        
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)}, status=500)

@role_management_required
def admin_bulk_role_management(request):
    """管理者用一括ロール管理ページ"""
    users = User.objects.select_related('profile').order_by('username')
    
    if request.method == 'POST':
        # 一括ロール変更処理
        user_roles = {}
        for key, value in request.POST.items():
            if key.startswith('role_'):
                user_id = key.replace('role_', '')
                user_roles[user_id] = value
        
        updated_count = 0
        for user_id, new_role in user_roles.items():
            try:
                user = User.objects.get(id=user_id)
                profile, created = UserProfile.objects.get_or_create(user=user)
                
                # ロールの妥当性チェック
                valid_roles = [choice[0] for choice in UserProfile.ROLE_CHOICES]
                if new_role in valid_roles and profile.role != new_role:
                    profile.role = new_role
                    profile.save()
                    updated_count += 1
            except User.DoesNotExist:
                continue
        
        messages.success(request, f'{updated_count}人のユーザーロールを更新しました。')
        return redirect('accounts:admin_bulk_role_management')
    
    context = {
        'users': users,
        'role_choices': UserProfile.ROLE_CHOICES,
    }
    return render(request, 'accounts/admin_bulk_role_management.html', context)