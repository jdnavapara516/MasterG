from django.contrib import admin
from .models import UserProfile, Vocabulary, VocabularySentence, DailyVocabularyProgress

admin.site.register(UserProfile)
admin.site.register(Vocabulary)
admin.site.register(VocabularySentence)
admin.site.register(DailyVocabularyProgress)
