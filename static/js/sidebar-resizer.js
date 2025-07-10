// 右サイドバーリサイズ機能（右サイドバーのみ）

class SidebarResizer {
  constructor() {
    this.isResizing = false;
    this.currentHandle = null;
    this.currentSidebar = null;
    this.startX = 0;
    this.startWidth = 0;
    this.minWidth = 240;
    this.maxWidth = 600;
  }

  init() {
    // 右サイドバーのリサイズハンドルのみ対象
    const resizeHandles = document.querySelectorAll('.resize-handle[data-sidebar="right"]');
    
    resizeHandles.forEach(handle => {
      handle.addEventListener('mousedown', (e) => this.startResize(e));
    });

    // グローバルイベントリスナー
    document.addEventListener('mousemove', (e) => this.handleResize(e));
    document.addEventListener('mouseup', () => this.stopResize());
    
    // ダブルクリックでデフォルトサイズにリセット
    resizeHandles.forEach(handle => {
      handle.addEventListener('dblclick', (e) => this.resetSize(e));
    });

    // 保存されたサイズを復元
    this.loadSavedSizes();
  }

  startResize(e) {
    e.preventDefault();
    
    this.isResizing = true;
    this.currentHandle = e.target;
    this.currentSidebar = this.currentHandle.closest('.resizable-sidebar');
    
    if (!this.currentSidebar) return;

    this.startX = e.clientX;
    this.startWidth = parseInt(document.defaultView.getComputedStyle(this.currentSidebar).width, 10);

    // UI状態の更新
    document.body.classList.add('resize-active');
    this.currentSidebar.classList.add('resizing');
    this.currentHandle.classList.add('resizing');
  }

  handleResize(e) {
    if (!this.isResizing || !this.currentSidebar || !this.currentHandle) return;

    e.preventDefault();

    // 右サイドバー：左方向にドラッグで拡大
    const newWidth = this.startWidth - (e.clientX - this.startX);

    // 制限範囲内に収める
    const constrainedWidth = Math.max(this.minWidth, Math.min(this.maxWidth, newWidth));

    // 幅を適用
    this.currentSidebar.style.width = constrainedWidth + 'px';
  }

  stopResize() {
    if (!this.isResizing) return;

    this.isResizing = false;
    
    // UI状態をリセット
    document.body.classList.remove('resize-active');
    if (this.currentSidebar) {
      this.currentSidebar.classList.remove('resizing');
    }
    if (this.currentHandle) {
      this.currentHandle.classList.remove('resizing');
    }

    // サイズを保存
    this.saveSizes();

    this.currentHandle = null;
    this.currentSidebar = null;
  }

  resetSize(e) {
    const handle = e.target;
    const sidebar = handle.closest('.resizable-sidebar');

    if (!sidebar) return;

    // デフォルトサイズに戻す（右サイドバーのみ）
    sidebar.style.width = '320px';

    // サイズを保存
    this.saveSizes();

    // アニメーション効果
    sidebar.style.transition = 'width 0.3s ease';
    setTimeout(() => {
      sidebar.style.transition = '';
    }, 300);
  }

  saveSizes() {
    const rightSidebar = document.querySelector('aside[data-sidebar="right"]');

    const sizes = {};

    if (rightSidebar) {
      sizes.rightWidth = rightSidebar.style.width || '320px';
    }

    localStorage.setItem('kokkoSofter_sidebarSizes', JSON.stringify(sizes));
  }

  loadSavedSizes() {
    try {
      const saved = localStorage.getItem('kokkoSofter_sidebarSizes');
      if (!saved) return;

      const sizes = JSON.parse(saved);

      const rightSidebar = document.querySelector('aside[data-sidebar="right"]');

      if (rightSidebar && sizes.rightWidth) {
        rightSidebar.style.width = sizes.rightWidth;
      }
    } catch (error) {
      console.warn('Failed to load saved sidebar sizes:', error);
    }
  }
}

// グローバルインスタンス
const sidebarResizer = new SidebarResizer();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => sidebarResizer.init());
} else {
  sidebarResizer.init();
}
