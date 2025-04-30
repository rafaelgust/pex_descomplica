class SupplierModel {
  final String? collectionId;
  final String? collectionName;
  final String id;
  final String type; // "Jurídico" ou "Físico"
  final String name;
  final String register; // Pode ser CNPJ ou CPF, dependendo do tipo
  final String? telefone;
  final String? email;
  final String? cep;
  final bool active;
  final String? obs;
  final DateTime? created;
  final DateTime? updated;

  SupplierModel({
    this.collectionId,
    this.collectionName,
    required this.id,
    required this.type,
    required this.name,
    required this.register,
    this.telefone,
    this.email,
    this.cep,
    required this.active,
    this.obs,
    this.created,
    this.updated,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      register: json['register'] as String,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      cep: json['cep'] as String?,
      active: json['active'] as bool,
      obs: json['obs'] as String?,
      created:
          json['created'] == null
              ? null
              : DateTime.parse(json['created'] as String),
      updated:
          json['updated'] == null
              ? null
              : DateTime.parse(json['updated'] as String),
    );
  }

  toJson() {
    return {
      'collectionId': collectionId,
      'collectionName': collectionName,
      'id': id,
      'type': type,
      'name': name,
      'register': register,
      'telefone': telefone,
      'email': email,
      'cep': cep,
      'active': active,
      'obs': obs,
      'created': created?.toIso8601String(),
      'updated': updated?.toIso8601String(),
    };
  }
}
