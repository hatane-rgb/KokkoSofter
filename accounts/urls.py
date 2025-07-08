from .views import CustomLoginView, profile_settings
from django.urls import path
from django.contrib.auth.views import LogoutView

app_name = 'accounts'

urlpatterns = [
    # 既存のlogin等のURL
    path('login/', CustomLoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(next_page='/'), name='logout'),  # ←追加
    path('settings/', profile_settings, name='profile_settings'),
]
