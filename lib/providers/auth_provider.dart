import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  List<TransactionModel> get transactions => _transactions;

  // Constructeur : charge les données au démarrage
  AuthProvider() {
    _loadData();
  }

  // Inscription avec choix du PIN
  void register(String name, String phone, String cni, String chosenPin) {
    _currentUser = UserModel(
      fullName: name,
      phoneNumber: phone,
      idNumber: cni,
      pin: chosenPin, // Enregistrement du PIN client
      balance: 250000.0, // Bonus de bienvenue pour tes tests
    );
    notifyListeners();
    _saveData();
  }

  // Déconnexion
  void logout() {
    _currentUser = null;
    _transactions = [];
    notifyListeners();
    _clearData(); // On efface les données locales si l'utilisateur se déconnecte explicitement
  }

  // Vérification du PIN lors des transactions
  bool verifyPin(String inputPin) {
    return _currentUser?.pin == inputPin;
  }

  // Simulation d'un dépôt (Recharge de compte)
  void deposit(double amount) {
  if (_currentUser != null) {
    _currentUser!.balance += amount;
    _transactions.insert(0, TransactionModel(
      id: const Uuid().v4(),
      title: "Dépôt d'argent",
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.reception,
    ));
    notifyListeners();
    _saveData();
  }
}

  // Envoi d'argent
  bool transferMoney(String recipient, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      _currentUser!.balance -= amount;
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "Envoi à $recipient",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.envoi,
      ));
      notifyListeners();
      _saveData();
      return true;
    }
    return false;
  }

  // Paiement par QR Code
  bool payByQRCode(String merchant, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      _currentUser!.balance -= amount;
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "Paiement $merchant",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.facture,
      ));
      notifyListeners();
      _saveData();
      return true;
    }
    return false;
  }

  // Paiement de Facture (Senelec, Eau, etc.)
  bool payBill(String serviceName, String reference, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      _currentUser!.balance -= amount;
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "$serviceName - $reference",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.facture,
      ));
      notifyListeners();
      _saveData();
      return true;
    }
    return false;
  }

  // Mise à jour des informations utilisateur
  void updateUserInfo(String newName) {
    if (_currentUser != null) {
      _currentUser = UserModel(
        fullName: newName,
        phoneNumber: _currentUser!.phoneNumber,
        idNumber: _currentUser!.idNumber,
        pin: _currentUser!.pin,
        balance: _currentUser!.balance,
        favorites: _currentUser!.favorites,
      );
      notifyListeners();
      _saveData();
    }
  }

  // Changement de PIN
  bool changePin(String oldPin, String newPin) {
    if (_currentUser != null && _currentUser!.pin == oldPin) {
      _currentUser = UserModel(
        fullName: _currentUser!.fullName,
        phoneNumber: _currentUser!.phoneNumber,
        idNumber: _currentUser!.idNumber,
        pin: newPin,
        balance: _currentUser!.balance,
        favorites: _currentUser!.favorites,
      );
      notifyListeners();
      _saveData();
      return true;
    }
    return false;
  }

  // --- PERSISTANCE DES DONNÉES ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      // Sauvegarde User
      String userJson = jsonEncode(_currentUser!.toJson());
      await prefs.setString('user_data', userJson);

      // Sauvegarde Transactions
      List<String> transactionsJson = _transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('transactions_data', transactionsJson);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Chargement User
    String? userString = prefs.getString('user_data');
    if (userString != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userString));
    }

    // Chargement Transactions
    List<String>? transactionsList = prefs.getStringList('transactions_data');
    if (transactionsList != null) {
      _transactions = transactionsList.map((t) => TransactionModel.fromJson(jsonDecode(t))).toList();
    }
    notifyListeners();
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('transactions_data');
  }
}