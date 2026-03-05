import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../core/errors.dart';
import '../models/cat_model.dart';
import '../models/breed_model.dart';

abstract class RemoteCatDataSource {
  Future<List<CatModel>> getCats({int limit = 10});
  Future<List<BreedModel>> getBreeds();
}

class RemoteCatDataSourceImpl implements RemoteCatDataSource {
  final http.Client client;

  RemoteCatDataSourceImpl({required this.client});

  @override
  Future<List<CatModel>> getCats({int limit = 10}) async {
    try {
      final response = await client.get(
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.imagesSearchEndpoint}?has_breeds=1&limit=$limit',
        ),
        headers: {'x-api-key': ApiConfig.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data.map((json) => CatModel.fromJson(json)).toList();
        } else {
          return [];
        }
      }
      throw ServerException(ErrorMessages.serverError);
    } catch (e) {
      throw ServerException(ErrorMessages.serverError);
    }
  }

  @override
  Future<List<BreedModel>> getBreeds() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.breedsEndpoint}'),
        headers: {'x-api-key': ApiConfig.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((json) => BreedModel.fromJson(json)).toList();
      }
      throw ServerException(ErrorMessages.serverError);
    } catch (e) {
      throw ServerException(ErrorMessages.serverError);
    }
  }
}
