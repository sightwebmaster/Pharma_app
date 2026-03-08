import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String userId;
  final String role;
  final String nom;
  final String prenom;
  final String? email;

  AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    required this.userId,
    required this.role,
    required this.nom,
    required this.prenom,
    this.email,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String?,
      expiresIn: json['expiresIn'] as int?,
      // ✅ Fix: fallback '' si null
      userId: (json['userId'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'PATIENT',
      nom: (json['nom'] as String?) ?? '',
      prenom: (json['prenom'] as String?) ?? '',
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
        'userId': userId,
        'role': role,
        'nom': nom,
        'prenom': prenom,
        'email': email,
      };

  // ✅ Crée UserModel depuis les champs plats
  UserModel get user => UserModel(
        id: userId,
        nom: nom,
        prenom: prenom,
        email: email,
        role: role,
      );

  String get message => 'Connexion réussie';
}