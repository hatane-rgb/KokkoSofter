import requests
import json
from typing import Dict, Optional, Tuple

class WeatherService:
    """
    気象庁APIを使用した天気情報取得サービス
    """
    
    def __init__(self):
        self.base_url = "https://www.jma.go.jp/bosai/forecast/data/forecast/"
        self.area_url = "https://www.jma.go.jp/bosai/common/const/area.json"
        # 逆ジオコーディング用のAPI (OpenStreetMap Nominatim)
        self.geocoding_url = "https://nominatim.openstreetmap.org/reverse"
        
    def get_area_code_by_location(self, lat: float, lon: float) -> Optional[str]:
        """
        緯度経度から最寄りの地域コードを取得
        簡易実装：日本の主要都市との距離で判定
        """
        # 主要都市の座標と地域コード
        major_cities = {
            "130000": {"name": "東京", "lat": 35.6762, "lon": 139.6503},
            "270000": {"name": "大阪", "lat": 34.6937, "lon": 135.5023},
            "140000": {"name": "神奈川", "lat": 35.4478, "lon": 139.6425},
            "230000": {"name": "愛知", "lat": 35.1815, "lon": 136.9066},
            "010000": {"name": "北海道", "lat": 43.0642, "lon": 141.3469},
            "040000": {"name": "宮城", "lat": 38.2682, "lon": 140.8694},
            "340000": {"name": "広島", "lat": 34.3853, "lon": 132.4553},
            "400000": {"name": "福岡", "lat": 33.5904, "lon": 130.4017},
            "470000": {"name": "沖縄", "lat": 26.2125, "lon": 127.6792},
        }
        
        min_distance = float('inf')
        closest_code = "130000"  # デフォルトは東京
        
        for code, city in major_cities.items():
            # 簡易距離計算（度数での差分）
            distance = ((lat - city["lat"]) ** 2 + (lon - city["lon"]) ** 2) ** 0.5
            if distance < min_distance:
                min_distance = distance
                closest_code = code
                
        return closest_code
    
    def get_weather_forecast(self, area_code: str) -> Optional[Dict]:
        """
        地域コードから天気予報を取得
        """
        try:
            url = f"{self.base_url}{area_code}.json"
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            print(f"Weather API error: {e}")
            return None
    
    def parse_weather_data(self, weather_data: Dict) -> Optional[Dict]:
        """
        天気データを解析して必要な情報を抽出
        """
        try:
            if not weather_data or len(weather_data) == 0:
                return None
                
            # 最初の予報データを使用
            forecast = weather_data[0]
            
            # 今日の天気情報を取得
            time_series = forecast.get("timeSeries", [])
            if not time_series:
                return None
                
            # 天気情報
            weather_series = time_series[0] if len(time_series) > 0 else None
            temp_series = time_series[1] if len(time_series) > 1 else None
            
            result = {
                "area_name": "",
                "weather": "情報なし",
                "temperature": "",
                "update_time": ""
            }
            
            # 地域名
            if weather_series and "areas" in weather_series:
                areas = weather_series["areas"]
                if areas and len(areas) > 0:
                    result["area_name"] = areas[0].get("area", {}).get("name", "")
            
            # 天気
            if weather_series and "areas" in weather_series:
                areas = weather_series["areas"]
                if areas and len(areas) > 0 and "weathers" in areas[0]:
                    weathers = areas[0]["weathers"]
                    if weathers and len(weathers) > 0:
                        result["weather"] = weathers[0]
            
            # 気温
            if temp_series and "areas" in temp_series:
                areas = temp_series["areas"]
                if areas and len(areas) > 0:
                    temps = areas[0].get("temps", [])
                    if temps and len(temps) > 0:
                        result["temperature"] = f"{temps[0]}°C"
            
            # 更新時間
            if forecast.get("reportDatetime"):
                result["update_time"] = forecast["reportDatetime"]
            
            return result
            
        except (KeyError, IndexError, TypeError) as e:
            print(f"Weather data parsing error: {e}")
            return None
    
    def get_weather_by_location(self, lat: float, lon: float) -> Optional[Dict]:
        """
        緯度経度から天気情報を取得
        """
        # 位置情報から地名を取得
        location_info = self.get_location_name(lat, lon)
        
        area_code = self.get_area_code_by_location(lat, lon)
        if not area_code:
            return None
            
        weather_data = self.get_weather_forecast(area_code)
        if not weather_data:
            return None
            
        weather_result = self.parse_weather_data(weather_data)
        if not weather_result:
            return None
        
        # 位置情報を追加
        weather_result.update({
            'prefecture': location_info.get('prefecture', ''),
            'city': location_info.get('city', ''),
            'full_address': location_info.get('full_address', '')
        })
        
        return weather_result
    
    def get_location_name(self, lat: float, lon: float) -> Dict[str, str]:
        """
        緯度経度から都道府県・市町村名を取得
        """
        try:
            params = {
                'lat': lat,
                'lon': lon,
                'format': 'json',
                'accept-language': 'ja',
                'addressdetails': 1
            }
            
            response = requests.get(self.geocoding_url, params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            address = data.get('address', {})
            
            # 日本の住所構造に合わせて抽出
            prefecture = (
                address.get('state') or 
                address.get('province') or 
                address.get('county') or 
                address.get('prefecture', '')
            )
            
            city = (
                address.get('city') or 
                address.get('town') or 
                address.get('village') or 
                address.get('municipality', '')
            )
            
            # 「〜県」「〜都」「〜府」「〜道」が含まれていない場合は追加
            if prefecture and not any(suffix in prefecture for suffix in ['県', '都', '府', '道']):
                # 主要な都道府県名のマッピング
                prefecture_mapping = {
                    'Tokyo': '東京都',
                    'Osaka': '大阪府',
                    'Kyoto': '京都府',
                    'Hokkaido': '北海道'
                }
                prefecture = prefecture_mapping.get(prefecture, prefecture + '県')
            
            return {
                'prefecture': prefecture,
                'city': city,
                'full_address': data.get('display_name', '')
            }
            
        except requests.RequestException as e:
            print(f"Geocoding API error: {e}")
            return {'prefecture': '', 'city': '', 'full_address': ''}
        except (KeyError, TypeError) as e:
            print(f"Geocoding data parsing error: {e}")
            return {'prefecture': '', 'city': '', 'full_address': ''}
