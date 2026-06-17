from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from .models import UserVocabularyProgress

# Dictionary of vocabulary words for A1-C2 levels
VOCABULARY_DATABASE = {
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
            "gujarati_meaning": "जिज्ञासु / उत्सुक",
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
            "gujarati_meaning": "ઉદાર / દાતા",
            "english_meaning": "Showing a readiness to give more of something than is strictly necessary.",
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
            "gujarati_meaning": "व्यवहारिक",
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
            "gujarati_meaning": "कम करना",
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
            "gujarati_meaning": "अनावश्यक",
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

def get_or_create_progress(user, level):
    # Setup initial pointers
    defaults = {
        "A1": 45,
        "A2": 10,
        "B1": 5,
        "B2": 0,
        "C1": 0,
        "C2": 0
    }
    initial_pointer = defaults.get(level, 0)
    
    progress, created = UserVocabularyProgress.objects.get_or_create(
        user=user,
        level=level,
        defaults={'pointer': initial_pointer, 'today_progress': 0}
    )
    return progress

def get_user_from_request(request):
    if request.user and request.user.is_authenticated:
        return request.user
    # Fallback to first user in db (for easy local testing)
    user = User.objects.first()
    if not user:
        # Create a mock user
        user = User.objects.create_user(username='guest', email='guest@masterg.com', password='password123')
    return user

@api_view(['GET'])
@permission_classes([AllowAny])
def levels_view(request):
    user = get_user_from_request(request)
    levels = ["A1", "A2", "B1", "B2", "C1", "C2"]
    response_data = []

    for lvl in levels:
        prog = get_or_create_progress(user, lvl)
        response_data.append({
            "level": lvl,
            "learned_words": prog.pointer
        })

    return Response(response_data, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([AllowAny])
def current_word_view(request):
    user = get_user_from_request(request)
    level = request.query_params.get('level', 'A1')
    
    prog = get_or_create_progress(user, level)
    words = VOCABULARY_DATABASE.get(level, VOCABULARY_DATABASE["A1"])
    
    # Select word based on pointer (wrapping around list size)
    word_index = prog.pointer % len(words)
    word_info = words[word_index]

    # Calculate today progress (1 to 5)
    today_prog = (prog.today_progress % 5) + 1

    return Response({
        "word_no": prog.pointer + 1,
        "word": word_info["word"],
        "pronunciation": word_info["pronunciation"],
        "gujarati_meaning": word_info["gujarati_meaning"],
        "english_meaning": word_info["english_meaning"],
        "sentences": word_info["sentences"],
        "today_progress": today_prog,
        "today_target": 5,
        "streak": 12
    }, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def next_word_view(request):
    user = get_user_from_request(request)
    level = request.data.get('level', 'A1')

    prog = get_or_create_progress(user, level)
    
    # Increment pointer and today_progress
    prog.pointer += 1
    prog.today_progress += 1
    prog.save()

    words = VOCABULARY_DATABASE.get(level, VOCABULARY_DATABASE["A1"])
    word_index = prog.pointer % len(words)
    word_info = words[word_index]

    today_prog = (prog.today_progress % 5) + 1

    return Response({
        "word_no": prog.pointer + 1,
        "word": word_info["word"],
        "pronunciation": word_info["pronunciation"],
        "gujarati_meaning": word_info["gujarati_meaning"],
        "english_meaning": word_info["english_meaning"],
        "sentences": word_info["sentences"],
        "today_progress": today_prog,
        "today_target": 5,
        "streak": 12
    }, status=status.HTTP_200_OK)
