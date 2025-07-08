from django.db import models
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True, verbose_name='アバター画像')
    bio = models.TextField(max_length=500, blank=True, verbose_name='自己紹介')
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
