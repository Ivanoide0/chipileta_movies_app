import 'opinion.dart';

class OpinionWithAuthor {
  final Opinion opinion;
  final String authorName;
  final String authorLastName;
  final String? authorPhotoPath;

  /// uids de los usuarios que dieron like a esta opinión.
  final List<String> likedBy;

  const OpinionWithAuthor({
    required this.opinion,
    required this.authorName,
    required this.authorLastName,
    this.authorPhotoPath,
    this.likedBy = const [],
  });

  int get likeCount => likedBy.length;
  bool isLikedBy(String uid) => likedBy.contains(uid);

  String get fullName => '$authorName $authorLastName'.trim();
  String get initials {
    final n = authorName.isNotEmpty ? authorName[0] : '';
    final l = authorLastName.isNotEmpty ? authorLastName[0] : '';
    return '$n$l'.toUpperCase();
  }
}