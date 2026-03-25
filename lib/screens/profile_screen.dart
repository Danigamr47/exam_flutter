import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Section Informations
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Informations",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(_isEditing ? Icons.check : Icons.edit,
                              color: AppTheme.primaryColor),
                          onPressed: () {
                            if (_isEditing) {
                              auth.updateUserInfo(_nameController.text);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Profil mis à jour")));
                            }
                            setState(() => _isEditing = !_isEditing);
                          },
                        )
                      ],
                    ),
                    const Divider(),
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                          labelText: "Nom complet",
                          prefixIcon: Icon(Icons.person_outline)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller:
                          TextEditingController(text: user.phoneNumber),
                      enabled: false,
                      decoration: const InputDecoration(
                          labelText: "Téléphone",
                          prefixIcon: Icon(Icons.phone_android)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section Sécurité
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sécurité",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text("Changer le code PIN",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _oldPinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Ancien PIN",
                          prefixIcon: Icon(Icons.lock_open)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Nouveau PIN",
                          prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_oldPinController.text.length == 4 &&
                              _newPinController.text.length == 4) {
                            bool success = auth.changePin(
                                _oldPinController.text, _newPinController.text);
                            if (success) {
                              _oldPinController.clear();
                              _newPinController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("PIN modifié avec succès !"),
                                      backgroundColor: Colors.green));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Ancien PIN incorrect"),
                                      backgroundColor: Colors.red));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Le PIN doit faire 4 chiffres"),
                                    backgroundColor: Colors.orange));
                          }
                        },
                        child: const Text("Mettre à jour le PIN"),
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