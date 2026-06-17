import '../entities/opinion.dart';
import '../repositories/opinions_repository.dart';

class GetOpinionsByMovieUseCase {
  final OpinionsRepository repository;

  GetOpinionsByMovieUseCase(this.repository);

  Future<List<Opinion>> call(int movieId) {
    return repository.getOpinionsByMovie(movieId);
  }
}