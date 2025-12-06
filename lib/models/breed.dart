class Breed {
  final String name;
  final String temperament;
  final String description;
  final String origin;

  const Breed({
    required this.name,
    required this.temperament,
    required this.description,
    required this.origin,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      name: json['name'] ?? 'Unknown',
      temperament: json['temperament'] ?? 'Unknown',
      description: json['description'] ?? 'No description available.',
      origin: json['origin'] ?? 'Unknown',
    );
  }
}
