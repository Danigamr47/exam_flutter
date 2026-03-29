import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _selectedFilter;
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F CFA',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Filtrer les transactions
    final transactions = _selectedFilter == null
        ? auth.transactions
        : auth.transactions
            .where((t) => t.type == _selectedFilter)
            .toList();

    // Calcul résumé
    double totalEnvoi = auth.transactions
        .where((t) => t.type == TransactionType.envoi)
        .fold(0, (sum, t) => sum + t.amount.abs());

    double totalReception = auth.transactions
        .where((t) => t.type == TransactionType.reception)
        .fold(0, (sum, t) => sum + t.amount.abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: Column(
        children: [

          // ══════════════════════════
          // RÉSUMÉ
          // ══════════════════════════
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF8E24AA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    label: 'Total envoyé',
                    amount: totalEnvoi,
                    icon: Icons.arrow_upward,
                    color: Colors.red.shade200,
                  ),
                ),
                Container(width: 1, height: 50, color: Colors.white24),
                Expanded(
                  child: _buildSummaryItem(
                    label: 'Total reçu',
                    amount: totalReception,
                    icon: Icons.arrow_downward,
                    color: Colors.green.shade200,
                  ),
                ),
              ],
            ),
          ),

          // ══════════════════════════
          // FILTRES
          // ══════════════════════════
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tout',
                  isSelected: _selectedFilter == null,
                  color: AppTheme.primaryColor,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '↑ Envois',
                  isSelected: _selectedFilter == TransactionType.envoi,
                  color: Colors.red,
                  onTap: () => setState(
                    () => _selectedFilter = TransactionType.envoi,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '↓ Réceptions',
                  isSelected: _selectedFilter == TransactionType.reception,
                  color: Colors.green,
                  onTap: () => setState(
                    () => _selectedFilter = TransactionType.reception,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '📄 Factures',
                  isSelected: _selectedFilter == TransactionType.facture,
                  color: Colors.orange,
                  onTap: () => setState(
                    () => _selectedFilter = TransactionType.facture,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Compteur
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${transactions.length} transaction(s)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedFilter != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = null),
                    child: const Text(
                      'Réinitialiser',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ══════════════════════════
          // LISTE
          // ══════════════════════════
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune transaction',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                        if (_selectedFilter != null) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedFilter = null),
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final showDate = index == 0 ||
                          !_isSameDay(
                            transactions[index - 1].date,
                            transaction.date,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                _formatDateHeader(transaction.date),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          _buildTransactionItem(transaction),
                        ],
                      );
                    },
                  ),
          ),

        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer par type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFilterOption(
              icon: Icons.list,
              label: 'Toutes les transactions',
              isSelected: _selectedFilter == null,
              color: AppTheme.primaryColor,
              onTap: () {
                setState(() => _selectedFilter = null);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              icon: Icons.arrow_upward,
              label: 'Envois seulement',
              color: Colors.red,
              isSelected: _selectedFilter == TransactionType.envoi,
              onTap: () {
                setState(() => _selectedFilter = TransactionType.envoi);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              icon: Icons.arrow_downward,
              label: 'Réceptions seulement',
              color: Colors.green,
              isSelected: _selectedFilter == TransactionType.reception,
              onTap: () {
                setState(() => _selectedFilter = TransactionType.reception);
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              icon: Icons.receipt_long,
              label: 'Factures seulement',
              color: Colors.orange,
              isSelected: _selectedFilter == TransactionType.facture,
              onTap: () {
                setState(() => _selectedFilter = TransactionType.facture);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color color = AppTheme.primaryColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: color)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final isNegative = transaction.amount < 0;
    IconData icon;
    Color color;

    switch (transaction.type) {
      case TransactionType.envoi:
        icon = Icons.arrow_upward;
        color = Colors.red;
        break;
      case TransactionType.reception:
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      case TransactionType.facture:
        icon = Icons.receipt_long;
        color = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(transaction.date),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isNegative ? '-' : '+'} ${_currencyFormat.format(transaction.amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isNegative
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return "Aujourd'hui";
    if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return "Hier";
    }
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  }
}