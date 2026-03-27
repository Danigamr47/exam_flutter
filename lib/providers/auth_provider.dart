import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  List<TransactionModel> _transactions = [];
  List<NotificationModel> _notifications = [];
  bool _isSessionActive = false;
  bool _isDarkMode = false;

  // Contacts fictifs pour les tests de transfert
  final List<Map<String, String>> _mockContacts = [
    {"name": "Moussa Diop", "phone": "771234567"},
    {"name": "Fatou Sow", "phone": "789876543"},
    {"name": "Ibrahima Ndiaye", "phone": "705554433"},
    {"name": "Awa Fall", "phone": "761112233"},
  ];

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _isSessionActive;
  bool get hasAccount => _currentUser != null;
  List<TransactionModel> get transactions => _transactions;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;
  bool get isDarkMode => _isDarkMode;
  List<Map<String, String>> get suggestedContacts => _mockContacts;

  // Constructeur : charge les données au démarrage
  AuthProvider() {
    _loadData();
  }

  // Inscription avec choix du PIN
  void register(String name, String phone, String chosenPin) {
    _currentUser = UserModel(
      fullName: name,
      phoneNumber: phone,
      idNumber: "", // Vide par défaut, à compléter dans le profil
      pin: chosenPin, // Enregistrement du PIN client
      balance: 150000.0, // Bonus de bienvenue pour tes tests
    );
    _isSessionActive = true;
    notifyListeners();
    _saveData();
  }

  // Connexion
  bool login(String phone, String pin) {
    if (_currentUser != null && 
        _currentUser!.phoneNumber == phone && 
        _currentUser!.pin == pin) {
      _isSessionActive = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Déconnexion
  void logout() {
    _isSessionActive = false;
    _currentUser = null;
    _transactions = [];
    notifyListeners();
  }

  // Vérification du PIN lors des transactions
  bool verifyPin(String inputPin) {
    return _currentUser?.pin == inputPin;
  }

  // Ajout d'une notification interne
  void _addNotification(String title, String message) {
    _notifications.insert(0, NotificationModel(
      id: const Uuid().v4(),
      title: title,
      message: message,
      date: DateTime.now(),
    ));
    notifyListeners();
    _saveData();
  }

  // Simulation d'un dépôt (Recharge de compte)
  void deposit(double amount) {
  if (_currentUser != null) {
    _currentUser = _currentUser!.copyWith(balance: _currentUser!.balance + amount);
    _transactions.insert(0, TransactionModel(
      id: const Uuid().v4(),
      title: "Dépôt d'argent",
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.reception,
    ));
    _addNotification("Dépôt réussi", "Vous avez reçu ${amount.toStringAsFixed(0)} F CFA sur votre compte.");
    notifyListeners();
    _saveData();
  }
}

  // Envoi d'argent
  bool transferMoney(String recipient, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      final double newBalance = _currentUser!.balance - amount;
      _currentUser = _currentUser!.copyWith(balance: newBalance);
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "Envoi à $recipient",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.envoi,
      ));
      _addNotification("Transfert réussi", "Vous avez envoyé ${amount.toStringAsFixed(0)} F CFA à $recipient.");
      notifyListeners();
      _saveData();
      return true;
    } else {
      _addNotification("Échec du transfert", "Le transfert de ${amount.toStringAsFixed(0)} F CFA vers $recipient a échoué (Solde insuffisant).");
      return false;
    }
  }

  // Paiement par QR Code
  bool payByQRCode(String merchant, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      final double newBalance = _currentUser!.balance - amount;
      _currentUser = _currentUser!.copyWith(balance: newBalance);
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "Paiement $merchant",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.facture,
      ));
      _addNotification("Paiement effectué", "Paiement de ${amount.toStringAsFixed(0)} F CFA à $merchant.");
      notifyListeners();
      _saveData();
      return true;
    } else {
      _addNotification("Échec du paiement", "Le paiement de ${amount.toStringAsFixed(0)} F CFA à $merchant a échoué (Solde insuffisant).");
      return false;
    }
  }

  // Paiement de Facture (Senelec, Eau, etc.)
  bool payBill(String serviceName, String reference, double amount) {
    if (_currentUser != null && _currentUser!.balance >= amount) {
      final double newBalance = _currentUser!.balance - amount;
      _currentUser = _currentUser!.copyWith(balance: newBalance);
      _transactions.insert(0, TransactionModel(
        id: const Uuid().v4(),
        title: "$serviceName - $reference",
        amount: -amount,
        date: DateTime.now(),
        type: TransactionType.facture,
      ));
      _addNotification("Facture payée", "Votre facture $serviceName (${amount.toStringAsFixed(0)} F CFA) a été réglée.");
      notifyListeners();
      _saveData();
      return true;
    } else {
      _addNotification("Échec de facture", "Le paiement de la facture $serviceName (${amount.toStringAsFixed(0)} F CFA) a échoué (Solde insuffisant).");
      return false;
    }
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

  // Mise à jour du numéro CNI
  void updateCni(String newCni) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(idNumber: newCni);
      _addNotification("Profil mis à jour", "Votre numéro CNI a été enregistré avec succès.");
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

  // Gestion des favoris
  void toggleFavorite(String serviceId) {
    if (_currentUser != null) {
      final favorites = List<String>.from(_currentUser!.favorites);
      if (favorites.contains(serviceId)) {
        favorites.remove(serviceId);
      } else {
        favorites.add(serviceId);
      }
      _currentUser = UserModel(
        fullName: _currentUser!.fullName,
        phoneNumber: _currentUser!.phoneNumber,
        idNumber: _currentUser!.idNumber,
        pin: _currentUser!.pin,
        balance: _currentUser!.balance,
        favorites: favorites,
      );
      notifyListeners();
      _saveData();
    }
  }

  // Supprimer une notification spécifique
  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveData();
  }

  // Vider tout l'historique
  void clearNotifications() {
    _notifications = [];
    notifyListeners();
    _saveData();
  }

  // Marquer toutes les notifications comme lues
  void markAllAsRead() {
    for (var notif in _notifications) {
      notif.isRead = true;
    }
    notifyListeners();
    _saveData();
  }

  // Alterner le thème
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveData();
  }

  // --- PERSISTANCE DES DONNÉES ---

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    if (_currentUser != null) {
      // Sauvegarde User
      String userJson = jsonEncode(_currentUser!.toJson());
      await prefs.setString('user_data', userJson);

      // Sauvegarde Transactions
      List<String> transactionsJson = _transactions.map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList('transactions_data', transactionsJson);

      // Sauvegarde Notifications
      List<String> notificationsJson = _notifications.map((n) => jsonEncode(n.toJson())).toList();
      await prefs.setStringList('notifications_data', notificationsJson);
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

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

    // Chargement Notifications
    List<String>? notificationsList = prefs.getStringList('notifications_data');
    if (notificationsList != null) {
      _notifications = notificationsList.map((n) => NotificationModel.fromJson(jsonDecode(n))).toList();
    }
    notifyListeners();
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('transactions_data');
  }
}