import '../entities/cat.dart';
import '../repositories/i_cat_repository.dart';

class GetCatsUseCase {
  final ICatRepository repository;

  GetCatsUseCase(this.repository);

  Future<List<Cat>> call({int limit = 10}) async {
    return await repository.getCats(limit: limit);
  }
}
