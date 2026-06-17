import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'theme/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell.dart';

void main() {
  runApp(
    AppStateProvider(
      notifier: AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return MaterialApp(
      title: 'MasterG - AI English Learning',
      debugShowCheckedModeBanner: false,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: appState.isLoggedIn ? const MainNavigationShell() : const LoginScreen(),
    );
  }
}
