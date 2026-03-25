import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _inputPin = "";

  void _onNumberPress(String number) {
    setState(() {
      if (_inputPin.length < 4) _inputPin += number;
    });

    if (_inputPin == "0000") { // Code PIN par défaut
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (_inputPin.length == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code PIN incorrect"), backgroundColor: Colors.red),
      );
      setState(() => _inputPin = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: AppTheme.primaryColor),
            const SizedBox(height: 20),
            const Text("Saisissez votre code PIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // Affichage des points du PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Container(
                margin: const EdgeInsets.all(8),
                width: 15, height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _inputPin.length ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              )),
            ),
            const SizedBox(height: 50),
            // Clavier numérique
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1.2,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  String label = (index + 1).toString();
                  if (index == 9) label = "";
                  if (index == 10) label = "0";
                  if (index == 11) return IconButton(onPressed: () => setState(() => _inputPin = ""), icon: const Icon(Icons.backspace_outlined));
                  if (index == 9) return const SizedBox();

                  return TextButton(
                    onPressed: () => _onNumberPress(label),
                    child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}