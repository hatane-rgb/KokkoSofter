// デジタル時計機能

class DigitalClock {
  constructor() {
    this.clockEl = null;
    this.dateEl = null;
    this.intervalId = null;
  }

  init() {
    this.clockEl = document.getElementById('digital-clock');
    this.dateEl = document.getElementById('digital-date');

    if (this.clockEl || this.dateEl) {
      this.update(); // 即座に更新
      this.intervalId = setInterval(() => this.update(), 1000); // 1秒ごとに更新
    }
  }

  update() {
    const now = new Date();
    
    // 時刻表示 (HH:MM:SS)
    const timeString = now.toLocaleTimeString('ja-JP', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    });
    
    // 日付表示 (YYYY年MM月DD日 曜日)
    const dateString = now.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      weekday: 'short'
    });
    
    if (this.clockEl) this.clockEl.textContent = timeString;
    if (this.dateEl) this.dateEl.textContent = dateString;
  }

  destroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
}

// グローバルインスタンス
const digitalClock = new DigitalClock();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => digitalClock.init());
} else {
  digitalClock.init();
}

// ページ離脱時のクリーンアップ
window.addEventListener('beforeunload', () => digitalClock.destroy());
