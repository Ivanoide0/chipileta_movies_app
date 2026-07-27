import '../entities/opinion.dart';
import '../entities/opinion_with_author.dart';

abstract class OpinionsRepository {
  Future<Opinion> addOpinion({
    required int movieId,
    required String userId,
    required double rating,
    required String comment,
    required String authorName,
    required String authorLastName,
    String? authorPhotoPath,
  });

  Future<List<Opinion>> getOpinionsByMovie(int movieId);
  Future<List<Opinion>> getAllOpinions();
  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor();
}