import '../entities/breed.dart';
import '../repositories/i_cat_repository.dart';

class GetBreedsUseCase {
  final ICatRepository repository;

  GetBreedsUseCase(this.repository);

  Future<List<Breed>> call() async {
    return await repository.getBreeds();
  }
}
