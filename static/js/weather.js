// 天気情報機能

class WeatherWidget {
  constructor() {
    this.loadingEl = null;
    this.dataEl = null;
    this.errorEl = null;
    this.retryBtn = null;
  }

  init() {
    this.loadingEl = document.getElementById('weather-loading');
    this.dataEl = document.getElementById('weather-data');
    this.errorEl = document.getElementById('weather-error');
    this.retryBtn = document.getElementById('weather-retry');

    if (this.retryBtn) {
      this.retryBtn.addEventListener('click', () => {
        this.reset();
        this.loadWeatherInfo();
      });
    }

    this.loadWeatherInfo();
  }

  reset() {
    if (this.loadingEl) this.loadingEl.classList.remove('hidden');
    if (this.dataEl) this.dataEl.classList.add('hidden');
    if (this.errorEl) this.errorEl.classList.add('hidden');
  }

  async fetchWeatherData(lat, lon) {
    try {
      const response = await fetch('/api/weather/', {
        method: 'POST',
        headers: {
          'X-CSRFToken': getCookie('csrftoken'),
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ lat: lat, lon: lon }),
      });

      if (!response.ok) throw new Error('Network response was not ok');
      return await response.json();
    } catch (error) {
      console.error('Weather API error:', error);
      return { success: false, error: error.message };
    }
  }

  loadWeatherInfo() {
    if (!navigator.geolocation) {
      this.showError('位置情報がサポートされていません');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const lat = position.coords.latitude;
        const lon = position.coords.longitude;

        const result = await this.fetchWeatherData(lat, lon);

        if (this.loadingEl) this.loadingEl.classList.add('hidden');

        if (result.success && result.data) {
          this.displayWeatherData(result.data);
        } else {
          this.showError(result.error || '天気情報を取得できませんでした');
        }
      },
      (error) => {
        if (this.loadingEl) this.loadingEl.classList.add('hidden');
        
        let errorMessage = '位置情報の取得に失敗しました';
        switch (error.code) {
          case error.PERMISSION_DENIED:
            errorMessage = '位置情報の取得が拒否されました';
            break;
          case error.POSITION_UNAVAILABLE:
            errorMessage = '位置情報が利用できません';
            break;
          case error.TIMEOUT:
            errorMessage = '位置情報の取得がタイムアウトしました';
            break;
        }
        
        this.showError(errorMessage);
      },
      {
        timeout: 10000,
        enableHighAccuracy: false,
        maximumAge: 600000 // 10分間キャッシュ
      }
    );
  }

  displayWeatherData(weather) {
    if (!this.dataEl) return;

    // 都道府県・市町村名を表示
    const locationText = [weather.prefecture, weather.city].filter(Boolean).join(' ');
    const locationEl = document.getElementById('weather-location');
    if (locationEl) locationEl.textContent = locationText || '位置不明';
    
    const areaEl = document.getElementById('weather-area');
    if (areaEl) areaEl.textContent = weather.area_name || '地域不明';
    
    const descEl = document.getElementById('weather-desc');
    if (descEl) descEl.textContent = weather.weather || '情報なし';
    
    const tempEl = document.getElementById('weather-temp');
    if (tempEl) tempEl.textContent = weather.temperature || '';
    
    // 更新時間を表示
    if (weather.update_time) {
      const updateTime = new Date(weather.update_time);
      const timeStr = updateTime.toLocaleString('ja-JP', {
        month: 'numeric',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
      const timeEl = document.getElementById('weather-time');
      if (timeEl) timeEl.textContent = `更新: ${timeStr}`;
    }

    this.dataEl.classList.remove('hidden');
  }

  showError(message) {
    if (this.errorEl) {
      this.errorEl.classList.remove('hidden');
      const textNode = this.errorEl.firstChild;
      if (textNode && textNode.nodeType === Node.TEXT_NODE) {
        textNode.textContent = message;
      } else {
        this.errorEl.insertBefore(document.createTextNode(message), this.errorEl.firstChild);
      }
    }
  }
}

// グローバルインスタンス
const weatherWidget = new WeatherWidget();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => weatherWidget.init());
} else {
  weatherWidget.init();
}
