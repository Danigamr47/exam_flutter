import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_snackbar.dart';
import 'transfer_screen.dart';
import 'bill_payment_screen.dart';
import 'qr_scanner_screen.dart';
import 'notifications_screen.dart';
import 'my_qr_code_screen.dart';
import 'profile_screen.dart';
import 'coffre_screen.dart';
import 'transport_screen.dart';
import 'history_screen.dart';
import '../widgets/pin_dialog.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isBalanceVisible = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final currencyFormatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: 'F CFA',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SENPAY',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          // Bouton notifications
          Stack(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
              if (auth.unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${auth.unreadNotificationsCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Menu profil
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (value == 'logout') {
                String? pin = await showDialog(
                  context: context,
                  builder: (_) => PinDialog(),
                );
                if (pin != null && auth.verifyPin(pin)) {
                  auth.logout();
                } else if (pin != null) {
                  CustomSnackbar.error(
                    context,
                    'Le code PIN saisi est incorrect',
                    title: 'PIN invalide',
                  );
                }
              }
            },
            icon:  Icon(
              Icons.account_circle_outlined,
              color: Theme.of(context).textTheme.bodySmall?.color,
              size: 26,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text("Mon Profil"),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    "Déconnexion",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ══════════════════════════
                // CARTE SOLDE
                // ══════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          Color(0xFF8E24AA),
                          Color(0xFFAD1457),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Cercles décoratifs
                        Positioned(
                          right: -30,
                          top: -30,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.07),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          bottom: -20,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.05),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bonjour
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '👋 Bonjour, ${user?.fullName.split(' ').first ?? 'Utilisateur'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Label solde
                            Text(
                              'Solde disponible',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Montant
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    _isBalanceVisible
                                        ? currencyFormatter.format(
                                            user?.balance ?? 0,
                                          )
                                        : '•••••• F CFA',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(
                                    () =>
                                        _isBalanceVisible = !_isBalanceVisible,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _isBalanceVisible
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Numéro + coffre
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_android,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+221 ${user?.phoneNumber ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.lock_person_rounded,
                                        color: Colors.white70,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Coffre: ${currencyFormatter.format(user?.vaultBalance ?? 0)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ══════════════════════════
                // ACTIONS LIGNE 1
                // ══════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.swap_horiz_rounded,
                            label: 'Transfert',
                            gradient: [
                              Colors.blue.shade400,
                              Colors.blue.shade700,
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransferScreen(),
                              ),
                            ),
                          ),
                          _buildActionButton(
                            icon: Icons.lock_outline_rounded,
                            label: 'Coffre',
                            gradient: [
                              Colors.indigo.shade400,
                              Colors.indigo.shade700,
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VaultScreen(),
                              ),
                            ),
                          ),
                          _buildActionButton(
                            icon: Icons.receipt_long_rounded,
                            label: 'Factures',
                            gradient: [
                              Colors.orange.shade400,
                              Colors.orange.shade700,
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BillPaymentScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ACTIONS LIGNE 2
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.directions_bus_filled_rounded,
                            label: 'Transport',
                            gradient: [
                              Colors.teal.shade400,
                              Colors.teal.shade700,
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransportScreen(),
                              ),
                            ),
                          ),
                          _buildActionButton(
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Scanner',
                            gradient: [
                              AppTheme.primaryColor,
                              const Color(0xFF8E24AA),
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QrScannerScreen(),
                              ),
                            ),
                          ),
                          _buildActionButton(
                            icon: Icons.qr_code_2_rounded,
                            label: 'Ma Carte',
                            gradient: [
                              Colors.purple.shade400,
                              Colors.purple.shade700,
                            ],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyQrCodeScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ══════════════════════════
                // TRANSACTIONS RÉCENTES
                // ══════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions récentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Voir tout →',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                auth.transactions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune transaction pour le moment',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: auth.transactions.length > 5
                              ? 5
                              : auth.transactions.length,
                          separatorBuilder: (_, __) => Divider(
                            color: Colors.grey.shade50,
                            height: 1,
                            indent: 70,
                          ),
                          itemBuilder: (context, index) {
                            final transaction = auth.transactions[index];
                            final isNegative = transaction.amount < 0;

                            // Couleur et icône selon le type
                            Color color;
                            IconData icon;

                            switch (transaction.type) {
                              case TransactionType.envoi:
                                color = Colors.red;
                                icon = Icons.arrow_upward_rounded;
                                break;
                              case TransactionType.reception:
                                color = Colors.green;
                                icon = Icons.arrow_downward_rounded;
                                break;
                              case TransactionType.facture:
                                color = Colors.orange;
                                icon = Icons.receipt_long_rounded;
                                break;
                            }
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              title: Text(
                                transaction.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM, HH:mm',
                                ).format(transaction.date),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                '${isNegative ? '-' : '+'} ${NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0).format(transaction.amount.abs())}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isNegative
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
