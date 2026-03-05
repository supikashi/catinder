import '../../domain/entities/breed.dart';

class BreedModel extends Breed {
  const BreedModel({
    required super.name,
    required super.temperament,
    required super.description,
    required super.origin,
  });

  factory BreedModel.fromJson(Map<String, dynamic> json) {
    return BreedModel(
      name: json['name'] ?? 'Unknown',
      temperament: json['temperament'] ?? 'Unknown',
      description: json['description'] ?? 'No description available.',
      origin: json['origin'] ?? 'Unknown',
    );
  }
}
