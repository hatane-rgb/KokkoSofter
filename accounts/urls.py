from .views import (
    CustomLoginView, profile_settings, admin_dashboard, admin_users,
    admin_create_user, admin_toggle_user_status, admin_toggle_staff_status,
    admin_edit_user, admin_delete_user
)
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
    path('admin-create-user/', admin_create_user, name='admin_create_user'),
    path('admin-edit-user/<int:user_id>/', admin_edit_user, name='admin_edit_user'),
    path('admin-delete-user/<int:user_id>/', admin_delete_user, name='admin_delete_user'),
    path('admin-toggle-user/<int:user_id>/', admin_toggle_user_status, name='admin_toggle_user_status'),
    path('admin-toggle-staff/<int:user_id>/', admin_toggle_staff_status, name='admin_toggle_staff_status'),
]
