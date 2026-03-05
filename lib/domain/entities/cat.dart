import 'package:equatable/equatable.dart';
import 'breed.dart';

class Cat extends Equatable {
  final String id;
  final String url;
  final Breed? breed;

  const Cat({
    required this.id,
    required this.url,
    this.breed,
  });

  @override
  List<Object?> get props => [id, url, breed];
}
