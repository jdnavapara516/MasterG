import random
from datetime import timedelta
from django.contrib.auth.models import User
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .models import UserProfile, Vocabulary, VocabularySentence, DailyVocabularyProgress
from grammar.models import UserGrammarProgress

def get_user_profile(user):
    profile, _ = UserProfile.objects.get_or_create(
        user=user,
        defaults={
            'current_streak': 0,
            'longest_streak': 0,
            'points': 0,
            'speaking_sessions': 0,
            'chat_sessions': 0,
            'a1_pointer': 0,
            'a2_pointer': 0,
            'b1_pointer': 0,
            'b2_pointer': 0,
            'c1_pointer': 0,
            'c2_pointer': 0,
        }
    )
    return profile

def get_user_from_request(request):
    if request.user and request.user.is_authenticated:
        return request.user
    user = User.objects.first()
    if not user:
        user = User.objects.create_user(username='guest', email='guest@masterg.com', password='password123')
    return user

@api_view(['GET'])
@permission_classes([AllowAny])
def levels_view(request):
    user = get_user_from_request(request)
    profile = get_user_profile(user)

    return Response([
        {"level": "A1", "learned_words": profile.a1_pointer},
        {"level": "A2", "learned_words": profile.a2_pointer},
        {"level": "B1", "learned_words": profile.b1_pointer},
        {"level": "B2", "learned_words": profile.b2_pointer},
        {"level": "C1", "learned_words": profile.c1_pointer},
        {"level": "C2", "learned_words": profile.c2_pointer},
    ], status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([AllowAny])
def current_word_view(request):
    user = get_user_from_request(request)
    profile = get_user_profile(user)
    level = request.query_params.get('level', 'A1')

    pointer_map = {
        'A1': profile.a1_pointer,
        'A2': profile.a2_pointer,
        'B1': profile.b1_pointer,
        'B2': profile.b2_pointer,
        'C1': profile.c1_pointer,
        'C2': profile.c2_pointer,
    }
    pointer = pointer_map.get(level, 0)

    level_words = Vocabulary.objects.filter(level=level)
    if not level_words.exists():
        level_words = Vocabulary.objects.all()
    if not level_words.exists():
        return Response({"error": "No words found"}, status=status.HTTP_404_NOT_FOUND)

    word_index = pointer % level_words.count()
    word = level_words.all()[word_index]

    today = timezone.now().date()
    progress, _ = DailyVocabularyProgress.objects.get_or_create(user=user, date=today)

    return Response({
        "word_no": pointer + 1,
        "word": word.word,
        "pronunciation": word.pronunciation,
        "gujarati_meaning": word.gujarati_meaning,
        "english_meaning": word.english_meaning,
        "sentences": [s.sentence for s in word.sentences.all()],
        "today_progress": progress.completed_words,
        "today_target": 5,
        "streak": profile.current_streak
    }, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def next_word_view(request):
    user = get_user_from_request(request)
    profile = get_user_profile(user)
    level = request.data.get('level', 'A1')

    if level == 'A1':
        profile.a1_pointer += 1
        pointer = profile.a1_pointer
    elif level == 'A2':
        profile.a2_pointer += 1
        pointer = profile.a2_pointer
    elif level == 'B1':
        profile.b1_pointer += 1
        pointer = profile.b1_pointer
    elif level == 'B2':
        profile.b2_pointer += 1
        pointer = profile.b2_pointer
    elif level == 'C1':
        profile.c1_pointer += 1
        pointer = profile.c1_pointer
    elif level == 'C2':
        profile.c2_pointer += 1
        pointer = profile.c2_pointer
    else:
        pointer = 0

    profile.points += 15
    profile.save()

    today = timezone.now().date()
    progress, _ = DailyVocabularyProgress.objects.get_or_create(user=user, date=today)
    progress.completed_words += 1
    progress.save()

    just_completed = False
    if progress.completed_words >= 5:
        last_date = profile.last_learning_date
        if last_date != today:
            if last_date == today - timedelta(days=1):
                profile.current_streak += 1
            else:
                profile.current_streak = 1
            if profile.current_streak > profile.longest_streak:
                profile.longest_streak = profile.current_streak
            profile.last_learning_date = today
            profile.save()

        if progress.completed_words == 5:
            just_completed = True

    level_words = Vocabulary.objects.filter(level=level)
    if not level_words.exists():
        level_words = Vocabulary.objects.all()
    word_index = pointer % level_words.count()
    word = level_words.all()[word_index]

    return Response({
        "word_no": pointer + 1,
        "word": word.word,
        "pronunciation": word.pronunciation,
        "gujarati_meaning": word.gujarati_meaning,
        "english_meaning": word.english_meaning,
        "sentences": [s.sentence for s in word.sentences.all()],
        "today_progress": progress.completed_words,
        "today_target": 5,
        "streak": profile.current_streak,
        "daily_completed": just_completed
    }, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([AllowAny])
def user_profile_view(request):
    user = get_user_from_request(request)
    profile = get_user_profile(user)
    grammar_progress, _ = UserGrammarProgress.objects.get_or_create(user=user)
    
    today = timezone.now().date()
    progress, _ = DailyVocabularyProgress.objects.get_or_create(user=user, date=today)

    words_learned = (
        profile.a1_pointer +
        profile.a2_pointer +
        profile.b1_pointer +
        profile.b2_pointer +
        profile.c1_pointer +
        profile.c2_pointer
    )

    display_name = user.email.split('@')[0].capitalize() if user.email else user.username
    return Response({
        "username": display_name,
        "level": "Beginner (A1)",
        "streak": profile.current_streak,
        "longest_streak": profile.longest_streak,
        "today_progress": progress.completed_words,
        "point": profile.points,
        "words_learned": words_learned,
        "grammar_lessons_completed": grammar_progress.completed_topics,
        "speaking_sessions": profile.speaking_sessions,
        "chat_sessions": profile.chat_sessions,
    }, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def rapid_fire_words_view(request):
    level = request.data.get('level')
    query = Vocabulary.objects.filter(level=level) if level else Vocabulary.objects.all()
    all_words = list(query)
    
    if len(all_words) < 10:
        all_words = list(Vocabulary.objects.all())

    selected = random.sample(all_words, min(10, len(all_words)))
    while len(selected) < 10 and selected:
        selected.append(random.choice(all_words))

    words_payload = [
        {
            'english': w.word,
            'gujarati': w.gujarati_meaning,
            'pronunciation': w.pronunciation,
        }
        for w in selected[:10]
    ]

    return Response({'words': words_payload}, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def revision_view(request):
    user = request.user
    profile = get_user_profile(user)
    grammar_progress, _ = UserGrammarProgress.objects.get_or_create(user=user)

    words_learned = (
        profile.a1_pointer +
        profile.a2_pointer +
        profile.b1_pointer +
        profile.b2_pointer +
        profile.c1_pointer +
        profile.c2_pointer
    )

    count = int(request.query_params.get('count', 20))
    all_words = list(Vocabulary.objects.all().prefetch_related('sentences'))
    selected = random.sample(all_words, min(count, len(all_words))) if all_words else []

    words_payload = [
        {
            'word': w.word,
            'pronunciation': w.pronunciation,
            'gujarati_meaning': w.gujarati_meaning,
            'english_meaning': w.english_meaning,
            'level': w.level,
            'sentences': [s.sentence for s in w.sentences.all()],
        }
        for w in selected
    ]

    return Response({
        'total_words_learned': words_learned,
        'completed_grammar_topics': grammar_progress.completed_topic_ids or [],
        'words': words_payload,
    }, status=status.HTTP_200_OK)
