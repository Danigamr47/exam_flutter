import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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

      // Routes
      initialRoute: '/',
      routes: {
        '/':      (context) => const SplashScreen(),
        '/register': (context) => const AuthScreen(),
        '/auth':  (context) => const AuthScreen(),
        '/home':  (context) => const HomeScreen(),
      },
    );
  }
}