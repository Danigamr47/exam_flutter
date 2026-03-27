import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart'; // Nous allons le créer

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // C'est ici qu'on "donne" l'accès
      ],
      child: const SenPayApp(),
    ),
  );
}

class SenPayApp extends StatelessWidget {
  const SenPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return MaterialApp(
      title: 'SENPAY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: auth.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // Logique de redirection automatique
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated 
              ? const HomeScreen() 
              : const AuthScreen();
        },
      ),
    );
  }
}