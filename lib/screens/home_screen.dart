import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

// Importations des composants du projet
import '../models/transaction_model.dart';
import 'transfer_screen.dart';
import 'bill_payment_screen.dart';
import 'qr_scanner_screen.dart';
import 'profile_screen.dart';
import '../widgets/pin_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isBalanceVisible = true; // État pour masquer le solde

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final currencyFormatter = NumberFormat.currency(
        locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SENPAY"),
        actions: [
          IconButton(
              onPressed: () async {
                // Demande du PIN avant déconnexion
                String? pin = await showDialog(
                  context: context,
                  builder: (_) => PinDialog(),
                );
                
                if (pin != null && authProvider.verifyPin(pin)) {
                  authProvider.logout();
                } else if (pin != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN incorrect"), backgroundColor: Colors.red));
                }
              },
              icon: const Icon(Icons.logout, color: Colors.black)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CARTE SOLDE AMÉLIORÉE
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text("Bonjour, ${user?.fullName ?? 'Utilisateur'}",
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isBalanceVisible 
                          ? currencyFormatter.format(user?.balance ?? 0) 
                          : "•••••• F CFA",
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(_isBalanceVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                        onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SECTION ACTIONS (Transfert, Factures, Scanner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                      icon: Icons.swap_horiz,
                      label: "Transfert",
                      color: Colors.blue,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TransferScreen()))),
                  _buildActionButton(
                      icon: Icons.receipt_long,
                      label: "Factures",
                      color: Colors.orange,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BillPaymentScreen()))),
                  _buildActionButton(
                      icon: Icons.qr_code_scanner,
                      label: "Scanner",
                      color: AppTheme.primaryColor,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const QrScannerScreen()))),
                  _buildActionButton(
                      icon: Icons.more_horiz,
                      label: "Plus",
                      color: Colors.grey,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen())
                          )
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SECTION HISTORIQUE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transactions récentes",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("Voir tout")),
                ],
              ),
            ),

            authProvider.transactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text("Aucune transaction récente",
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: authProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = authProvider.transactions[index];
                      final isNegative = transaction.amount < 0;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isNegative
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          child: Icon(
                            isNegative
                                ? Icons.arrow_outward
                                : Icons.arrow_downward,
                            color: isNegative ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(transaction.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                            .format(transaction.date)),
                        trailing: Text(
                          currencyFormatter.format(transaction.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isNegative ? Colors.red : Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // Widget utilitaire pour les boutons d'action
  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}