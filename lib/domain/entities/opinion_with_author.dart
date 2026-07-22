import 'opinion.dart';

class OpinionWithAuthor {
  final Opinion opinion;
  final String authorName;
  final String authorLastName;
  final String? authorPhotoPath;

  const OpinionWithAuthor({
    required this.opinion,
    required this.authorName,
    required this.authorLastName,
    this.authorPhotoPath,
  });

  String get fullName => '$authorName $authorLastName'.trim();
  String get initials {
    final n = authorName.isNotEmpty ? authorName[0] : '';
    final l = authorLastName.isNotEmpty ? authorLastName[0] : '';
    return '$n$l'.toUpperCase();
  }
}