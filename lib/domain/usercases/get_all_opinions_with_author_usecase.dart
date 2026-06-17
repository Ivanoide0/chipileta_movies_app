import '../entities/opinion_with_author.dart';
import '../repositories/opinions_repository.dart';

class GetAllOpinionsWithAuthorUseCase {
  final OpinionsRepository repository;

  GetAllOpinionsWithAuthorUseCase(this.repository);

  Future<List<OpinionWithAuthor>> call() {
    return repository.getAllOpinionsWithAuthor();
  }
}