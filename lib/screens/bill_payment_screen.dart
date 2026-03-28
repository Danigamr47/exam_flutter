import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
// ignore: unused_import
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_dialog.dart';
import 'package:intl/intl.dart';

class BillPaymentScreen extends StatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  // Liste locale des facturiers (Exigence : Données locales)
  final List<ServiceModel> _services = [
    ServiceModel(id: '1', name: 'SENELEC (Facture)', logoPath: '', color: Colors.orange),
    ServiceModel(id: '4', name: 'WOYOFAL (Achat crédit)', logoPath: '', color: Colors.yellow.shade700),
    ServiceModel(id: '2', name: 'SEN’EAU', logoPath: '', color: Colors.blue),
    ServiceModel(id: '3', name: 'RAPIDO', logoPath: '', color: Colors.red),
    ServiceModel(id: '5', name: 'Groupe ISI', logoPath: '', color: Colors.blue.shade900),
  ];

  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'F CFA', decimalDigits: 0);
  String _searchQuery = "";

  // Sélecteur d'icône basé sur le nom du service
  IconData _getServiceIcon(String serviceName) {
    if (serviceName.contains("SENELEC")) return Icons.receipt_outlined;
    if (serviceName.contains("WOYOFAL")) return Icons.flash_on_rounded;
    if (serviceName.contains("SEN’EAU")) return Icons.water_drop_outlined;
    if (serviceName.contains("RAPIDO")) return Icons.directions_car_filled_outlined;
    if (serviceName.contains("ISI")) return Icons.school_outlined;
    return Icons.business_center_outlined;
  }

  // Retourne la longueur requise pour la référence selon le service (standards Sénégal)
  int _getRequiredLength(String serviceName) {
    if (serviceName.contains("WOYOFAL")) return 11;
    if (serviceName.contains("SENELEC")) return 12;
    if (serviceName.contains("SEN’EAU")) return 10;
    if (serviceName.contains("RAPIDO")) return 8;
    if (serviceName.contains("ISI")) return 8;
    return 14; // Valeur par défaut
  }

  // Logique de traitement du paiement (Architecture identique au transfert)
  Future<void> _processPayment(ServiceModel service, String reference, double amount) async {
    // 1. Demander le code PIN
    final String? enteredPin = await showDialog<String>(
      context: context, 
      builder: (_) => PinDialog()
    );

    if (enteredPin == null) return; // Annulé par l'utilisateur

    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // 2. Vérification du PIN
    if (auth.verifyPin(enteredPin)) {
      // 3. Exécution de la transaction dans le Provider
      final bool success = auth.payBill(service.name, reference, amount);

      if (success) {
        // Succès : On ferme l'écran actuel pour revenir à l'accueil et voir le solde mis à jour
        if (mounted) {
          Navigator.pop(context); // Ferme le formulaire/liste
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Paiement de ${_currencyFormat.format(amount)} pour ${service.name} réussi !"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Échec : Solde insuffisant
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solde insuffisant pour ce paiement"), backgroundColor: Colors.red),
        );
      }
    } else {
      // PIN Incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code PIN incorrect"), backgroundColor: Colors.red),
      );
    }
  }

  // Formulaire de saisie des informations de facture
  void _showBillForm(ServiceModel service) {
    final refController = TextEditingController();
    final amountController = TextEditingController();
    final int requiredLength = _getRequiredLength(service.name);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Liste des mois pour le paiement de scolarité (ISI)
    final List<String> months = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    String? selectedMonth;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: service.color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: service.color,
                radius: 30,
                child: Icon(_getServiceIcon(service.name), color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                service.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
                "Solde disponible : ${_currencyFormat.format(auth.currentUser?.balance ?? 0)}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: refController,
                keyboardType: service.name.contains("ISI") ? TextInputType.text : TextInputType.number,
                decoration: InputDecoration(
                  labelText: service.name.contains("ISI") ? "Matricule Étudiant" : "Numéro de référence",
                  hintText: "Saisir les $requiredLength chiffres",
                  prefixIcon: Icon(service.name.contains("ISI") ? Icons.school : Icons.tag),
                  helperText: service.name.contains("ISI") ? "Matricule de l'étudiant" : "Référence client ou compteur",
                ),
                validator: (v) => v!.length != requiredLength ? "Référence invalide" : null,
              ),
              
              // Champ spécifique pour choisir le mois (ISI uniquement)
              if (service.name.contains("ISI")) ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: "Mois à régler",
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  items: months.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m),
                  )).toList(),
                  onChanged: (val) {
                    setStateDialog(() {
                      selectedMonth = val;
                    });
                  },
                  validator: (v) => v == null ? "Veuillez choisir le mois" : null,
                ),
              ],

              const SizedBox(height: 20),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                decoration: InputDecoration(
                  labelText: "Montant à payer",
                  suffixText: "F CFA",
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  final amount = double.tryParse(v ?? "") ?? 0;
                  if (amount <= 0) return "Montant invalide";
                  if (service.name.contains("ISI") && amount < 70000) {
                    return "Le montant minimum pour ISI est de 70 000 F CFA";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Frais de service : 0 F CFA", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Annuler"),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(ctx);
                        String finalReference = refController.text;
                        // On concatène le mois à la référence pour l'historique
                        if (service.name.contains("ISI") && selectedMonth != null) {
                          finalReference = "${refController.text} ($selectedMonth)";
                        }
                        
                        _processPayment(service, finalReference, double.parse(amountController.text));
                      }
                    },
                    child: const Text("Confirmer le paiement"),
                  ),
                ),
              ],
            ),
          ),
        ]      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favoriteIds = authProvider.currentUser?.favorites ?? [];

    // Logique de filtre (Exigence : Recherche ou filtre)
    final filteredServices = _services
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final favoriteServices = _services.where((s) => favoriteIds.contains(s.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Paiement de factures")),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: "Rechercher un service...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          // Section des favoris épinglés (Visible uniquement si pas de recherche en cours)
          if (favoriteServices.isNotEmpty && _searchQuery.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Favoris épinglés", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favoriteServices.length,
                itemBuilder: (context, index) {
                  final service = favoriteServices[index];
                  return GestureDetector(
                    onTap: () => _showBillForm(service),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: service.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getServiceIcon(service.name), color: service.color, size: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.name.split(' ')[0],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(indent: 20, endIndent: 20, height: 30),
          ],

          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                final isFavorite = favoriteIds.contains(service.id);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: service.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(_getServiceIcon(service.name), color: service.color),
                    ),
                    title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text(
                      service.name.contains("WOYOFAL") 
                          ? "Achat de jetons" 
                          : (service.name.contains("ISI") 
                              ? "Mensualité étudiant" 
                              : "Régler ma facture"),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFavorite ? Colors.amber : Colors.grey.shade300,
                          ),
                          onPressed: () => authProvider.toggleFavorite(service.id),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                    onTap: () => _showBillForm(service),
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