import 'breed.dart';

class Cat {
  final String id;
  final String url;
  final Breed? breed;

  const Cat({
    required this.id,
    required this.url,
    this.breed,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'],
      url: json['url'],
      breed: (json['breeds'] as List).isNotEmpty
          ? Breed.fromJson((json['breeds'] as List).first)
          : null,
    );
  }
}
