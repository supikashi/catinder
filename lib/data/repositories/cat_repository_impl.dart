import '../../domain/entities/cat.dart';
import '../../domain/entities/breed.dart';
import '../../domain/repositories/i_cat_repository.dart';
import '../datasources/remote_cat_data_source.dart';

class CatRepositoryImpl implements ICatRepository {
  final RemoteCatDataSource remoteDataSource;

  CatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Cat>> getCats({int limit = 10}) async {
    return await remoteDataSource.getCats(limit: limit);
  }

  @override
  Future<List<Breed>> getBreeds() async {
    return await remoteDataSource.getBreeds();
  }
}
