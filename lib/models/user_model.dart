class UserModel {
  final String fullName;
  final String phoneNumber;
  final String idNumber;
  final String pin; // Nouveau : stockage du PIN choisi
  double balance;
  List<String> favorites;

  UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.idNumber,
    required this.pin,
    this.balance = 0.0,
    this.favorites = const [],
  });

  // Conversion en JSON pour la sauvegarde
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'idNumber': idNumber,
        'pin': pin,
        'balance': balance,
        'favorites': favorites,
      };

  // Création depuis JSON pour le chargement
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        fullName: json['fullName'],
        phoneNumber: json['phoneNumber'],
        idNumber: json['idNumber'],
        pin: json['pin'],
        balance: (json['balance'] as num).toDouble(),
        favorites: List<String>.from(json['favorites'] ?? []),
      );
}