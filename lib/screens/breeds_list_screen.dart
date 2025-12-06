import 'package:flutter/material.dart';
import '../models/breed.dart';
import '../services/cat_api_service.dart';
import '../services/errors.dart';
import 'breed_details_screen.dart';

class BreedsListScreen extends StatefulWidget {
  const BreedsListScreen({super.key});

  @override
  State<BreedsListScreen> createState() => _BreedsListScreenState();
}

class _BreedsListScreenState extends State<BreedsListScreen>
    with AutomaticKeepAliveClientMixin {
  final CatApiService _apiService = CatApiService();
  List<Breed> _breeds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _fetchBreeds() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final breeds = await _apiService.getAllBreeds();
      if (mounted) {
        setState(() {
          _breeds = breeds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = ErrorHandler.getUserMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Breeds'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBreeds,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _breeds.length,
      itemBuilder: (context, index) {
        final breed = _breeds[index];
        return ListTile(
          title: Text(breed.name),
          subtitle: Text(breed.origin),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BreedDetailsScreen(breed: breed),
              ),
            );
          },
        );
      },
    );
  }
}
