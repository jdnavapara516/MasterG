from django.db import models
from django.contrib.auth.models import User

class UserVocabularyProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    level = models.CharField(max_length=4) # A1, A2, B1, B2, C1, C2
    pointer = models.IntegerField(default=0)
    today_progress = models.IntegerField(default=0) # 0 to 5

    class Meta:
        unique_together = ('user', 'level')

    def __str__(self):
        return f"{self.user.username} - {self.level} - {self.pointer}"
