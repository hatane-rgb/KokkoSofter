// モバイルサイドバー制御
class MobileSidebarController {
  constructor() {
    this.sidebar = null;
    this.backdrop = null;
    this.menuBtn = null;
    this.closeBtn = null;
    this.isOpen = false;
  }

  init() {
    this.sidebar = document.getElementById('mobile-sidebar');
    this.backdrop = document.getElementById('sidebar-backdrop');
    this.menuBtn = document.getElementById('mobile-menu-btn');
    this.closeBtn = document.getElementById('mobile-close-btn');

    if (!this.sidebar) return;

    // 初期表示設定
    this.setupInitialDisplay();

    // イベントリスナー設定
    if (this.menuBtn) {
      this.menuBtn.addEventListener('click', () => this.toggleSidebar());
    }

    if (this.closeBtn) {
      this.closeBtn.addEventListener('click', () => this.closeSidebar());
    }

    if (this.backdrop) {
      this.backdrop.addEventListener('click', () => this.closeSidebar());
    }

    // ESCキーで閉じる
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        this.closeSidebar();
      }
    });

    // リサイズ時の処理
    window.addEventListener('resize', () => {
      if (window.innerWidth >= 769) {
        this.closeSidebar();
      }
      this.setupInitialDisplay();
    });
  }

  // 初期表示設定
  setupInitialDisplay() {
    if (window.innerWidth < 769) {
      // モバイル時は非表示
      if (this.sidebar) {
        this.sidebar.classList.remove('show');
      }
      if (this.backdrop) {
        this.backdrop.classList.remove('show');
      }
      document.body.classList.remove('sidebar-open');
    } else {
      // デスクトップ時は表示
      if (this.sidebar) {
        this.sidebar.classList.add('show');
      }
    }
  }

  toggleSidebar() {
    if (this.isOpen) {
      this.closeSidebar();
    } else {
      this.openSidebar();
    }
  }

  openSidebar() {
    if (!this.sidebar) return;
    
    this.isOpen = true;
    this.sidebar.classList.add('show');
    if (this.backdrop) {
      this.backdrop.classList.add('show');
    }
    document.body.classList.add('sidebar-open');
  }

  closeSidebar() {
    if (!this.sidebar) return;
    
    this.isOpen = false;
    this.sidebar.classList.remove('show');
    if (this.backdrop) {
      this.backdrop.classList.remove('show');
    }
    document.body.classList.remove('sidebar-open');
  }
}

// 右サイドバー機能（オンラインユーザー・通知）

class RightSidebarWidget {
  constructor() {
    this.onlineUsersListEl = null;
    this.onlineUsersLoadingEl = null;
    this.onlineUsersErrorEl = null;
    this.onlineUsersRetryBtn = null;
    
    this.notificationsListEl = null;
    this.notificationsLoadingEl = null;
    this.notificationsErrorEl = null;
    this.notificationsRetryBtn = null;
  }

  init() {
    // オンラインユーザー要素
    this.onlineUsersListEl = document.getElementById('online-users-list');
    this.onlineUsersLoadingEl = document.getElementById('online-users-loading');
    this.onlineUsersErrorEl = document.getElementById('online-users-error');
    this.onlineUsersRetryBtn = document.getElementById('online-users-retry');

    // 通知要素
    this.notificationsListEl = document.getElementById('notifications-list');
    this.notificationsLoadingEl = document.getElementById('notifications-loading');
    this.notificationsErrorEl = document.getElementById('notifications-error');
    this.notificationsRetryBtn = document.getElementById('notifications-retry');

    // イベントリスナー設定
    if (this.onlineUsersRetryBtn) {
      this.onlineUsersRetryBtn.addEventListener('click', () => {
        this.loadOnlineUsers();
      });
    }

    if (this.notificationsRetryBtn) {
      this.notificationsRetryBtn.addEventListener('click', () => {
        this.loadNotifications();
      });
    }

    // 初期データ読み込み
    this.loadOnlineUsers();
    this.loadNotifications();

    // 定期更新（1分ごと）
    setInterval(() => {
      this.loadOnlineUsers();
      this.loadNotifications();
    }, 60000);
  }

  async loadOnlineUsers() {
    if (!this.onlineUsersListEl) return;

    try {
      // ローディング状態にする
      this.showOnlineUsersLoading();

      const response = await fetch('/api/online-users/', {
        method: 'GET',
        headers: {
          'X-CSRFToken': getCookie('csrftoken'),
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) throw new Error('Network response was not ok');
      const result = await response.json();

      this.hideOnlineUsersLoading();

      if (result.success && result.users) {
        this.displayOnlineUsers(result.users);
      } else {
        this.showOnlineUsersError(result.error || 'オンラインユーザー情報を取得できませんでした');
      }
    } catch (error) {
      console.error('Failed to load online users:', error);
      this.hideOnlineUsersLoading();
      this.showOnlineUsersError('ネットワークエラーが発生しました');
    }
  }

  async loadNotifications() {
    if (!this.notificationsListEl) return;

    try {
      // ローディング状態にする
      this.showNotificationsLoading();

      const response = await fetch('/api/notifications/', {
        method: 'GET',
        headers: {
          'X-CSRFToken': getCookie('csrftoken'),
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) throw new Error('Network response was not ok');
      const result = await response.json();

      this.hideNotificationsLoading();

      if (result.success && result.notifications) {
        this.displayNotifications(result.notifications);
      } else {
        this.showNotificationsError(result.error || '通知情報を取得できませんでした');
      }
    } catch (error) {
      console.error('Failed to load notifications:', error);
      this.hideNotificationsLoading();
      this.showNotificationsError('ネットワークエラーが発生しました');
    }
  }

  showOnlineUsersLoading() {
    if (this.onlineUsersLoadingEl) this.onlineUsersLoadingEl.classList.remove('hidden');
    if (this.onlineUsersListEl) this.onlineUsersListEl.classList.add('hidden');
    if (this.onlineUsersErrorEl) this.onlineUsersErrorEl.classList.add('hidden');
  }

  hideOnlineUsersLoading() {
    if (this.onlineUsersLoadingEl) this.onlineUsersLoadingEl.classList.add('hidden');
  }

  showOnlineUsersError(message) {
    if (this.onlineUsersErrorEl) {
      this.onlineUsersErrorEl.classList.remove('hidden');
      const textNode = this.onlineUsersErrorEl.firstChild;
      if (textNode && textNode.nodeType === Node.TEXT_NODE) {
        textNode.textContent = message;
      }
    }
    if (this.onlineUsersListEl) this.onlineUsersListEl.classList.add('hidden');
  }

  displayOnlineUsers(users) {
    if (!this.onlineUsersListEl) return;

    if (!users || users.length === 0) {
      this.onlineUsersListEl.innerHTML = '<li class="text-center text-base-content/60 py-2">現在、オンラインユーザーはいません</li>';
    } else {
      const userItems = users.map(user => `
        <li class="flex items-center space-x-2">
          <span class="badge ${user.role_badge_class} badge-xs"></span>
          <img src="${user.avatar_url || '/static/images/default-avatar.png'}" 
               alt="${user.username}" 
               class="w-4 h-4 rounded-full">
          <span class="text-sm truncate">${user.username}</span>
          <span class="text-xs opacity-60">${user.role_icon || '👤'}</span>
        </li>
      `).join('');
      
      this.onlineUsersListEl.innerHTML = userItems;
    }

    this.onlineUsersListEl.classList.remove('hidden');
  }

  showNotificationsLoading() {
    if (this.notificationsLoadingEl) this.notificationsLoadingEl.classList.remove('hidden');
    if (this.notificationsListEl) this.notificationsListEl.classList.add('hidden');
    if (this.notificationsErrorEl) this.notificationsErrorEl.classList.add('hidden');
  }

  hideNotificationsLoading() {
    if (this.notificationsLoadingEl) this.notificationsLoadingEl.classList.add('hidden');
  }

  showNotificationsError(message) {
    if (this.notificationsErrorEl) {
      this.notificationsErrorEl.classList.remove('hidden');
      const textNode = this.notificationsErrorEl.firstChild;
      if (textNode && textNode.nodeType === Node.TEXT_NODE) {
        textNode.textContent = message;
      }
    }
    if (this.notificationsListEl) this.notificationsListEl.classList.add('hidden');
  }

  displayNotifications(notifications) {
    if (!this.notificationsListEl) return;

    if (!notifications || notifications.length === 0) {
      this.notificationsListEl.innerHTML = '<li class="text-center text-base-content/60 py-2">新しい通知はありません</li>';
    } else {
      const getBorderClass = (type) => {
        switch (type) {
          case 'like': return 'border-primary';
          case 'comment': return 'border-secondary';
          case 'user_joined': return 'border-info';
          case 'system': return 'border-warning';
          default: return 'border-base-content/20';
        }
      };

      const notificationItems = notifications.map(notification => `
        <li class="p-2 bg-base-100/50 rounded border-l-4 ${getBorderClass(notification.type)}">
          <div class="text-xs mb-1">${notification.message}</div>
          <div class="text-xs text-base-content/60">${notification.time_ago}</div>
        </li>
      `).join('');
      
      this.notificationsListEl.innerHTML = notificationItems;
    }

    this.notificationsListEl.classList.remove('hidden');
  }
}

// CSRFトークン取得（他のファイルにもあるが、独立性を保つため再定義）
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

// グローバルインスタンス
const rightSidebarWidget = new RightSidebarWidget();
const mobileSidebarController = new MobileSidebarController();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    rightSidebarWidget.init();
    mobileSidebarController.init();
  });
} else {
  rightSidebarWidget.init();
  mobileSidebarController.init();
}
