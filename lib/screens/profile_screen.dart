import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/custom_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _cniController = TextEditingController();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cniController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  void _showEditNameDialog(
    BuildContext context,
    AuthProvider auth,
    String currentName,
  ) {
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Modifier mon nom"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Nouveau nom complet"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              auth.updateUserInfo(_nameController.text);
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _showEditCniDialog(
    BuildContext context,
    AuthProvider auth,
    String currentCni,
  ) {
    _cniController.text = currentCni;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Numéro de CNI"),
        content: TextField(
          controller: _cniController,
          decoration: const InputDecoration(
            labelText: "Numéro CNI (14 chiffres)",
            hintText: "Ex: 12345678901234",
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              auth.updateCni(_cniController.text);
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Changer le PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Ancien PIN",
                counterText: "",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Nouveau PIN",
                counterText: "",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              bool success = auth.changePin(
                _oldPinController.text,
                _newPinController.text,
              );
              if (success) {
                Navigator.pop(context);
                CustomSnackbar.success(
                  context,
                  'Votre code PIN a été modifié avec succès',
                  title: 'PIN mis à jour',
                );

                _oldPinController.clear();
                _newPinController.clear();
              } else {
                CustomSnackbar.error(
                  context,
                  'L\'ancien code PIN est incorrect',
                  title: 'PIN invalide',
                );
              }
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres du Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.phoneNumber ?? "",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 40),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text(
                      "Nom d'utilisateur",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(user?.fullName ?? ""),
                    trailing: const Icon(Icons.edit_outlined, size: 20),
                    onTap: () => _showEditNameDialog(
                      context,
                      auth,
                      user?.fullName ?? "",
                    ),
                  ),
                  const Divider(indent: 70, endIndent: 20, height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text(
                      "Numéro CNI",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user?.idNumber.isEmpty ?? true
                          ? "Non renseigné"
                          : user!.idNumber,
                    ),
                    trailing: const Icon(Icons.edit_outlined, size: 20),
                    onTap: () =>
                        _showEditCniDialog(context, auth, user?.idNumber ?? ""),
                  ),
                  const Divider(indent: 70, endIndent: 20, height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.lock_open_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text(
                      "Mot de passe (PIN)",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text("Changer votre code secret"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePinDialog(context, auth),
                  ),
                  const Divider(indent: 70, endIndent: 20, height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.dark_mode_outlined,
                        color: Colors.purple,
                      ),
                    ),
                    title: const Text(
                      "Mode Sombre",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text("Activer le thème sombre"),
                    trailing: Switch.adaptive(
                      value: auth.isDarkMode,
                      onChanged: (val) => auth.toggleTheme(),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  String? pin = await showDialog(
                    context: context,
                    builder: (_) => PinDialog(),
                  );
                  if (pin != null && auth.verifyPin(pin)) {
                    auth.logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (pin != null) {
                    CustomSnackbar.error(
                  context,
                  'Le code PIN saisi est incorrect',
                  title: 'PIN invalide',
                );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "SE DÉCONNECTER",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
