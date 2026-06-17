class OpinionView {
  final String authorName;
  final String comment;
  final double rating;
  final bool fromTmdb;

  const OpinionView({
    required this.authorName,
    required this.comment,
    required this.rating,
    required this.fromTmdb,
  });

  String get initials {
    final parts = authorName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}