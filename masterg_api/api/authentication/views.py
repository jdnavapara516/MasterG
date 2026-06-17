from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Please provide both email and password.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    # Use email as username since we don't have separate username field
    username = email

    if User.objects.filter(username=username).exists() or User.objects.filter(email=email).exists():
        return Response(
            {'error': 'A user with this email already exists.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.create_user(username=username, email=email, password=password)
        tokens = get_tokens_for_user(user)
        
        # Create UserProfile explicitly for the new user starting at 0 progress
        from vocabulary.models import UserProfile
        profile = UserProfile.objects.create(
            user=user,
            current_streak=0,
            a1_pointer=0,
            a2_pointer=0,
            b1_pointer=0,
            b2_pointer=0,
            c1_pointer=0,
            c2_pointer=0
        )
        words_learned = 0

        display_name = user.email.split('@')[0].capitalize()
        return Response({
            'message': 'User registered successfully.',
            'tokens': tokens,
            'user': {
                'id': user.id,
                'email': user.email,
                'username': display_name,
                'level': 'Intermediate (B1)',
                'streak': profile.current_streak,
                'xp': 450,
                'stats': {
                    'wordsLearned': words_learned,
                    'grammarLessonsCompleted': 18,
                    'speakingSessionsCompleted': 7,
                    'chatSessionsCompleted': 14,
                }
            }
        }, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response(
            {'error': 'Please provide both email and password.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    user = authenticate(username=email, password=password)

    if user is None:
        return Response(
            {'error': 'Invalid email or password.'},
            status=status.HTTP_401_UNAUTHORIZED
        )

    tokens = get_tokens_for_user(user)
    
    # Get profile to fetch real streak and words learned
    from vocabulary.views import get_user_profile
    profile = get_user_profile(user)
    words_learned = (
        profile.a1_pointer +
        profile.a2_pointer +
        profile.b1_pointer +
        profile.b2_pointer +
        profile.c1_pointer +
        profile.c2_pointer
    )

    display_name = user.email.split('@')[0].capitalize()
    return Response({
        'message': 'Login successful.',
        'tokens': tokens,
        'user': {
            'id': user.id,
            'email': user.email,
            'username': display_name,
            'level': 'Intermediate (B1)',
            'streak': profile.current_streak,
            'xp': 450,
            'stats': {
                'wordsLearned': words_learned,
                'grammarLessonsCompleted': 18,
                'speakingSessionsCompleted': 7,
                'chatSessionsCompleted': 14,
            }
        }
    }, status=status.HTTP_200_OK)
