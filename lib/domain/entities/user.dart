class User {
  final int? id;
  final String name;
  final String lastName;
  final String email;
  final String telephone;
  final bool acceptTerms;
  final int rolId;
  final bool isActive;
  final DateTime createdAt;
  final String? photoPath;

  const User({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.acceptTerms,
    required this.rolId,
    required this.isActive,
    required this.createdAt,
    this.photoPath,
  });

  User copyWith({
    int? id,
    String? name,
    String? lastName,
    String? email,
    String? telephone,
    bool? acceptTerms,
    int? rolId,
    bool? isActive,
    DateTime? createdAt,
    String? photoPath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      rolId: rolId ?? this.rolId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}