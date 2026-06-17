class Opinion {
  final int? id;
  final int movieId;
  final int userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Opinion({
    this.id,
    required this.movieId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt
  });
}