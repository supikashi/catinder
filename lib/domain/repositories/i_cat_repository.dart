import '../entities/cat.dart';
import '../entities/breed.dart';

abstract class ICatRepository {
  Future<List<Cat>> getCats({int limit = 10});
  Future<List<Breed>> getBreeds();
}
