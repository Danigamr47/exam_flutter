import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clé globale pour le formulaire (Exigence : Formulaire avec validation) [cite: 28]
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer les données saisies 
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cniController = TextEditingController();
  
  final _pinController = TextEditingController();
  

  @override
  void dispose() {
    // Libération de la mémoire quand l'écran est fermé
    _nameController.dispose();
    _phoneController.dispose();
    _cniController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou Icône de l'application
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 100,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Créer votre compte SENPAY",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Simple, rapide et sécurisé",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Champ Nom (KYC) 
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Prénom et Nom",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Ce champ est requis";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Champ Téléphone 
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Numéro de téléphone",
                    prefixIcon: Icon(Icons.phone_android),
                    prefixText: "+221 ",
                  ),
                  validator: (value) {
                    if (value == null || value.length < 9) return "Numéro invalide";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Champ CNI (KYC simplifié) 
                TextFormField(
                  controller: _cniController,
                  decoration: const InputDecoration(
                    hintText: "Numéro de la pièce d'identité",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Obligatoire pour le KYC";
                    return null;
                  },
                ),
                // PIN
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    hintText: "Choisissez votre code PIN (4 chiffres)",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v!.length != 4 ? "Le PIN doit avoir 4 chiffres" : null,
                ),
                const SizedBox(height: 40),

                // Bouton d'inscription
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validation du formulaire avant action 
                      if (_formKey.currentState!.validate()) {
                        // Accès au Provider pour enregistrer l'utilisateur
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        
                        auth.register(
                          _nameController.text,
                          _phoneController.text,
                          _cniController.text,
                          _pinController.text,
                        );

                        // Note : La navigation vers HomeScreen se fera 
                        // automatiquement grâce au Consumer dans main.dart
                      }
                    },
                    child: const Text(
                      "S'INSCRIRE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}