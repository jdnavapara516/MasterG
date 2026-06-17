from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    current_streak = models.IntegerField(default=0)
    
    a1_pointer = models.IntegerField(default=0)
    a2_pointer = models.IntegerField(default=0)
    b1_pointer = models.IntegerField(default=0)
    b2_pointer = models.IntegerField(default=0)
    c1_pointer = models.IntegerField(default=0)
    c2_pointer = models.IntegerField(default=0)

    last_learning_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.user.username}'s Profile"

class Vocabulary(models.Model):
    LEVELS = (
        ('A1','A1'),
        ('A2','A2'),
        ('B1','B1'),
        ('B2','B2'),
        ('C1','C1'),
        ('C2','C2')
    )
    level = models.CharField(max_length=2, choices=LEVELS)
    word_no = models.IntegerField()
    word = models.CharField(max_length=100)
    pronunciation = models.CharField(max_length=100)
    gujarati_meaning = models.TextField()
    english_meaning = models.TextField()

    class Meta:
        unique_together = ('level', 'word_no')

    def __str__(self):
        return f"{self.level} - Word #{self.word_no}: {self.word}"

class VocabularySentence(models.Model):
    vocabulary = models.ForeignKey(
        Vocabulary,
        on_delete=models.CASCADE,
        related_name="sentences"
    )
    sentence = models.TextField()

    def __str__(self):
        return f"Sentence for {self.vocabulary.word}"

class DailyVocabularyProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.DateField()
    completed_words = models.IntegerField(default=0)

    class Meta:
        unique_together = ('user', 'date')

    def __str__(self):
        return f"{self.user.username} - {self.date} - Completed: {self.completed_words}"
