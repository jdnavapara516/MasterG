import 'package:flutter_test/flutter_test.dart';
import 'package:masterg_app/main.dart';
import 'package:masterg_app/state/app_state.dart';
import 'package:masterg_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('App renders LoginScreen when unauthenticated', (WidgetTester tester) async {
    final appState = AppState();
    addTearDown(appState.dispose);

    await tester.pumpWidget(
      AppStateProvider(
        notifier: appState,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('MasterG'), findsOneWidget);
  });

  testWidgets('Theme toggle updates brightness in state', (WidgetTester tester) async {
    final appState = AppState();
    addTearDown(appState.dispose);

    expect(appState.isDarkMode, isFalse);

    appState.toggleTheme();
    expect(appState.isDarkMode, isTrue);

    appState.toggleTheme();
    expect(appState.isDarkMode, isFalse);
  });
}
