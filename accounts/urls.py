from .views import CustomLoginView, profile_settings, admin_dashboard, admin_users
from django.urls import path
from django.contrib.auth.views import LogoutView

app_name = 'accounts'

urlpatterns = [
    # 既存のlogin等のURL
    path('login/', CustomLoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(next_page='/'), name='logout'),  # ←追加
    path('settings/', profile_settings, name='profile_settings'),
    
    # 管理者専用URL
    path('admin-dashboard/', admin_dashboard, name='admin_dashboard'),
    path('admin-users/', admin_users, name='admin_users'),
]
