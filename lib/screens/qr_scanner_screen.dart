import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // Simuler une détection après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isScanning = false);
        _showPaymentConfirmation();
      }
    });
  }

  void _showPaymentConfirmation() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 50, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text("Payer à : BOULANGERIE JAUNE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Montant : 2 500 F CFA", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final success = Provider.of<AuthProvider>(context, listen: false).payByQRCode("Boulangerie Jaune", 2500);
                  Navigator.pop(context); // Ferme le BottomSheet
                  
                  if (success) {
                    Navigator.pop(context); // Retour à l'accueil si succès
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Paiement effectué avec succès !"), backgroundColor: Colors.green),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Solde insuffisant pour ce paiement"), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text("CONFIRMER LE PAIEMENT"),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulation du viseur de la caméra
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isScanning 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : const Icon(Icons.check_circle, color: Colors.green, size: 80),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Placez le QR Code dans le cadre",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}