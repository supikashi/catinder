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
  Future<void>? _loadingFuture;
  int _likeCount = 0;

  int get likeCount => _likeCount;

  CatProvider({required this.getCatsUseCase});

  Future<void> initialize() async {
    _state = CatLoading();
    notifyListeners();
    await _loadMoreCats();
  }

  Future<void> _loadMoreCats() {
    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = _fetchCats();
    return _loadingFuture!;
  }

  Future<void> _fetchCats() async {
    try {
      final cats = await getCatsUseCase(limit: 5);
      _catQueue.addAll(cats);
      _updateState();
    } catch (e) {
      if (_state is! CatLoaded) {
        _state = CatError(
            e is ServerException ? e.message : ErrorMessages.serverError);
        notifyListeners();
      }
    } finally {
      _loadingFuture = null;
    }
  }

  void _updateState() {
    if (_catQueue.isNotEmpty) {
      final current = _catQueue.first;
      _state =
          CatLoaded(currentCat: current, queue: List.from(_catQueue.skip(1)));
    } else {
      if (_loadingFuture == null) {
        _loadMoreCats();
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

  void resetLikes() {
    _likeCount = 0;
    notifyListeners();
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
