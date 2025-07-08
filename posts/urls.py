from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_post, name='create'),
    path('like/<int:post_id>/', views.post_like_toggle, name='post_like_toggle'),
]

app_name = 'posts'


