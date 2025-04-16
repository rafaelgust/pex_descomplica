import 'role_model.dart';

class UserModel {
  final String? collectionName;
  final bool? emailVisibility;
  final DateTime? created;
  final DateTime? updated;
  final bool? verified;
  final String id;
  final String collectionId;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String avatar;
  final RoleModel role;

  String get fullName => '$firstName $lastName';

  UserModel({
    this.collectionName,
    this.emailVisibility,
    this.created,
    this.updated,
    this.verified,
    required this.id,
    required this.collectionId,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatar,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      collectionName: json['collection_name'],
      emailVisibility: json['email_visibility'],
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      updated: json['updated'] != null ? DateTime.parse(json['updated']) : null,
      verified: json['verified'],
      id: json['id'],
      collectionId: json['collectionId'],
      email: json['email'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
      role: RoleModel.fromJson(json['expand']['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collection_name': collectionName,
      'email_visibility': emailVisibility,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
      'verified': verified,
      'id': id,
      'collectionId': collectionId,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'avatar': avatar,
      'role': role.toJson(),
    };
  }
}
