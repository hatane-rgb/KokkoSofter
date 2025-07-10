// 画像ビューワー機能

class ImageViewer {
  constructor() {
    this.viewer = null;
    this.viewerImage = null;
    this.closeBtn = null;
  }

  init() {
    this.viewer = document.getElementById('imageViewer');
    this.viewerImage = document.getElementById('viewerImage');
    this.closeBtn = this.viewer ? this.viewer.querySelector('.close-btn') : null;

    this.setupEventListeners();
    this.attachToImages();
  }

  setupEventListeners() {
    // 閉じるボタン
    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.close());
    }

    // 背景クリックで閉じる
    if (this.viewer) {
      this.viewer.addEventListener('click', (e) => {
        if (e.target === this.viewer) {
          this.close();
        }
      });
    }

    // ESCキーで閉じる
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.viewer && this.viewer.style.display === 'flex') {
        this.close();
      }
    });
  }

  attachToImages() {
    const images = document.querySelectorAll('img[data-clickable]:not([data-viewer-attached])');
    
    images.forEach(img => {
      img.addEventListener('click', () => this.open(img.src, img.alt));
      img.setAttribute('data-viewer-attached', 'true');
      img.style.cursor = 'pointer';
    });
  }

  open(src, alt) {
    if (this.viewer && this.viewerImage) {
      this.viewerImage.src = src;
      this.viewerImage.alt = alt || '拡大画像';
      this.viewer.style.display = 'flex';
      
      // フェードイン効果
      setTimeout(() => {
        this.viewer.style.opacity = '1';
      }, 10);
    }
  }

  close() {
    if (this.viewer) {
      this.viewer.style.opacity = '0';
      setTimeout(() => {
        this.viewer.style.display = 'none';
        if (this.viewerImage) {
          this.viewerImage.src = '';
        }
      }, 200);
    }
  }

  // 新しく追加された画像にも対応
  refresh() {
    this.attachToImages();
  }
}

// グローバルインスタンス
const imageViewer = new ImageViewer();

// グローバル関数として公開（後方互換性）
window.openImageViewer = (src, alt) => imageViewer.open(src, alt);
window.closeImageViewer = () => imageViewer.close();
window.refreshImageViewer = () => imageViewer.refresh();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => imageViewer.init());
} else {
  imageViewer.init();
}
