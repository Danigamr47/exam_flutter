import 'package:flutter/material.dart';

class PinDialog extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  PinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sécurité SENPAY", textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Entrez votre code PIN pour valider"),
          const SizedBox(height: 20),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: "****"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _pinController.text),
          child: const Text("Valider"),
        ),
      ],
    );
  }
}