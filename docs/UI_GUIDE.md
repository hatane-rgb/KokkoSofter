# 🎨 UI/UXガイド

KokkoSofterのデザインシステムとカスタマイズ方法について説明します。

## 🎭 デザインシステム

### 📋 コンポーネントライブラリ
- **DaisyUI**: メインUIコンポーネント
- **TailwindCSS**: ユーティリティクラス・カスタムスタイル
- **レスポンシブデザイン**: モバイルファースト設計

### 🎨 カラーパレット

#### テーマカラー
```css
/* Light Theme */
--primary: #3b82f6;      /* Blue 500 */
--secondary: #f59e0b;    /* Amber 500 */
--accent: #06b6d4;       /* Cyan 500 */
--neutral: #6b7280;      /* Gray 500 */

/* Dark Theme */
--primary: #60a5fa;      /* Blue 400 */
--secondary: #fbbf24;    /* Amber 400 */
--accent: #22d3ee;       /* Cyan 400 */
--neutral: #9ca3af;      /* Gray 400 */
```

#### セマンティックカラー
```css
--success: #10b981;      /* Emerald 500 */
--warning: #f59e0b;      /* Amber 500 */
--error: #ef4444;        /* Red 500 */
--info: #3b82f6;         /* Blue 500 */
```

### 📏 スペーシング・タイポグラフィ

#### スペーシングシステム
```css
/* TailwindCSS スペーシング (rem) */
xs: 0.25rem;    /* 4px */
sm: 0.5rem;     /* 8px */
md: 1rem;       /* 16px */
lg: 1.5rem;     /* 24px */
xl: 2rem;       /* 32px */
2xl: 2.5rem;    /* 40px */
3xl: 3rem;      /* 48px */
```

#### タイポグラフィ
```css
/* フォントサイズ */
text-xs: 0.75rem;       /* 12px */
text-sm: 0.875rem;      /* 14px */
text-base: 1rem;        /* 16px */
text-lg: 1.125rem;      /* 18px */
text-xl: 1.25rem;       /* 20px */
text-2xl: 1.5rem;       /* 24px */
text-3xl: 1.875rem;     /* 30px */
```

## 🔧 サイドバーリサイズ機能

### 🖱️ 操作方法

#### リサイズ操作
- **ドラッグ**: 右サイドバーの左端をドラッグしてリサイズ
- **ダブルクリック**: リサイズハンドルをダブルクリックでデフォルトサイズに戻す
- **自動保存**: 変更したサイズはブラウザに自動保存

#### サイズ制限
```javascript
minWidth: 240px;    // 最小幅
maxWidth: 600px;    // 最大幅
defaultWidth: 320px; // デフォルト幅
```

### 📱 レスポンシブ動作

#### モバイル（768px未満）
- サイドバーは画面外に隠れる
- ハンバーガーメニューで開閉
- 背景バックドロップ表示
- スワイプジェスチャー対応

#### タブレット（768px〜1024px）
- 左サイドバー: 固定表示
- 右サイドバー: 初期状態で非表示
- 切り替えボタンで表示/非表示

#### デスクトップ（1024px以上）
- 両サイドバー表示
- 右サイドバーリサイズ可能
- スティッキー（追従）動作

## 🌙 テーマシステム

### 🎨 テーマ切り替え

#### 自動切り替え
```javascript
// システムテーマの検出
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');

// ダークテーマ適用
document.documentElement.setAttribute('data-theme', 'dark');

// ライトテーマ適用  
document.documentElement.setAttribute('data-theme', 'light');
```

#### 手動切り替え
- ナビゲーション右上のテーマ切り替えボタン
- 設定はローカルストレージに保存
- ページ読み込み時に前回の設定を復元

### 🎭 カスタムテーマ作成

#### DaisyUIテーマカスタマイズ
```css
/* tailwind.config.js */
module.exports = {
  daisyui: {
    themes: [
      {
        'kokko-light': {
          'primary': '#3b82f6',
          'secondary': '#f59e0b',
          'accent': '#06b6d4',
          'neutral': '#6b7280',
          'base-100': '#ffffff',
          'base-200': '#f8fafc',
          'base-300': '#e2e8f0',
        },
        'kokko-dark': {
          'primary': '#60a5fa',
          'secondary': '#fbbf24',
          'accent': '#22d3ee',
          'neutral': '#9ca3af',
          'base-100': '#1f2937',
          'base-200': '#111827',
          'base-300': '#0f172a',
        }
      }
    ]
  }
}
```

## 🎯 アニメーション・トランジション

### ⚡ パフォーマンス重視

#### CSS Transform使用
```css
/* Good: GPUアクセラレーション */
.sidebar-enter {
  transform: translateX(-100%);
  transition: transform 0.3s ease;
}

.sidebar-enter-active {
  transform: translateX(0);
}
```

#### 軽量アニメーション
```css
/* ページ遷移 */
.page-transition {
  opacity: 0;
  transform: translateY(10px);
  transition: all 0.2s ease;
}

.page-transition.active {
  opacity: 1;
  transform: translateY(0);
}
```

### 🎬 インタラクションデザイン

#### ホバー効果
```css
.interactive-element {
  @apply transition-all duration-200 ease-in-out;
  @apply hover:scale-105 hover:shadow-lg;
  @apply active:scale-95;
}
```

#### フォーカス状態
```css
.focus-ring {
  @apply focus:ring-2 focus:ring-primary focus:ring-offset-2;
  @apply focus:outline-none;
}
```

## 📱 モバイル最適化

### 👆 タッチ操作

#### タッチターゲット
```css
/* 最小44px×44pxのタッチエリア確保 */
.touch-target {
  min-height: 44px;
  min-width: 44px;
  @apply flex items-center justify-center;
}
```

#### スワイプジェスチャー
```javascript
// サイドバー開閉のスワイプ
let startX = 0;
element.addEventListener('touchstart', (e) => {
  startX = e.touches[0].clientX;
});

element.addEventListener('touchend', (e) => {
  const endX = e.changedTouches[0].clientX;
  const diff = startX - endX;
  
  if (Math.abs(diff) > 50) {
    if (diff > 0) closeSidebar();
    else openSidebar();
  }
});
```

### 📺 画面サイズ対応

#### ブレークポイント
```css
/* TailwindCSS ブレークポイント */
sm: 640px;     /* スマートフォン横 */
md: 768px;     /* タブレット縦 */
lg: 1024px;    /* タブレット横・小型PC */
xl: 1280px;    /* デスクトップ */
2xl: 1536px;   /* 大型デスクトップ */
```

## 🛠️ カスタマイズ方法

### 🎨 スタイルカスタマイズ

#### カスタムCSSの追加場所
```
static/css/
├── main.css          # メインスタイル
├── components/       # コンポーネント別CSS
├── utilities/        # ユーティリティクラス
└── themes/          # カスタムテーマ
```

#### TailwindCSS設定
```javascript
// tailwind.config.js
module.exports = {
  content: [
    './templates/**/*.html',
    './static/js/**/*.js',
  ],
  theme: {
    extend: {
      colors: {
        'kokko-blue': '#3b82f6',
        'kokko-amber': '#f59e0b',
      },
      fontFamily: {
        'sans': ['Inter', 'system-ui', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      }
    }
  },
  plugins: [require('daisyui')]
}
```

### 🔧 JavaScriptカスタマイズ

#### ウィジェット追加
```javascript
// static/js/widgets/custom-widget.js
class CustomWidget {
  constructor(element) {
    this.element = element;
    this.init();
  }
  
  init() {
    // ウィジェットの初期化
  }
  
  render() {
    // ウィジェットの描画
  }
}

// グローバル登録
window.CustomWidget = CustomWidget;
```

#### イベントリスナー追加
```javascript
// base.htmlで読み込み
document.addEventListener('DOMContentLoaded', () => {
  // カスタム機能の初期化
  initCustomFeatures();
});
```

## 🎭 アクセシビリティ

### ♿ 基本対応

#### キーボードナビゲーション
```css
/* フォーカス表示 */
.focus-visible {
  @apply ring-2 ring-primary ring-offset-2;
}

/* スキップリンク */
.skip-link {
  @apply sr-only focus:not-sr-only;
  @apply focus:absolute focus:top-0 focus:left-0;
  @apply focus:z-50 focus:p-4 focus:bg-primary focus:text-white;
}
```

#### セマンティックHTML
```html
<!-- 適切なマークアップ -->
<nav aria-label="主要ナビゲーション">
  <ul>
    <li><a href="/" aria-current="page">ホーム</a></li>
    <li><a href="/posts/">投稿</a></li>
  </ul>
</nav>

<main>
  <h1>ページタイトル</h1>
  <section aria-labelledby="section-title">
    <h2 id="section-title">セクション</h2>
  </section>
</main>
```

### 🎨 カラーコントラスト

#### WCAG 2.1 AAレベル準拠
```css
/* 十分なコントラスト比確保 */
.text-primary-contrast {
  @apply text-gray-900 dark:text-gray-100;
}

.bg-primary-contrast {
  @apply bg-white dark:bg-gray-800;
}
```

## 🔍 デバッグ・開発ツール

### 🛠️ 開発時の便利ツール

#### CSS Grid/Flexbox可視化
```css
/* 開発時のみ有効 */
.debug-grid {
  @apply bg-red-100 border border-red-500;
}

.debug-flex {
  @apply bg-blue-100 border border-blue-500;
}
```

#### レスポンシブデバッグ
```html
<!-- 開発時に画面サイズ表示 -->
<div class="fixed top-0 right-0 z-50 p-2 bg-black text-white text-xs">
  <span class="sm:hidden">XS</span>
  <span class="hidden sm:inline md:hidden">SM</span>
  <span class="hidden md:inline lg:hidden">MD</span>
  <span class="hidden lg:inline xl:hidden">LG</span>
  <span class="hidden xl:inline 2xl:hidden">XL</span>
  <span class="hidden 2xl:inline">2XL</span>
</div>
```

### 📊 パフォーマンス監視

#### Core Web Vitals対応
```javascript
// パフォーマンス測定
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log(entry.name, entry.value);
  }
});

observer.observe({entryTypes: ['paint', 'layout-shift', 'largest-contentful-paint']});
```

## 📋 ベストプラクティス

### 🎯 推奨事項

#### CSS組織化
1. **ユーティリティファースト**: TailwindCSSのユーティリティクラスを優先
2. **コンポーネント分離**: 再利用可能なコンポーネントは別ファイル
3. **カスタムプロパティ**: CSS変数でテーマ対応
4. **モバイルファースト**: 小さい画面から設計

#### JavaScript設計
1. **モジュール化**: 機能ごとにファイル分割
2. **イベント委譲**: パフォーマンス最適化
3. **エラーハンドリング**: 適切なエラー処理
4. **プログレッシブエンハンスメント**: JavaScript無効でも基本機能は動作

#### ファイル構成
```
static/
├── css/
│   ├── main.css           # メインスタイル
│   ├── components/        # コンポーネント別
│   └── utilities/         # ユーティリティ
├── js/
│   ├── main.js           # メインスクリプト
│   ├── components/       # コンポーネント別
│   ├── utils/           # ユーティリティ関数
│   └── widgets/         # ウィジェット
└── images/
    ├── icons/           # アイコン
    └── backgrounds/     # 背景画像
```

---

このガイドを参考に、KokkoSofterのUI/UXをカスタマイズしてください。

**🎨 美しく使いやすいUIを目指して**
