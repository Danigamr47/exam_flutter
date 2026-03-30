import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SnackType { success, error, warning, info }

class CustomSnackbar {

  // Méthode principale
  static void show(
    BuildContext context, {
    required String message,
    required SnackType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Couleurs et icônes selon le type
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case SnackType.success:
        backgroundColor = const Color(0xFF2ECC71);
        iconColor       = Colors.white;
        icon            = Icons.check_circle_rounded;
        defaultTitle    = 'Succès';
        break;
      case SnackType.error:
        backgroundColor = const Color(0xFFE74C3C);
        iconColor       = Colors.white;
        icon            = Icons.error_rounded;
        defaultTitle    = 'Erreur';
        break;
      case SnackType.warning:
        backgroundColor = const Color(0xFFF39C12);
        iconColor       = Colors.white;
        icon            = Icons.warning_rounded;
        defaultTitle    = 'Attention';
        break;
      case SnackType.info:
        backgroundColor = AppTheme.primaryColor;
        iconColor       = Colors.white;
        icon            = Icons.info_rounded;
        defaultTitle    = 'Information';
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),

                const SizedBox(width: 12),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? defaultTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton fermer
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // Raccourcis pratiques
  static void success(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: SnackType.success, title: title);
  }

  static void error(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: SnackType.error, title: title);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: SnackType.warning, title: title);
  }

  static void info(BuildContext context, String message, {String? title}) {
    show(context, message: message, type: SnackType.info, title: title);
  }
}