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
        
        return Response({
            'message': 'User registered successfully.',
            'tokens': tokens,
            'user': {
                'id': user.id,
                'email': user.email,
                'username': 'Jenil Navapara', # Mock default name
                'level': 'Intermediate (B1)',
                'streak': 12,
                'xp': 450,
                'stats': {
                    'wordsLearned': 142,
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
    
    return Response({
        'message': 'Login successful.',
        'tokens': tokens,
        'user': {
            'id': user.id,
            'email': user.email,
            'username': 'Jenil Navapara', # Mock default name
            'level': 'Intermediate (B1)',
            'streak': 12,
            'xp': 450,
            'stats': {
                'wordsLearned': 142,
                'grammarLessonsCompleted': 18,
                'speakingSessionsCompleted': 7,
                'chatSessionsCompleted': 14,
            }
        }
    }, status=status.HTTP_200_OK)
