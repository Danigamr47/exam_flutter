import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  bool _isPinVisible = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si aucun compte n'existe, on affiche l'inscription par défaut
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.hasAccount) {
        setState(() => _isLoginMode = false);
      }
    });
  }
  

  @override
  void dispose() {
    // Libération de la mémoire quand l'écran est fermé
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Petit délai pour simuler une vérification réseau moderne
      await Future.delayed(const Duration(milliseconds: 800));

      if (!_isLoginMode && _pinController.text != _confirmPinController.text) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Les codes PIN ne correspondent pas"), backgroundColor: Colors.red),
        );
        return;
      }
      
      final auth = Provider.of<AuthProvider>(context, listen: false);
      setState(() => _isLoading = false);

      if (_isLoginMode) {
        bool success = auth.login(_phoneController.text, _pinController.text);
        if (!success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Téléphone ou PIN incorrect"), backgroundColor: Colors.red),
          );
        }
      } else {
        auth.register(
          _nameController.text,
          _phoneController.text,
          _pinController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isLoginMode ? "Bon retour !" : "Bienvenue sur SENPAY",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isLoginMode ? "Connectez-vous à votre compte" : "Créez votre portefeuille en 1 minute",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoginMode ? "Identifiants" : "Informations personnelles",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            if (!_isLoginMode) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Prénom et Nom",
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) => v!.isEmpty ? "Veuillez saisir votre nom" : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Numéro de téléphone",
                                prefixIcon: Icon(Icons.phone_android_outlined),
                                prefixText: "+221 ",
                              ),
                              validator: (v) => v!.length < 9 ? "Numéro invalide" : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _pinController,
                              obscureText: !_isPinVisible,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              decoration: InputDecoration(
                                labelText: "Code PIN (4 chiffres)",
                                prefixIcon: const Icon(Icons.lock_outline),
                                counterText: "",
                                suffixIcon: IconButton(
                                  icon: Icon(_isPinVisible ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _isPinVisible = !_isPinVisible),
                                ),
                              ),
                              validator: (v) => v!.length != 4 ? "4 chiffres requis" : null,
                            ),
                            if (!_isLoginMode) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPinController,
                                obscureText: !_isPinVisible,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration: const InputDecoration(
                                  labelText: "Confirmer le code PIN",
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                  counterText: "",
                                ),
                                validator: (v) => v != _pinController.text ? "Les codes ne correspondent pas" : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_isLoginMode ? "SE CONNECTER" : "S'INSCRIRE",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                    child: Text(
                      _isLoginMode ? "Nouveau ici ? Créer un compte" : "Déjà un compte ? Se connecter",
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}