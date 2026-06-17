import '../../entities/opinion.dart';

class OpinionModel extends Opinion {
  const OpinionModel({
    super.id,
    required super.movieId,
    required super.userId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'movie_id': movieId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  factory OpinionModel.fromMap(Map<String, dynamic> map) => OpinionModel(
        id: map['id'] as int?,
        movieId: map['movie_id'] as int,
        userId: map['user_id'] as int,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
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