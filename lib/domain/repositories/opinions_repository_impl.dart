import '../entities/opinion.dart';
import 'opinions_repository.dart';
import '../datasources/opinions_local_datasource.dart';
import '../entities/opinion_with_author.dart';

class OpinionsRepositoryImpl implements OpinionsRepository {
  final OpinionsLocalDataSource localDataSource;

  OpinionsRepositoryImpl(this.localDataSource);

  @override
  Future<Opinion> addOpinion({
    required int movieId,
    required int userId,
    required double rating,
    required String comment,
  }) async {
    final model = await localDataSource.addOpinion(
      movieId: movieId,
      userId: userId,
      rating: rating,
      comment: comment,
    );
    return model.toEntity();
  }

  @override
  Future<List<Opinion>> getOpinionsByMovie(int movieId) async {
    final models = await localDataSource.getOpinionsByMovie(movieId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Opinion>> getAllOpinions() async {
    final models = await localDataSource.getAllOpinions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor(){
    return localDataSource.getAllOpinionsWithAuthor();
  }
}