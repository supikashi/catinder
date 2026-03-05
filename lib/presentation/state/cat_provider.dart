import 'package:flutter/material.dart';
import '../../domain/entities/cat.dart';
import '../../domain/usecases/get_cats_usecase.dart';
import '../../core/errors.dart';

sealed class CatState {}

class CatLoading extends CatState {}

class CatLoaded extends CatState {
  final Cat currentCat;
  final List<Cat> queue;

  CatLoaded({required this.currentCat, required this.queue});
}

class CatError extends CatState {
  final String message;
  CatError(this.message);
}

class CatProvider extends ChangeNotifier {
  final GetCatsUseCase getCatsUseCase;

  CatState _state = CatLoading();
  CatState get state => _state;

  final List<Cat> _catQueue = [];
  bool _isLoadingBatch = false;
  int _likeCount = 0;

  int get likeCount => _likeCount;

  CatProvider({required this.getCatsUseCase});

  Future<void> initialize() async {
    _state = CatLoading();
    notifyListeners();
    await _loadMoreCats();
    _updateState();
  }

  Future<void> _loadMoreCats() async {
    if (_isLoadingBatch) return;
    _isLoadingBatch = true;

    try {
      final cats = await getCatsUseCase(limit: 5);
      _catQueue.addAll(cats);
    } catch (e) {
      if (_state is! CatLoaded) {
        _state = CatError(
            e is ServerException ? e.message : ErrorMessages.serverError);
        notifyListeners();
      }
    } finally {
      _isLoadingBatch = false;
    }
  }

  void _updateState() {
    if (_catQueue.isNotEmpty) {
      final current = _catQueue.first;
      _state =
          CatLoaded(currentCat: current, queue: List.from(_catQueue.skip(1)));
    } else {
      if (!_isLoadingBatch) {
        _loadMoreCats().then((_) => _updateState());
      }
      if (_state is! CatError) {
        _state = CatLoading();
      }
    }
    notifyListeners();
  }

  void likeCat() {
    _likeCount++;
    _removeCurrentCat();
  }

  void dislikeCat() {
    _removeCurrentCat();
  }

  void _removeCurrentCat() {
    if (_catQueue.isNotEmpty) {
      _catQueue.removeAt(0);
      if (_catQueue.length < 3) {
        _loadMoreCats();
      }
      _updateState();
    }
  }
}
