class UserModel {
  final String fullName;
  final String phoneNumber;
  final String idNumber;
  final String pin; // Nouveau : stockage du PIN choisi
  final double balance;
  List<String> favorites;

  UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.idNumber,
    required this.pin,
    this.balance = 0.0,
    this.favorites = const [],
  });

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? idNumber,
    String? pin,
    double? balance,
    List<String>? favorites,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idNumber: idNumber ?? this.idNumber,
      pin: pin ?? this.pin,
      balance: balance ?? this.balance,
      favorites: favorites ?? this.favorites,
    );
  }

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