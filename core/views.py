from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from posts.models import Post
from .weather import WeatherService
import json

def home(request):
    posts = Post.objects.order_by('-created_at')
    return render(request, 'home.html', {'posts': posts})

@require_http_methods(["POST"])
def get_weather(request):
    """
    緯度経度から天気情報を取得するAPIエンドポイント
    """
    try:
        data = json.loads(request.body)
        lat = float(data.get('lat'))
        lon = float(data.get('lon'))
        
        weather_service = WeatherService()
        weather_data = weather_service.get_weather_by_location(lat, lon)
        
        if weather_data:
            return JsonResponse({
                'success': True,
                'data': weather_data
            })
        else:
            return JsonResponse({
                'success': False,
                'error': '天気情報を取得できませんでした'
            })
            
    except (ValueError, KeyError, json.JSONDecodeError) as e:
        return JsonResponse({
            'success': False,
            'error': 'パラメータが無効です'
        }, status=400)
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': 'サーバーエラーが発生しました'
        }, status=500)

@login_required
@require_http_methods(["GET"])
def get_online_users(request):
    """
    オンラインユーザー一覧を取得するAPIエンドポイント
    """
    try:
        # 過去5分以内にアクティブだったユーザーをオンラインとみなす
        online_threshold = timezone.now() - timedelta(minutes=5)
        
        # プロフィールのlast_seenを使用してオンラインユーザーを取得
        online_users = User.objects.filter(
            profile__last_seen__gte=online_threshold,
            is_active=True
        ).exclude(id=request.user.id).select_related('profile')[:10]  # 最大10人まで表示
        
        users_data = []
        for user in online_users:
            users_data.append({
                'username': user.username,
                'avatar_url': user.profile.get_avatar_url() if hasattr(user, 'profile') else '/static/images/default-avatar.png',
                'role_badge_class': user.profile.get_role_badge_class() if hasattr(user, 'profile') else 'badge-secondary',
                'role_icon': user.profile.get_role_display_with_icon() if hasattr(user, 'profile') else '👤',
                'last_seen': user.profile.last_seen.isoformat() if hasattr(user, 'profile') else None
            })
        
        return JsonResponse({
            'success': True,
            'users': users_data,
            'total_count': len(users_data)
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': 'オンラインユーザー情報を取得できませんでした'
        }, status=500)

@login_required
@require_http_methods(["GET"])
def get_notifications(request):
    """
    通知一覧を取得するAPIエンドポイント
    """
    try:
        # 実際の通知システムが実装されるまでは、最近の投稿からサンプル通知を生成
        notifications_data = []
        
        # 最近の投稿から通知を生成（例：いいねやコメント）
        recent_posts = Post.objects.filter(author=request.user).order_by('-created_at')[:3]
        
        for post in recent_posts:
            if post.likes.count() > 0:
                notifications_data.append({
                    'message': f'あなたの投稿「{post.content[:20]}...」にいいねがつきました',
                    'type': 'like',
                    'time_ago': '5分前',
                    'read': False
                })
        
        # 新しいユーザーの参加通知
        new_users = User.objects.filter(
            date_joined__gte=timezone.now() - timedelta(days=1)
        ).exclude(id=request.user.id)[:2]
        
        for user in new_users:
            notifications_data.append({
                'message': f'{user.username} さんが参加しました',
                'type': 'user_joined',
                'time_ago': '1時間前',
                'read': False
            })
        
        return JsonResponse({
            'success': True,
            'notifications': notifications_data[:5]  # 最大5件まで表示
        })
        
    except Exception as e:
        return JsonResponse({
            'success': False,
            'error': '通知情報を取得できませんでした'
        }, status=500)
