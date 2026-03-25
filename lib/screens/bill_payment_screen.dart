import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
// ignore: unused_import
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_dialog.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  // Liste locale des facturiers (Exigence : Données locales)
  final List<ServiceModel> _services = [
    ServiceModel(id: '1', name: 'SENELEC', logoPath: 'assets/logos/senelec.png', color: Colors.orange),
    ServiceModel(id: '2', name: 'SEN’EAU', logoPath: 'assets/logos/seneau.png', color: Colors.blue),
    ServiceModel(id: '3', name: 'RAPIDO', logoPath: 'assets/logos/rapido.png', color: Colors.red),
    ServiceModel(id: '4', name: 'WOYOFAL', logoPath: 'assets/logos/senelec.png', color: Colors.yellow),
  ];

  String _searchQuery = "";

  // Fonction pour afficher le formulaire de paiement
  void _showBillDialog(ServiceModel service) {
    final referenceController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Paiement ${service.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(labelText: "Numéro de client / Compteur"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Montant à payer"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (referenceController.text.isNotEmpty && amountController.text.isNotEmpty) {
                Navigator.pop(context); // Fermer le formulaire
                // Demander le PIN
                String? pin = await showDialog(context: context, builder: (_) => PinDialog());
                
                if (pin != null && mounted) {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  if (auth.verifyPin(pin)) {
                     bool success = auth.payBill(service.name, referenceController.text, double.parse(amountController.text));
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content: Text(success ? "Paiement effectué !" : "Solde insuffisant"),
                       backgroundColor: success ? Colors.green : Colors.red,
                     ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code PIN incorrect"), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text("Payer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logique de filtre (Exigence : Recherche ou filtre)
    final filteredServices = _services
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Paiement de factures")),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Rechercher un service...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.business, color: Colors.grey), // Remplacer par Image.asset(service.logoPath)
                    ),
                    title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Paiement immédiat sans frais"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showBillDialog(service),
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