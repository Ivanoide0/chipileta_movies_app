class User {
  final int? id;
  final String name;
  final String lastName;
  final String email;
  final String telephone;
  final bool acceptTerms;
  final int rolId;

  const User({
    this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.acceptTerms,
    required this.rolId,
  });
}