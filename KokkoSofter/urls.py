from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.static import serve
import re

urlpatterns = [
    path('', include('core.urls')),
    path('posts/', include('posts.urls')),
    path('accounts/', include('accounts.urls')),
    path('admin/', admin.site.urls),
]

# デバッグ環境ではDjangoの静的ファイル配信を使用
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0] if settings.STATICFILES_DIRS else None)
# 本番環境でも直接サーバーから配信できるようにする（Nginx障害時のバックアップとして）
else:
    urlpatterns += [
        path('media/<path:path>', serve, {'document_root': settings.MEDIA_ROOT}),
        path('static/<path:path>', serve, {'document_root': settings.STATIC_ROOT}),
    ]
