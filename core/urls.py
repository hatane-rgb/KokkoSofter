from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('api/weather/', views.get_weather, name='get_weather'),
    path('api/online-users/', views.get_online_users, name='get_online_users'),
    path('api/notifications/', views.get_notifications, name='get_notifications'),
]
