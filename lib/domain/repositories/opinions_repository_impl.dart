import '../entities/opinion.dart';
import 'opinions_repository.dart';
import '../datasources/opinions_remote_datasource.dart';
import '../entities/opinion_with_author.dart';

class OpinionsRepositoryImpl implements OpinionsRepository {
  final OpinionsRemoteDataSource localDataSource;

  OpinionsRepositoryImpl(this.localDataSource);

  @override
  Future<Opinion> addOpinion({
    required int movieId,
    required String userId,
    required double rating,
    required String comment,
    required String authorName,
    required String authorLastName,
    String? authorPhotoPath,
  }) async {
    final model = await localDataSource.addOpinion(
      movieId: movieId,
      userId: userId,
      rating: rating,
      comment: comment,
      authorName: authorName,
      authorLastName: authorLastName,
      authorPhotoPath: authorPhotoPath,
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
  Future<List<OpinionWithAuthor>> getAllOpinionsWithAuthor() {
    return localDataSource.getAllOpinionsWithAuthor();
  }
}