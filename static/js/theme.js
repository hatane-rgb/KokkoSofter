// テーマ切り替え機能

class ThemeManager {
  constructor() {
    this.themeToggle = null;
    this.mobileThemeToggle = null;
    this.htmlElement = document.documentElement;
  }

  init() {
    this.themeToggle = document.getElementById('theme-toggle');
    this.mobileThemeToggle = document.getElementById('mobile-theme-toggle');

    if (!this.themeToggle) return;

    // 初期テーマを設定
    const currentTheme = this.getCurrentTheme();
    this.applyTheme(currentTheme);

    // イベントリスナー設定
    this.setupEventListeners();
  }

  getSystemTheme() {
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  getCurrentTheme() {
    const savedTheme = localStorage.getItem('theme');
    return savedTheme || this.getSystemTheme();
  }

  applyTheme(theme) {
    const logoImage = document.getElementById('logo-image');
    const mobileLogoImage = document.getElementById('mobile-logo-image');
    
    if (theme === 'dark') {
      this.htmlElement.setAttribute('data-theme', 'dark');
      if (this.themeToggle) this.themeToggle.checked = true;
      if (this.mobileThemeToggle) this.mobileThemeToggle.checked = true;
      
      // ロゴ画像の切り替え（テンプレート変数は使用不可のため、固定パス使用）
      if (logoImage) logoImage.src = "/static/images/logo.png";
      if (mobileLogoImage) mobileLogoImage.src = "/static/images/logo.png";
    } else {
      this.htmlElement.setAttribute('data-theme', 'light');
      if (this.themeToggle) this.themeToggle.checked = false;
      if (this.mobileThemeToggle) this.mobileThemeToggle.checked = false;
      
      if (logoImage) logoImage.src = "/static/images/logo1.png";
      if (mobileLogoImage) mobileLogoImage.src = "/static/images/logo1.png";
    }
    
    localStorage.setItem('theme', theme);
  }

  setupEventListeners() {
    // デスクトップ版テーマトグル
    if (this.themeToggle) {
      this.themeToggle.addEventListener('change', (e) => {
        const newTheme = e.target.checked ? 'dark' : 'light';
        this.applyTheme(newTheme);
      });
    }

    // モバイル版テーマトグル
    if (this.mobileThemeToggle) {
      this.mobileThemeToggle.addEventListener('change', (e) => {
        const newTheme = e.target.checked ? 'dark' : 'light';
        this.applyTheme(newTheme);
      });
    }

    // システムテーマ変更の監視
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      // 保存されたテーマがない場合のみシステムテーマに従う
      if (!localStorage.getItem('theme')) {
        this.applyTheme(e.matches ? 'dark' : 'light');
      }
    });
  }
}

// グローバルインスタンス
const themeManager = new ThemeManager();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => themeManager.init());
} else {
  themeManager.init();
}
