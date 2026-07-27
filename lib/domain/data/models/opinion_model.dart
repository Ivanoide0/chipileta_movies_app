import '../../entities/opinion.dart';

class OpinionModel extends Opinion {
  // Datos del autor desnormalizados (copiados al crear la opinión).
  final String authorName;
  final String authorLastName;
  final String? authorPhotoPath;

  const OpinionModel({
    super.id,
    required super.movieId,
    required super.userId,
    required super.rating,
    required super.comment,
    required super.createdAt,
    this.authorName = '',
    this.authorLastName = '',
    this.authorPhotoPath,
  });

  Map<String, dynamic> toFirestoreMap() => {
    'movie_id': movieId,
    'user_id': userId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'author_nombre': authorName,
    'author_apellido': authorLastName,
    'author_foto_perfil': authorPhotoPath,
  };

  factory OpinionModel.fromFirestore(String id, Map<String, dynamic> map) =>
      OpinionModel(
        id: id,
        movieId: (map['movie_id'] as num).toInt(),
        userId: map['user_id'] as String,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        authorName: map['author_nombre'] as String? ?? '',
        authorLastName: map['author_apellido'] as String? ?? '',
        authorPhotoPath: map['author_foto_perfil'] as String?,
      );

  Opinion toEntity() => Opinion(
    id: id,
    movieId: movieId,
    userId: userId,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
  );
}