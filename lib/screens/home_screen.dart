import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

// Importations des composants du projet
//import '../models/transaction_model.dart';
import 'transfer_screen.dart';
import 'bill_payment_screen.dart';
import 'qr_scanner_screen.dart';
import 'notifications_screen.dart';
import 'my_qr_code_screen.dart';
import 'profile_screen.dart';
import 'coffre_screen.dart';
import 'transport_screen.dart';
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
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                icon: const Icon(Icons.notifications_outlined, color: Colors.black, size: 28),
              ),
              if (authProvider.unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${authProvider.unreadNotificationsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else if (value == 'logout') {
                String? pin = await showDialog(context: context, builder: (_) => PinDialog());
                if (pin != null && authProvider.verifyPin(pin)) {
                  authProvider.logout();
                } else if (pin != null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PIN incorrect"), backgroundColor: Colors.red));
                }
              }
            },
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black, size: 28),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: ListTile(leading: Icon(Icons.person_outline), title: Text("Mon Profil"))),
              const PopupMenuItem(value: 'logout', child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: Text("Déconnexion", style: TextStyle(color: Colors.red)))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF8E24AA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -20,
                    child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Solde disponible", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _isBalanceVisible ? currencyFormatter.format(user?.balance ?? 0) : "•••••• F CFA",
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(_isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white70),
                            onPressed: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(user?.fullName.toUpperCase() ?? "", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    ],
                  ),
                ],
              ),
            ),

            // SECTION ACTIONS (Transfert, Factures, Scanner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                          icon: Icons.swap_horiz,
                          label: "Transfert",
                          color: Colors.blue,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
                      _buildActionButton(
                          icon: Icons.lock_outline_rounded,
                          label: "Coffre",
                          color: Colors.indigo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaultScreen()))),
                      _buildActionButton(
                          icon: Icons.receipt_long,
                          label: "Factures",
                          color: Colors.orange,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPaymentScreen()))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                          icon: Icons.directions_bus_filled_outlined,
                          label: "Transport",
                          color: Colors.teal,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportScreen()))),
                      _buildActionButton(
                          icon: Icons.qr_code_scanner,
                          label: "Scanner",
                          color: AppTheme.primaryColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()))),
                      _buildActionButton(
                          icon: Icons.qr_code_2_rounded,
                          label: "Ma Carte",
                          color: Colors.purple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyQrCodeScreen()))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

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
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: authProvider.transactions.length,
                      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade50, height: 1),
                      itemBuilder: (context, index) {
                        final transaction = authProvider.transactions[index];
                        final isNegative = transaction.amount < 0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isNegative ? Colors.red.shade50 : Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isNegative ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isNegative ? Colors.red : Colors.green,
                              size: 20,
                            ),
                          ),
                          title: Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(DateFormat('dd MMM, HH:mm').format(transaction.date), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          trailing: Text(
                            currencyFormatter.format(transaction.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isNegative ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        );
                      },
                    ),
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
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }
}