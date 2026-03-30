import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_dialog.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_snackbar.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F CFA',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> transportServices = const [
    {"name": "TER", "icon": Icons.train, "color": Colors.green},
    {"name": "BRT", "icon": Icons.directions_bus, "color": Colors.blue},
    {
      "name": "DEM DIKK",
      "icon": Icons.directions_bus_filled,
      "color": Colors.orange,
    },
    {"name": "YANGO", "icon": Icons.local_taxi, "color": Colors.black},
  ];

  // Simule le scan d'un QR Code de transport
  void _handleQrScan() {
    // Simulation d'un scan réussi après un court délai
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          margin: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Lecture du ticket..."),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Ferme le dialogue de lecture

      // Données simulées extraites du QR Code (Ex: un trajet TER)
      final scannedData = {
        "service": "TER",
        "reference": "TICKET-7742-X",
        "amount": 1500.0,
      };

      _showScanConfirmation(scannedData);
    });
  }

  // Affiche un récapitulatif après le scan
  void _showScanConfirmation(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              "Ticket détecté : ${data['service']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Référence : ${data['reference']}"),
            Text(
              "Montant : ${_currencyFormat.format(data['amount'])}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _processPayment(
                    data['service'],
                    data['reference'],
                    data['amount'],
                  );
                },
                child: const Text("PAYER MAINTENANT"),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler"),
            ),
          ],
        ),
      ),
    );
  }

  // Retourne le label approprié selon le service
  String _getReferenceLabel(String service) {
    switch (service) {
      case "TER":
      case "BRT":
        return "Numéro de carte";
      case "DEM DIKK":
        return "Référence de réservation";
      case "YANGO":
        return "Code de la course";
      default:
        return "Référence client";
    }
  }

  // Logique de traitement du paiement
  Future<void> _processPayment(
    String service,
    String reference,
    double amount,
  ) async {
    final String? enteredPin = await showDialog<String>(
      context: context,
      builder: (_) => PinDialog(),
    );

    if (enteredPin == null) return;

    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.verifyPin(enteredPin)) {
      final bool success = auth.payTransport(service, amount);

      if (success) {
        if (mounted) Navigator.pop(context); // Retour à l'accueil
        CustomSnackbar.success(context, "Paiement $service de ${_currencyFormat.format(amount)} réussi !",
  title: 'Paiement Transport');

      } else {
        CustomSnackbar.error(
          context,
          'Solde insuffisant pour ce trajet',
          title: 'Paiement échoué',
        );
      }
    } else {
      CustomSnackbar.error(
        context,
        'Le code PIN saisi est incorrect',
        title: 'PIN invalide',
      );
    }
  }

  // Affiche le formulaire spécifique au transporteur
  void _showTransportForm(Map<String, dynamic> service) {
    final refController = TextEditingController();
    final amountController = TextEditingController();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (service['color'] as Color).withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: service['color'],
                radius: 30,
                child: Icon(service['icon'], color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                "Paiement ${service['name']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Solde : ${_currencyFormat.format(auth.currentUser?.balance ?? 0)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: refController,
                decoration: InputDecoration(
                  labelText: _getReferenceLabel(service['name']),
                  prefixIcon: const Icon(Icons.tag),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Champ obligatoire" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  labelText: "Montant à payer",
                  prefixIcon: Icon(Icons.payments_outlined),
                  suffixText: "F CFA",
                ),
                validator: (v) => (double.tryParse(v ?? "") ?? 0) <= 0
                    ? "Montant invalide"
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                _processPayment(
                  service['name'],
                  refController.text,
                  double.parse(amountController.text),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Transport")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleQrScan,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text(
          "Scanner un ticket",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Sélectionnez votre moyen de transport pour payer votre ticket ou trajet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemCount: transportServices.length,
              itemBuilder: (context, index) {
                final service = transportServices[index];
                return InkWell(
                  onTap: () => _showTransportForm(service),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        // ignore: deprecated_member_use
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: (service['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            service['icon'],
                            color: service['color'],
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
