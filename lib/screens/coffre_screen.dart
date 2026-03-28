import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_dialog.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _amountController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processVaultAction(bool isAdding) async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // Demander le PIN pour la sécurité
    String? pin = await showDialog<String>(context: context, builder: (_) => PinDialog());
    if (pin == null || !auth.verifyPin(pin)) {
      if (pin != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code PIN incorrect"), backgroundColor: Colors.red),
        );
      }
      return;
    }

    bool success = isAdding ? auth.addToVault(amount) : auth.withdrawFromVault(amount);

    if (success) {
      _amountController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAdding ? "Argent mis en sécurité !" : "Argent récupéré !"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Solde insuffisant"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Coffre-fort")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF8E75FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_person_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Solde dans le coffre",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(user?.vaultBalance ?? 0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Montant (F CFA)",
                hintText: "Combien voulez-vous déplacer ?",
                prefixIcon: Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _processVaultAction(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      foregroundColor: Colors.green,
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.add_circle_outline),
                        Text("Garder"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _processVaultAction(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange,
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.remove_circle_outline),
                        Text("Récupérer"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}