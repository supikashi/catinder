import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/cat.dart';
import '../models/breed.dart';
import '../config/api_config.dart';
import 'errors.dart';

class CatApiService {
  final http.Client _client;

  CatApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Cat>> getMultipleCatsWithBreed({int limit = 10}) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.imagesSearchEndpoint}?has_breeds=1&limit=$limit'),
        headers: {'x-api-key': ApiConfig.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data.map((json) => Cat.fromJson(json)).toList();
        }
      }
      throw Exception(ErrorMessages.serverError);
    } catch (e) {
      throw Exception(ErrorMessages.serverError);
    }
  }

  Future<List<Breed>> getAllBreeds() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.breedsEndpoint}'),
        headers: {'x-api-key': ApiConfig.apiKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((json) => Breed.fromJson(json)).toList();
      }
      throw Exception(ErrorMessages.serverError);
    } catch (e) {
      throw Exception(ErrorMessages.serverError);
    }
  }

  void dispose() {
    _client.close();
  }
}
