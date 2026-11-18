from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from vocabulary.models import UserProfile
from grammar.models import UserGrammarProgress

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

def get_or_create_user_profile(user):
    profile, _ = UserProfile.objects.get_or_create(user=user)
    return profile

def get_user_stats(user, profile):
    grammar_progress, _ = UserGrammarProgress.objects.get_or_create(user=user)
    words_learned = (
        profile.a1_pointer +
        profile.a2_pointer +
        profile.b1_pointer +
        profile.b2_pointer +
        profile.c1_pointer +
        profile.c2_pointer
    )
    return {
        'wordsLearned': words_learned,
        'grammarLessonsCompleted': grammar_progress.completed_topics,
        'speakingSessionsCompleted': profile.speaking_sessions,
        'chatSessionsCompleted': profile.chat_sessions,
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

    username = email

    if User.objects.filter(username=username).exists() or User.objects.filter(email=email).exists():
        return Response(
            {'error': 'A user with this email already exists.'},
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        user = User.objects.create_user(username=username, email=email, password=password)
        tokens = get_tokens_for_user(user)
        
        profile = UserProfile.objects.create(
            user=user,
            current_streak=0,
            longest_streak=0,
            points=0,
            speaking_sessions=0,
            chat_sessions=0,
            a1_pointer=0,
            a2_pointer=0,
            b1_pointer=0,
            b2_pointer=0,
            c1_pointer=0,
            c2_pointer=0
        )

        UserGrammarProgress.objects.create(user=user)

        stats_data = get_user_stats(user, profile)
        display_name = user.email.split('@')[0].capitalize()
        return Response({
            'message': 'User registered successfully.',
            'tokens': tokens,
            'user': {
                'id': user.id,
                'email': user.email,
                'username': display_name,
                'level': 'Beginner (A1)',
                'streak': profile.current_streak,
                'longest_streak': profile.longest_streak,
                'point': profile.points,
                'xp': profile.points,
                'stats': stats_data
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
    profile = get_or_create_user_profile(user)
    stats_data = get_user_stats(user, profile)

    display_name = user.email.split('@')[0].capitalize() if user.email else user.username
    return Response({
        'message': 'Login successful.',
        'tokens': tokens,
        'user': {
            'id': user.id,
            'email': user.email,
            'username': display_name,
            'level': 'Beginner (A1)',
            'streak': profile.current_streak,
            'longest_streak': profile.longest_streak,
            'point': profile.points,
            'xp': profile.points,
            'stats': stats_data
        }
    }, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def score_view(request):
    user = request.user
    profile = get_or_create_user_profile(user)
    
    try:
        point = int(request.data.get('point', 0))
    except (ValueError, TypeError):
        point = 0

    activity = request.data.get('activity')
    profile.points += point

    if activity == 'speaking':
        profile.speaking_sessions += 1
    elif activity == 'chat':
        profile.chat_sessions += 1

    profile.save()

    return Response({
        'point': profile.points,
        'speaking_sessions': profile.speaking_sessions,
        'chat_sessions': profile.chat_sessions,
        'message': 'Points saved successfully.'
    }, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def leaderboard_view(request):
    profiles = UserProfile.objects.select_related('user').order_by('-points', 'id')
    top_users = []
    current_user_data = None

    for rank, p in enumerate(profiles, start=1):
        username = p.user.email.split('@')[0].capitalize() if p.user.email else p.user.username
        entry = {
            'id': p.user.id,
            'username': username,
            'points': p.points,
            'rank': rank,
        }
        if len(top_users) < 10:
            top_users.append(entry)
        if p.user_id == request.user.id:
            current_user_data = entry

    if not current_user_data:
        current_user_data = {
            'id': request.user.id,
            'username': request.user.email.split('@')[0].capitalize() if request.user.email else request.user.username,
            'points': getattr(request.user, 'profile', None).points if hasattr(request.user, 'profile') else 0,
            'rank': len(top_users) + 1,
        }

    return Response({
        'top_users': top_users,
        'current_user': current_user_data,
        'total_users': profiles.count(),
    }, status=status.HTTP_200_OK)
