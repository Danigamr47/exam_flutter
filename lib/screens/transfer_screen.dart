import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/pin_dialog.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_snackbar.dart';


class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    // 1. Demander le code PIN
    String? enteredPin = await showDialog<String>(context: context, builder: (_) => PinDialog());

    if (enteredPin == null) return; // Annulé

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // 2. Vérifier le PIN (Simulation)
    if (auth.verifyPin(enteredPin)) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      
      if (amount <= 0) {
        CustomSnackbar.error(context, 'Veuillez saisir un montant valide');
        return;
      }

      bool success = auth.transferMoney(_recipientController.text, amount);

      if (success) {
        Navigator.pop(context);
        CustomSnackbar.success(context, 'Transfert effectué avec succès !');
      } else {
       CustomSnackbar.error(context, 'Votre solde est insuffisant pour ce transfert');
      }
    } else {
      CustomSnackbar.error(context, 'Le code PIN saisi est incorrect',
  title: 'PIN invalide');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Envoyer de l'argent")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Contacts favoris", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              // Liste de contacts fictifs
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: auth.suggestedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = auth.suggestedContacts[index];
                    return GestureDetector(
                      onTap: () => _recipientController.text = contact['phone']!,
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 15),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                                                      child: Text(contact['name']![0]),
                            ),
                            const SizedBox(height: 5),
                            Text(contact['name']!, 
                              style: const TextStyle(fontSize: 11), 
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 40),
              const Text("Saisie manuelle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(labelText: "Numéro du destinataire", prefixText: "+221 "),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.length < 9 ? "Numéro invalide" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Montant (F CFA)"),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v!) ?? 0) <= 0 ? "Montant incorrect" : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(onPressed: _submit, child: const Text("Confirmer l'envoi")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}