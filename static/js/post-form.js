// 投稿フォーム・画像アップロード機能

class PostForm {
  constructor() {
    this.contentTextarea = null;
    this.charCount = null;
    this.dropZone = null;
    this.dragOverlay = null;
    this.fileInput = null;
    this.imagePreview = null;
    this.previewImage = null;
    this.imageName = null;
    this.imageSize = null;
    this.removeImageBtn = null;
    this.postForm = null;
    this.postSubmitBtn = null;
  }

  init() {
    this.contentTextarea = document.getElementById('post-content');
    this.charCount = document.getElementById('post-char-count');
    this.dropZone = document.getElementById('post-drop-zone');
    this.dragOverlay = document.getElementById('post-drag-overlay');
    this.fileInput = document.getElementById('post-image-input');
    this.imagePreview = document.getElementById('image-preview');
    this.previewImage = document.getElementById('preview-image');
    this.imageName = document.getElementById('image-name');
    this.imageSize = document.getElementById('image-size');
    this.removeImageBtn = document.getElementById('remove-image');
    this.postSubmitBtn = document.getElementById('post-submit-btn');
    this.postForm = this.postSubmitBtn ? this.postSubmitBtn.closest('form') : null;

    this.setupEventListeners();
  }

  setupEventListeners() {
    // 文字数カウント
    if (this.contentTextarea && this.charCount) {
      this.contentTextarea.addEventListener('input', () => this.updateCharCount());
      this.updateCharCount(); // 初期化
    }

    // ドラッグ&ドロップ
    if (this.dropZone) {
      this.dropZone.addEventListener('dragover', (e) => this.handleDragOver(e));
      this.dropZone.addEventListener('dragleave', (e) => this.handleDragLeave(e));
      this.dropZone.addEventListener('drop', (e) => this.handleDrop(e));
    }

    // ファイル選択
    if (this.fileInput) {
      this.fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
    }

    // 画像削除
    if (this.removeImageBtn) {
      this.removeImageBtn.addEventListener('click', () => this.removeImage());
    }

    // フォーム送信
    if (this.postForm && this.postSubmitBtn) {
      this.postForm.addEventListener('submit', (e) => this.handleSubmit(e));
    }
  }

  updateCharCount() {
    const currentLength = this.contentTextarea.value.length;
    const maxLength = 1000;
    
    this.charCount.textContent = `${currentLength} / ${maxLength}文字`;
    
    if (currentLength > maxLength * 0.9) {
      this.charCount.classList.add('text-warning');
    } else {
      this.charCount.classList.remove('text-warning');
    }
    
    if (currentLength >= maxLength) {
      this.charCount.classList.add('text-error');
      this.charCount.classList.remove('text-warning');
    } else {
      this.charCount.classList.remove('text-error');
    }
  }

  handleDragOver(e) {
    e.preventDefault();
    e.stopPropagation();
    if (this.dragOverlay) {
      this.dragOverlay.style.opacity = '1';
      this.dragOverlay.style.pointerEvents = 'auto';
    }
  }

  handleDragLeave(e) {
    e.preventDefault();
    e.stopPropagation();
    
    // ドロップゾーンの外に出た場合のみオーバーレイを非表示
    if (!this.dropZone.contains(e.relatedTarget)) {
      if (this.dragOverlay) {
        this.dragOverlay.style.opacity = '0';
        this.dragOverlay.style.pointerEvents = 'none';
      }
    }
  }

  handleDrop(e) {
    e.preventDefault();
    e.stopPropagation();
    
    if (this.dragOverlay) {
      this.dragOverlay.style.opacity = '0';
      this.dragOverlay.style.pointerEvents = 'none';
    }
    
    const files = e.dataTransfer.files;
    if (files.length > 0) {
      this.processFile(files[0]);
    }
  }

  handleFileSelect(e) {
    const files = e.target.files;
    if (files.length > 0) {
      this.processFile(files[0]);
    }
  }

  processFile(file) {
    // ファイルタイプチェック
    if (!file.type.startsWith('image/')) {
      alert('画像ファイルのみアップロード可能です');
      return;
    }
    
    // ファイルサイズチェック（10MB）
    if (file.size > 10 * 1024 * 1024) {
      alert('ファイルサイズは10MB以下にしてください');
      return;
    }
    
    // プレビュー表示
    const reader = new FileReader();
    reader.onload = (e) => {
      if (this.previewImage) this.previewImage.src = e.target.result;
      if (this.imageName) this.imageName.textContent = file.name;
      if (this.imageSize) {
        const sizeInMB = (file.size / (1024 * 1024)).toFixed(2);
        this.imageSize.textContent = `${sizeInMB} MB`;
      }
      if (this.imagePreview) this.imagePreview.classList.remove('hidden');
    };
    reader.readAsDataURL(file);
  }

  removeImage() {
    if (this.fileInput) this.fileInput.value = '';
    if (this.imagePreview) this.imagePreview.classList.add('hidden');
    if (this.previewImage) this.previewImage.src = '';
    if (this.imageName) this.imageName.textContent = '';
    if (this.imageSize) this.imageSize.textContent = '';
  }

  handleSubmit(e) {
    e.preventDefault();
    
    // バリデーション
    const content = this.contentTextarea ? this.contentTextarea.value.trim() : '';
    if (!content) {
      alert('投稿内容を入力してください');
      return;
    }
    
    // ボタンを無効化
    if (this.postSubmitBtn) {
      this.postSubmitBtn.disabled = true;
      this.postSubmitBtn.innerHTML = `
        <span class="loading loading-spinner loading-sm mr-2"></span>
        投稿中...
      `;
    }
    
    // ページ遷移効果を表示
    if (window.showPageTransition) {
      window.showPageTransition();
    }
    
    // フォーム送信
    setTimeout(() => {
      this.postForm.submit();
    }, 0);
  }
}

// グローバルインスタンス
const postForm = new PostForm();

// 初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => postForm.init());
} else {
  postForm.init();
}
