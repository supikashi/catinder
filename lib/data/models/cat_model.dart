import '../../domain/entities/cat.dart';
import '../../data/models/breed_model.dart';

class CatModel extends Cat {
  const CatModel({
    required super.id,
    required super.url,
    super.breed,
  });

  factory CatModel.fromJson(Map<String, dynamic> json) {
    return CatModel(
      id: json['id'],
      url: json['url'],
      breed: (json['breeds'] as List).isNotEmpty
          ? BreedModel.fromJson((json['breeds'] as List).first)
          : null,
    );
  }
}
