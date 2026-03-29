import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Rediriger après 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      _redirect();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _redirect() {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isAuthenticated) {
      // Déjà connecté → Dashboard
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Pas connecté → Auth
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 70,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Nom
                        const Text(
                          'SENPAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Slogan
                        Text(
                          'Envoyez, recevez, payez facilement',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bas de l'écran
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}