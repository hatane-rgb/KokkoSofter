// KokkoSofter メインJavaScript

// ページ遷移・ローディング機能
class PageTransition {
  constructor() {
    this.transitionOverlay = null;
    this.pageContent = null;
    this.isInitialized = false;
  }

  init() {
    if (this.isInitialized) return;
    
    console.log('Initializing page transitions...');
    
    this.transitionOverlay = document.getElementById('transition-overlay');
    this.pageContent = document.getElementById('page-content');
    
    if (!this.transitionOverlay) {
      console.error('Transition overlay not found');
      return;
    }
    
    this.attachTransitionToLinks();
    this.enableLinkPrefetch();
    this.setupEventListeners();
    
    this.isInitialized = true;
    console.log('Page transitions initialized successfully');
  }

  attachTransitionToLinks() {
    const links = document.querySelectorAll('a.transition-link:not([data-transition-attached])');
    
    links.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const href = link.getAttribute('href');
        
        if (href && href !== '#' && href !== window.location.pathname) {
          console.log('Navigating to:', href);
          this.show();
          
          // 即座にページ遷移（遅延削除）
          setTimeout(() => {
            window.location.href = href;
          }, 0);
        }
      });
      
      link.setAttribute('data-transition-attached', 'true');
    });
  }

  enableLinkPrefetch() {
    const links = document.querySelectorAll('a.transition-link:not([data-prefetch-attached])');
    
    links.forEach(link => {
      link.addEventListener('mouseenter', () => {
        const href = link.getAttribute('href');
        if (href && href !== '#' && !document.querySelector(`link[href="${href}"][data-prefetch]`)) {
          const prefetchLink = document.createElement('link');
          prefetchLink.rel = 'prefetch';
          prefetchLink.href = href;
          prefetchLink.setAttribute('data-prefetch', 'true');
          document.head.appendChild(prefetchLink);
          
          console.log('Prefetching:', href);
        }
      });
      link.setAttribute('data-prefetch-attached', 'true');
    });
  }

  show() {
    console.log('Showing transition overlay...');
    if (this.transitionOverlay && this.pageContent) {
      this.transitionOverlay.style.display = 'flex';
      this.transitionOverlay.classList.add('active');
      this.pageContent.classList.add('transitioning');
      
      // 800ms後に自動的に非表示
      setTimeout(() => {
        if (this.transitionOverlay.classList.contains('active')) {
          this.transitionOverlay.classList.add('auto-hide');
          setTimeout(() => {
            this.hide();
          }, 800);
        }
      }, 200);
    }
  }

  hide() {
    console.log('Hiding transition overlay...');
    if (this.transitionOverlay && this.pageContent) {
      this.transitionOverlay.classList.remove('active', 'auto-hide');
      this.pageContent.classList.remove('transitioning');
      setTimeout(() => {
        this.transitionOverlay.style.display = 'none';
      }, 120);
    }
  }

  setupEventListeners() {
    // ページ読み込み完了時
    const finalizePageLoad = () => {
      console.log('Finalizing page load...');
      this.hide();
      this.attachTransitionToLinks();
      
      // ページを確実に表示
      document.documentElement.style.visibility = 'visible';
      document.documentElement.style.opacity = '1';
      document.body.style.visibility = 'visible';
      document.body.style.opacity = '1';
    };

    window.addEventListener('load', finalizePageLoad);
    document.addEventListener('DOMContentLoaded', finalizePageLoad);
    
    // ブラウザバック・フォワード時
    window.addEventListener('pageshow', (e) => {
      console.log('Page show event, persisted:', e.persisted);
      finalizePageLoad();
      
      if (e.persisted) {
        document.documentElement.style.visibility = 'visible';
        document.documentElement.style.opacity = '1';
        document.body.style.visibility = 'visible';
        document.body.style.opacity = '1';
      }
    });

    // 動的に追加されたリンクへの対応
    let observerTimeout;
    const observer = new MutationObserver((mutations) => {
      clearTimeout(observerTimeout);
      observerTimeout = setTimeout(() => {
        let shouldUpdate = false;
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
            for (let node of mutation.addedNodes) {
              if (node.nodeType === 1 && (node.querySelector && node.querySelector('a.transition-link'))) {
                shouldUpdate = true;
                break;
              }
            }
          }
        });
        
        if (shouldUpdate) {
          this.attachTransitionToLinks();
          this.enableLinkPrefetch();
        }
      }, 50);
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // デバッグ用
  test() {
    console.log('Manual transition test');
    this.show();
    setTimeout(() => this.hide(), 1000);
  }
}

// グローバルインスタンス
const pageTransition = new PageTransition();

// グローバル関数として公開（後方互換性）
window.showPageTransition = () => pageTransition.show();
window.hidePageTransition = () => pageTransition.hide();
window.testTransition = () => pageTransition.test();

// ユーティリティ関数
function getCookie(name) {
  let cookieValue = null;
  if (document.cookie && document.cookie !== '') {
    const cookies = document.cookie.split(';');
    for (let cookie of cookies) {
      cookie = cookie.trim();
      if (cookie.startsWith(name + '=')) {
        cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
        break;
      }
    }
  }
  return cookieValue;
}

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => pageTransition.init());
} else {
  pageTransition.init();
}
