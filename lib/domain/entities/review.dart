class Review {
  final String id;
  final String author;
  final String content;
  final double? rating; // puede ser null en TMDB

  const Review({
    required this.id,
    required this.author,
    required this.content,
    this.rating,
  });
}