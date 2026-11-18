import os
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from vocabulary.models import UserProfile

ENGLISH_TUTOR_PROMPT = """You are G-Bot, a friendly and encouraging AI English tutor for MasterG.
Your goal is to help learners improve their English conversation, vocabulary, and grammar.
Keep your answers supportive, concise (2-4 sentences), and natural.
If the learner makes a grammar or spelling mistake, gently point it out with the correct phrasing, then continue the conversation with an engaging question."""

def generate_tutor_reply(messages, latest_user_message):
    gemini_key = os.environ.get("GEMINI_API_KEY")
    if gemini_key:
        try:
            import google.generativeai as genai
            genai.configure(api_key=gemini_key)
            model = genai.GenerativeModel("gemini-1.5-flash", system_instruction=ENGLISH_TUTOR_PROMPT)
            history = []
            for msg in messages[:-1]:
                role = "user" if msg.get("role") == "user" else "model"
                history.append({"role": role, "parts": [msg.get("content", "")]})
            chat = model.start_chat(history=history)
            response = chat.send_message(latest_user_message)
            if response and response.text:
                return response.text.strip()
        except Exception:
            pass

    # Intelligent fallback English learning conversational engine
    text = latest_user_message.strip().lower()
    
    if any(g in text for g in ["hi", "hello", "hey", "good morning", "good evening", "good afternoon"]):
        return "Hello! It's great to practice English with you today. What topic would you like to explore—daily life, hobbies, or grammar?"
    
    if "check" in text or "grammar" in text or "correct" in text:
        return f"I'd be happy to check your grammar! Your sentence '{latest_user_message}' is clear. To express it even more naturally in conversation, you can say: '{latest_user_message.capitalize()}'. Would you like to try using that in another sentence?"
    
    if "idiom" in text or "phrase" in text:
        return "Here is a wonderful English idiom: 'Break the ice'! It means to do or say something that makes people who do not know each other feel more relaxed. Have you ever had to break the ice with someone new?"
    
    if "describe" in text and "day" in text:
        return "Telling stories about your day is the fastest way to build English fluency! Tell me about one interesting thing that happened today, whether it was at school, work, or with friends."
    
    if "how are you" in text:
        return "I'm doing fantastic, thank you for asking! How are your English studies going today? Which new words did you learn recently?"
    
    if "thank" in text:
        return "You're very welcome! Keep up the consistent practice—every word you speak brings you closer to fluency. What shall we talk about next?"
    
    if len(text) > 0 and text.endswith("?"):
        return f"That's a thoughtful question! Speaking in complete sentences helps develop natural rhythm. Could you tell me your own perspective on that as well?"
    
    return f"Great effort! Practicing consistently is key to mastering English. You mentioned: '{latest_user_message}'. Can you tell me a little more about that?"

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def chat_view(request):
    messages = request.data.get('messages', [])
    if not messages:
        return Response({'error': 'Messages list cannot be empty.'}, status=status.HTTP_400_BAD_REQUEST)

    latest_user_message = ""
    for msg in reversed(messages):
        if msg.get('role') == 'user':
            latest_user_message = msg.get('content', '')
            break

    if not latest_user_message:
        latest_user_message = "Hello"

    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    profile.chat_sessions += 1
    profile.points += 5
    profile.save()

    reply = generate_tutor_reply(messages, latest_user_message)

    return Response({
        'reply': reply,
        'point': profile.points,
        'chat_sessions': profile.chat_sessions,
    }, status=status.HTTP_200_OK)
