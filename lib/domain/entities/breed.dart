import 'package:equatable/equatable.dart';

class Breed extends Equatable {
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

  @override
  List<Object?> get props => [name, temperament, description, origin];
}
