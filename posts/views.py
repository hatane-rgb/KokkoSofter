from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from django.contrib.auth.decorators import login_required
from django.views.decorators.http import require_POST
from django.contrib import messages
from .forms import PostForm
from .models import Post

@login_required
def create_post(request):
    if request.method == 'POST':
        form = PostForm(request.POST, request.FILES)
        if form.is_valid():
            post = form.save(commit=False)
            post.author = request.user
            post.save()
            return redirect('/')
    else:
        form = PostForm()
    return render(request, 'posts/post_form.html', {'form': form})

@login_required
@require_POST
def post_like_toggle(request, post_id):  # ここをurls.pyの名前に合わせて統一
    post = get_object_or_404(Post, id=post_id)
    user = request.user

    if post.likes.filter(id=user.id).exists():
        post.likes.remove(user)
        liked = False
    else:
        post.likes.add(user)
        liked = True

    like_count = post.likes.count()

    return JsonResponse({'liked': liked, 'like_count': like_count})

@login_required
@require_POST
def delete_post(request, post_id):
    """投稿削除機能"""
    post = get_object_or_404(Post, id=post_id)
    
    # 作成者本人または管理者のみ削除可能
    if post.author != request.user and not (request.user.is_staff or request.user.is_superuser):
        return JsonResponse({'success': False, 'error': '削除権限がありません。'}, status=403)
    
    try:
        post.delete()
        return JsonResponse({'success': True, 'message': '投稿を削除しました。'})
    except Exception as e:
        return JsonResponse({'success': False, 'error': '削除に失敗しました。'}, status=500)

@login_required
def admin_posts(request):
    """管理者用投稿管理ページ"""
    if not (request.user.is_staff or request.user.is_superuser):
        messages.error(request, '管理者権限が必要です。')
        return redirect('/')
    
    posts = Post.objects.select_related('author').order_by('-created_at')
    
    context = {
        'posts': posts,
    }
    return render(request, 'posts/admin_posts.html', context)
