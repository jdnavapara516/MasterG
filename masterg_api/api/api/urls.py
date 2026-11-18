from django.contrib import admin
from django.urls import path, include
from .chat import chat_view

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('authentication.urls')),
    path('api/vocabulary/', include('vocabulary.urls')),
    path('api/grammar/', include('grammar.urls')),
    path('api/chat/', chat_view, name='api_chat'),
]
