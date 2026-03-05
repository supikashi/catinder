import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get apiKey => dotenv.env['CAT_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.thecatapi.com/v1';
  static const String imagesSearchEndpoint = '/images/search';
  static const String breedsEndpoint = '/breeds';
}
