from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import login_view, register_view, score_view, leaderboard_view

urlpatterns = [
    path('login/', login_view, name='api_login'),
    path('register/', register_view, name='api_register'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('score/', score_view, name='api_score'),
    path('leaderboard/', leaderboard_view, name='api_leaderboard'),
]
