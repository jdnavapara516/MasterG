from django.urls import path
from .views import levels_view, current_word_view, next_word_view

urlpatterns = [
    path('levels/', levels_view, name='vocabulary_levels'),
    path('current-word/', current_word_view, name='vocabulary_current_word'),
    path('next-word/', next_word_view, name='vocabulary_next_word'),
]
