from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import date, timedelta
from .models import UserProfile, Vocabulary, VocabularySentence, DailyVocabularyProgress

# Rich seed data for Vocabulary levels
SEED_VOCABULARY = {
    "A1": [
        {
            "word": "Ambitious",
            "pronunciation": "am-bi-shus",
            "gujarati_meaning": "મહત્વાકાંક્ષી",
            "english_meaning": "Having a strong desire to succeed.",
            "sentences": [
                "She is ambitious and wants to become a doctor.",
                "My friend is ambitious about his career.",
                "Ambitious students study every day.",
                "He is ambitious and hardworking.",
                "She has ambitious goals for the future."
            ]
        },
        {
            "word": "Curious",
            "pronunciation": "kyoo-ree-uhs",
            "gujarati_meaning": "જિજ્ઞાસુ / ઉત્સુક",
            "english_meaning": "Eager to know or learn something.",
            "sentences": [
                "The boy was curious about how the machine works.",
                "She gave me a curious look.",
                "Curious kids ask a lot of questions.",
                "I am curious to see what happens next.",
                "Scientists are curious by nature."
            ]
        },
        {
            "word": "Delightful",
            "pronunciation": "dih-lahyt-fuhl",
            "gujarati_meaning": "આનંદદાયક",
            "english_meaning": "Causing great pleasure or delight.",
            "sentences": [
                "We had a delightful evening with our friends.",
                "This garden is a delightful place to read.",
                "The cake was absolutely delightful.",
                "It was delightful to meet you.",
                "She told a delightful story."
            ]
        },
        {
            "word": "Efficient",
            "pronunciation": "ih-fish-uhnt",
            "gujarati_meaning": "કાર્યક્ષમ",
            "english_meaning": "Achieving maximum productivity with minimum wasted effort.",
            "sentences": [
                "An efficient assistant saves a lot of time.",
                "We need to find a more efficient way to work.",
                "The new heating system is very efficient.",
                "He is highly efficient at handling complaints.",
                "Fluorescent lamps are very efficient."
            ]
        },
        {
            "word": "Generous",
            "pronunciation": "jen-er-uhs",
            "gujarati_meaning": "ઉદાર",
            "english_meaning": "Showing a readiness to give more of something than is necessary.",
            "sentences": [
                "It was very generous of you to pay for dinner.",
                "She is always generous with her praise.",
                "He made a generous donation to the charity.",
                "A generous portion of soup was served.",
                "They are generous hosts."
            ]
        }
    ],
    "A2": [
        {
            "word": "Adventure",
            "pronunciation": "ad-ven-cher",
            "gujarati_meaning": "સાહસ",
            "english_meaning": "An unusual and exciting or daring experience.",
            "sentences": [
                "Traveling in the mountains was a great adventure.",
                "They went on an adventure into the deep forest.",
                "I love reading stories about wilderness adventures.",
                "She is looking for a new job adventure.",
                "Adventure travel is growing in popularity."
            ]
        },
        {
            "word": "Comfortable",
            "pronunciation": "kuhm-fter-buhl",
            "gujarati_meaning": "આરામદાયક",
            "english_meaning": "Providing physical ease and relaxation.",
            "sentences": [
                "This sofa is very comfortable.",
                "Are you comfortable in that chair?",
                "We had a comfortable flight.",
                "He lives a comfortable life in the suburbs.",
                "Wear comfortable shoes for walking."
            ]
        }
    ],
    "B1": [
        {
            "word": "Eloquent",
            "pronunciation": "el-uh-kwuhnt",
            "gujarati_meaning": "સુવક્તા",
            "english_meaning": "Fluent or persuasive in speaking or writing.",
            "sentences": [
                "She gave an eloquent speech at the ceremony.",
                "His writing style is highly eloquent.",
                "An eloquent argument convinced the jury.",
                "He was eloquent in his defense of the environment.",
                "Her eyes were more eloquent than words."
            ]
        }
    ],
    "B2": [
        {
            "word": "Pragmatic",
            "pronunciation": "prag-mat-ik",
            "gujarati_meaning": "વ્યવહારિક",
            "english_meaning": "Dealing with things realistically based on practical considerations.",
            "sentences": [
                "We need a pragmatic solution to this traffic issue.",
                "He took a pragmatic approach to the dispute.",
                "She is very pragmatic about career choices.",
                "Let's be pragmatic and look at the cost.",
                "Pragmatic business decisions help save money."
            ]
        }
    ],
    "C1": [
        {
            "word": "Mitigate",
            "pronunciation": "mit-i-geyt",
            "gujarati_meaning": "નરમ કરવું / ઓછું કરવું",
            "english_meaning": "Make something bad less severe, serious, or painful.",
            "sentences": [
                "The government took steps to mitigate the flood damage.",
                "Planting trees helps mitigate climate impact.",
                "We can mitigate the risk by testing early.",
                "Medicine was given to mitigate the pain.",
                "Actions were taken to mitigate loss of data."
            ]
        }
    ],
    "C2": [
        {
            "word": "Superfluous",
            "pronunciation": "soo-pur-floo-uhs",
            "gujarati_meaning": "વધારાનું / બિનજરૂરી",
            "english_meaning": "Unnecessary, especially through being more than enough.",
            "sentences": [
                "Please delete any superfluous words in your essay.",
                "Superfluous packaging is bad for the environment.",
                "We have all the data we need; more is superfluous.",
                "He avoided superfluous details in the report.",
                "Superfluous spendings should be cut down."
            ]
        }
    ]
}

def seed_vocabulary_database():
    if Vocabulary.objects.count() == 0:
        for lvl, words in SEED_VOCABULARY.items():
            for i, w in enumerate(words):
                vocab = Vocabulary.objects.create(
                    level=lvl,
                    word_no=i + 1,
                    word=w["word"],
                    pronunciation=w["pronunciation"],
                    gujarati_meaning=w["gujarati_meaning"],
                    english_meaning=w["english_meaning"]
                )
                for sent in w["sentences"]:
                    VocabularySentence.objects.create(
                        vocabulary=vocab,
                        sentence=sent
                    )

def get_user_profile(user):
    profile, created = UserProfile.objects.get_or_create(
        user=user,
        defaults={
            'current_streak': 12,
            'a1_pointer': 45,
            'a2_pointer': 12,
            'b1_pointer': 0,
            'b2_pointer': 0,
            'c1_pointer': 0,
            'c2_pointer': 0,
            'last_learning_date': timezone.now().date() - timedelta(days=1)
        }
    )
    return profile

def get_user_from_request(request):
    if request.user and request.user.is_authenticated:
        return request.user
    # Fallback to first user for easy local testing
    user = User.objects.first()
    if not user:
        user = User.objects.create_user(username='guest', email='guest@masterg.com', password='password123')
    return user

@api_view(['GET'])
@permission_classes([AllowAny])
def levels_view(request):
    seed_vocabulary_database()
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
    seed_vocabulary_database()
    user = get_user_from_request(request)
    profile = get_user_profile(user)
    level = request.query_params.get('level', 'A1')

    # Get pointer for selected level
    pointer = 0
    if level == 'A1':
        pointer = profile.a1_pointer
    elif level == 'A2':
        pointer = profile.a2_pointer
    elif level == 'B1':
        pointer = profile.b1_pointer
    elif level == 'B2':
        pointer = profile.b2_pointer
    elif level == 'C1':
        pointer = profile.c1_pointer
    elif level == 'C2':
        pointer = profile.c2_pointer

    # Fetch word matching level and wrapped word_no
    level_words = Vocabulary.objects.filter(level=level)
    if not level_words.exists():
        return Response({"error": "No words found for this level"}, status=status.HTTP_404_NOT_FOUND)

    word_index = pointer % level_words.count()
    word = level_words.all()[word_index]

    # Get daily progress
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
    seed_vocabulary_database()
    user = get_user_from_request(request)
    profile = get_user_profile(user)
    level = request.data.get('level', 'A1')

    # Increment pointer
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

    profile.save()

    # Update Daily Progress
    today = timezone.now().date()
    progress, _ = DailyVocabularyProgress.objects.get_or_create(user=user, date=today)
    progress.completed_words += 1
    progress.save()

    # Check daily target completed (5 words)
    if progress.completed_words >= 5:
        # Streak Logic
        last_date = profile.last_learning_date
        
        if last_date == today:
            # Already completed today, no update
            pass
        elif last_date == today - timedelta(days=1):
            # Completed yesterday, increment streak
            profile.current_streak += 1
        else:
            # Missed a day or first learning
            profile.current_streak = 1

        profile.last_learning_date = today
        profile.save()

        return Response({
            "daily_completed": True,
            "streak": profile.current_streak
        }, status=status.HTTP_200_OK)

    # Return next word details
    level_words = Vocabulary.objects.filter(level=level)
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
        "streak": profile.current_streak
    }, status=status.HTTP_200_OK)
