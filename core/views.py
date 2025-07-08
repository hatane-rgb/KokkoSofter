from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
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
