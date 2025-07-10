from django.utils import timezone
from django.utils.deprecation import MiddlewareMixin

class UpdateLastSeenMiddleware(MiddlewareMixin):
    """
    ログインユーザーの最終アクセス時刻を更新するミドルウェア
    """
    
    def process_request(self, request):
        if request.user.is_authenticated:
            # プロフィールが存在する場合のみ更新
            if hasattr(request.user, 'profile'):
                request.user.profile.update_last_seen()
        return None
