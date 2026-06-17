import '../../entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.author,
    required super.content,
    super.rating,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final authorDetails = json['author_details'];

    double? rating;
    if (authorDetails is Map<String, dynamic>) {
      final raw = authorDetails['rating'];
      rating = (raw as num?)?.toDouble();
    }

    return ReviewModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'Anónimo',
      content: json['content'] as String? ?? '',
      rating: rating,
    );
  }

  Review toEntity() => Review(
        id: id,
        author: author,
        content: content,
        rating: rating,
      );
}