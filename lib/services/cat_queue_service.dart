import 'package:flutter/material.dart';
import '../models/cat.dart';
import 'cat_api_service.dart';
import 'errors.dart';

sealed class CatQueueItem {}

class CatLoaded extends CatQueueItem {
  final Cat cat;
  CatLoaded(this.cat);
}

class CatLoading extends CatQueueItem {}

class CatError extends CatQueueItem {
  final String message;
  CatError(this.message);
}

class CatQueueService extends ChangeNotifier {
  final CatApiService _apiService;

  final List<Cat> _catQueue = [];
  CatQueueItem _currentItem = CatLoading();
  bool _isLoadingBatch = false;
  bool _isInitializing = false;

  static const int _minQueueSize = 3;
  static const int _batchSize = 10;

  CatQueueService({CatApiService? apiService})
      : _apiService = apiService ?? CatApiService();

  CatQueueItem get currentItem => _currentItem;

  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }

    _isInitializing = true;
    _currentItem = CatLoading();

    try {
      final cats =
          await _apiService.getMultipleCatsWithBreed(limit: _batchSize);

      if (cats.isEmpty) {
        throw Exception(ErrorMessages.serverError);
      }

      _currentItem = CatLoaded(cats.first);
      _catQueue.addAll(cats.skip(1));
      _isInitializing = false;
      notifyListeners();

      _precacheNextImages();
    } catch (e) {
      _currentItem = CatError(ErrorHandler.getUserMessage(e));
      _isInitializing = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getNextCat() async {
    if (_currentItem is! CatLoaded) {
      return;
    }

    if (_catQueue.isEmpty) {
      _currentItem = CatLoading();
      notifyListeners();

      if (_isLoadingBatch) {
        return;
      }
      await _loadCatBatch();
    } else {
      final nextCat = _catQueue.removeAt(0);
      _currentItem = CatLoaded(nextCat);
      notifyListeners();
    }

    if (_catQueue.length < _minQueueSize && !_isLoadingBatch) {
      _loadCatBatch();
    }
  }

  Future<void> retry() async {
    final current = _currentItem;

    if (current is! CatError) {
      return;
    }

    _currentItem = CatLoading();
    notifyListeners();

    try {
      if (_catQueue.isEmpty) {
        final cats =
            await _apiService.getMultipleCatsWithBreed(limit: _batchSize);

        if (cats.isEmpty) {
          throw Exception(ErrorMessages.serverError);
        }

        _currentItem = CatLoaded(cats.first);
        _catQueue.addAll(cats.skip(1));
        notifyListeners();
      } else {
        final nextCat = _catQueue.removeAt(0);
        _currentItem = CatLoaded(nextCat);
        notifyListeners();
      }
    } catch (e) {
      _currentItem = CatError(ErrorHandler.getUserMessage(e));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadCatBatch() async {
    if (_isLoadingBatch) return;

    _isLoadingBatch = true;

    try {
      final cats =
          await _apiService.getMultipleCatsWithBreed(limit: _batchSize);

      _catQueue.addAll(cats);
      _isLoadingBatch = false;

      _precacheNextImages();
    } catch (e) {
      _isLoadingBatch = false;
    }
    if (_catQueue.isEmpty) {
      _currentItem = CatError(ErrorMessages.serverError);
      notifyListeners();
    } else if (_currentItem is CatLoading) {
      final nextCat = _catQueue.removeAt(0);
      _currentItem = CatLoaded(nextCat);
      notifyListeners();
    }
  }

  void _precacheNextImages() {
    final context = _currentContext;
    if (context == null || !context.mounted) return;

    for (final cat in _catQueue) {
      precacheImage(
        NetworkImage(cat.url),
        context,
      )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {},
          )
          .catchError((e) {});
    }
  }

  BuildContext? _currentContext;

  void setContext(BuildContext context) {
    _currentContext = context;
  }

  @override
  void dispose() {
    _apiService.dispose();
    _catQueue.clear();
    super.dispose();
  }
}
