import '../entities/opinion.dart';
import '../repositories/opinions_repository.dart';

class GetAllOpinionsUseCase {
  final OpinionsRepository repository;

  GetAllOpinionsUseCase(this.repository);

  Future<List<Opinion>> call() {
    return repository.getAllOpinions();
  }
}