import requests
import json
import os
from typing import Dict, Optional
from django.conf import settings

class WeatherService:
    """
    OpenWeatherMap APIを使用した高精度天気情報取得サービス
    """
    
    def __init__(self):
        # OpenWeatherMap API設定
        self.api_key = getattr(settings, 'OPENWEATHER_API_KEY', '40c2e9c8a8ea9c1bba456b9fa3e8b7dd')  # 環境変数から取得
        self.base_url = "https://api.openweathermap.org/data/2.5"
        self.geocoding_url = "https://api.openweathermap.org/geo/1.0"
        
    def get_weather_by_location(self, lat: float, lon: float) -> Optional[Dict]:
        """
        緯度経度から高精度な天気情報を取得
        """
        try:
            # 現在の天気を取得
            weather_url = f"{self.base_url}/weather"
            params = {
                'lat': lat,
                'lon': lon,
                'appid': self.api_key,
                'units': 'metric',  # 摂氏温度
                'lang': 'ja'        # 日本語
            }
            
            response = requests.get(weather_url, params=params, timeout=10)
            
            if response.status_code != 200:
                print(f"OpenWeatherMap API error: {response.status_code}")
                return self._get_fallback_weather(lat, lon)
            
            data = response.json()
            
            # 場所名を取得（逆ジオコーディング）
            location_info = self._get_location_name(lat, lon)
            
            # データを整形
            weather_info = {
                'prefecture': location_info.get('prefecture', '不明'),
                'city': location_info.get('city', '不明'),
                'area_name': f"{location_info.get('prefecture', '')} {location_info.get('city', '')}".strip(),
                'weather': data['weather'][0]['description'],
                'temperature': f"{round(data['main']['temp'])}°C",
                'humidity': f"{data['main']['humidity']}%",
                'pressure': f"{data['main']['pressure']}hPa",
                'wind_speed': f"{data['wind']['speed']}m/s" if 'wind' in data else '0m/s',
                'feels_like': f"{round(data['main']['feels_like'])}°C",
                'visibility': f"{data.get('visibility', 0) / 1000:.1f}km",
                'update_time': data['dt'],
                'icon': data['weather'][0]['icon'],
                'coord': {
                    'lat': data['coord']['lat'],
                    'lon': data['coord']['lon']
                }
            }
            
            return weather_info
            
        except requests.exceptions.RequestException as e:
            print(f"Weather API request error: {e}")
            return self._get_fallback_weather(lat, lon)
        except Exception as e:
            print(f"Weather service error: {e}")
            return None
    
    def _get_location_name(self, lat: float, lon: float) -> Dict[str, str]:
        """
        緯度経度から地名を取得（逆ジオコーディング）
        """
        try:
            # OpenStreetMap Nominatimを使用（無料）
            nominatim_url = "https://nominatim.openstreetmap.org/reverse"
            params = {
                'lat': lat,
                'lon': lon,
                'format': 'json',
                'accept-language': 'ja',
                'zoom': 10
            }
            
            headers = {
                'User-Agent': 'KokkoSofter Weather App'
            }
            
            response = requests.get(nominatim_url, params=params, headers=headers, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                address = data.get('address', {})
                
                # 日本の住所体系に合わせて抽出
                prefecture = (
                    address.get('state') or 
                    address.get('prefecture') or 
                    address.get('province') or
                    '不明'
                )
                
                city = (
                    address.get('city') or 
                    address.get('town') or 
                    address.get('village') or 
                    address.get('suburb') or
                    '不明'
                )
                
                return {
                    'prefecture': prefecture,
                    'city': city
                }
                
        except Exception as e:
            print(f"Geocoding error: {e}")
        
        # フォールバック：大まかな地域判定
        return self._estimate_location_by_coords(lat, lon)
    
    def _estimate_location_by_coords(self, lat: float, lon: float) -> Dict[str, str]:
        """
        座標から大まかな地域を推定
        """
        # 日本の主要地域の座標範囲
        regions = [
            {'name': '北海道', 'city': '札幌', 'lat_min': 41.0, 'lat_max': 46.0, 'lon_min': 139.0, 'lon_max': 146.0},
            {'name': '東京都', 'city': '東京', 'lat_min': 35.5, 'lat_max': 36.0, 'lon_min': 139.0, 'lon_max': 140.0},
            {'name': '大阪府', 'city': '大阪', 'lat_min': 34.4, 'lat_max': 35.0, 'lon_min': 135.0, 'lon_max': 136.0},
            {'name': '愛知県', 'city': '名古屋', 'lat_min': 34.8, 'lat_max': 35.5, 'lon_min': 136.5, 'lon_max': 137.5},
            {'name': '福岡県', 'city': '福岡', 'lat_min': 33.2, 'lat_max': 34.0, 'lon_min': 130.0, 'lon_max': 131.0},
            {'name': '沖縄県', 'city': '那覇', 'lat_min': 24.0, 'lat_max': 27.0, 'lon_min': 123.0, 'lon_max': 132.0},
        ]
        
        for region in regions:
            if (region['lat_min'] <= lat <= region['lat_max'] and 
                region['lon_min'] <= lon <= region['lon_max']):
                return {
                    'prefecture': region['name'],
                    'city': region['city']
                }
        
        return {'prefecture': '日本', 'city': '不明'}
    
    def _get_fallback_weather(self, lat: float, lon: float) -> Optional[Dict]:
        """
        メインAPIが失敗した場合のフォールバック天気情報
        """
        location_info = self._estimate_location_by_coords(lat, lon)
        return {
            'prefecture': location_info['prefecture'],
            'city': location_info['city'],
            'area_name': f"{location_info['prefecture']} {location_info['city']}",
            'weather': '天気情報を取得できませんでした',
            'temperature': '--°C',
            'humidity': '--%',
            'pressure': '--hPa',
            'wind_speed': '--m/s',
            'feels_like': '--°C',
            'visibility': '--km',
            'update_time': None,
            'icon': '01d',
            'coord': {'lat': lat, 'lon': lon}
        }
