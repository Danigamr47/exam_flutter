import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senpay/widgets/pin_dialog.dart';
import '../providers/auth_provider.dart';


class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  void _submit() async {
  if (_formKey.currentState!.validate()) {
    // 1. Demander le code PIN
    String? enteredPin = await showDialog<String>(
      context: context,
      builder: (context) => PinDialog(),
    );

    if (enteredPin == null) return; // Annulé

    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // 2. Vérifier le PIN (Simulation)
    if (auth.verifyPin(enteredPin)) {
      final amount = double.parse(_amountController.text);
      bool success = auth.transferMoney(_recipientController.text, amount);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transfert réussi !"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solde insuffisant"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code PIN incorrect"), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Envoyer de l'argent")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                height: 50,
                child: ElevatedButton(onPressed: _submit, child: const Text("Confirmer l'envoi")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}