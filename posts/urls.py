from django.urls import path
from . import views

app_name = 'posts'

urlpatterns = [
    path('create/', views.create_post, name='create'),
    path('like/<int:post_id>/', views.post_like_toggle, name='post_like_toggle'),
    path('delete/<int:post_id>/', views.delete_post, name='delete_post'),
    path('admin-posts/', views.admin_posts, name='admin_posts'),
]


