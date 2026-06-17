import '../entities/opinion.dart';
import '../entities/opinion_with_author.dart';

abstract class OpinionsRepository {
  Future<Opinion> addOpinion({
    required int movieId,
    required int userId,
    required double rating,
    required String comment
  });

  Future<List<Opinion>> getOpinionsByMovie(int movieId);
  Future<List<Opinion>> getAllOpinions();
  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor();
}