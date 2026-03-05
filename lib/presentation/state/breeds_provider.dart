import 'package:flutter/material.dart';
import '../../domain/entities/breed.dart';
import '../../domain/usecases/get_breeds_usecase.dart';
import '../../core/errors.dart';

class BreedsProvider extends ChangeNotifier {
  final GetBreedsUseCase getBreedsUseCase;

  List<Breed> _breeds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Breed> get breeds => _breeds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BreedsProvider({required this.getBreedsUseCase});

  Future<void> loadBreeds() async {
    if (_breeds.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _breeds = await getBreedsUseCase();
    } catch (e) {
      _errorMessage =
          e is ServerException ? e.message : ErrorMessages.serverError;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
