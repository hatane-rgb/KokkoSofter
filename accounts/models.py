from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils import timezone

class UserProfile(models.Model):
    # ロール選択肢（簡素化）
    ROLE_CHOICES = [
        ('member', 'メンバー'),
        ('admin', '管理者'),
        ('owner', 'オーナー'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True, verbose_name='アバター画像')
    bio = models.TextField(max_length=500, blank=True, verbose_name='自己紹介')
    role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default='member', 
        verbose_name='役職'
    )
    last_seen = models.DateTimeField(default=timezone.now, verbose_name='最終アクセス時刻')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}のプロフィール"

    def get_avatar_url(self):
        """アバター画像のURLを取得（デフォルト画像を含む）"""
        if self.avatar:
            return self.avatar.url
        # デフォルトのアバター画像URLを返す
        return f"https://i.pravatar.cc/150?u={self.user.username}"
    
    def get_role_display_with_icon(self):
        """ロールをアイコン付きで表示"""
        role_icons = {
            'member': '👤 メンバー',
            'admin': '🛡️ 管理者',
            'owner': '👑 オーナー',
        }
        return role_icons.get(self.role, '👤 メンバー')
    
    def get_role_badge_class(self):
        """ロールに応じたバッジのCSSクラスを返す"""
        role_classes = {
            'member': 'badge-ghost',
            'admin': 'badge-warning',
            'owner': 'badge-error',
        }
        return role_classes.get(self.role, 'badge-ghost')
    
    def is_management_role(self):
        """管理職的なロールかどうかを判定"""
        return self.role in ['admin', 'owner']
    
    def can_manage_users(self):
        """ユーザー管理権限があるかどうかを判定"""
        return self.role in ['admin', 'owner']
    
    def is_online(self):
        """ユーザーがオンラインかどうかを判定（5分以内のアクティビティ）"""
        from datetime import timedelta
        return self.last_seen >= timezone.now() - timedelta(minutes=5)
    
    def update_last_seen(self):
        """最終アクセス時刻を現在時刻に更新"""
        self.last_seen = timezone.now()
        self.save(update_fields=['last_seen'])

# ユーザー作成時に自動でプロフィールを作成
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    if hasattr(instance, 'profile'):
        instance.profile.save()
    else:
        UserProfile.objects.create(user=instance)
