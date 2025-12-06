import 'package:flutter/material.dart';
import '../models/cat.dart';
import '../models/breed.dart';

class CatDetailsScreen extends StatefulWidget {
  final Cat cat;

  const CatDetailsScreen({super.key, required this.cat});

  @override
  State<CatDetailsScreen> createState() => _CatDetailsScreenState();
}

class _CatDetailsScreenState extends State<CatDetailsScreen> {
  bool _imageLoadError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat.breed?.name ?? 'A Cute Cat'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_imageLoadError)
              Hero(
                tag: 'cat_${widget.cat.id}',
                child: Image.network(
                  widget.cat.url,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _imageLoadError = true;
                        });
                      }
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.cat.breed != null) {
      return _buildBreedInfo(context, widget.cat.breed!);
    }
    return _buildNoBreedInfo(context);
  }

  Widget _buildBreedInfo(BuildContext context, Breed breed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Origin', breed.origin),
        const SizedBox(height: 16),
        _buildSection(context, 'Temperament', breed.temperament),
        const SizedBox(height: 16),
        _buildSection(context, 'Description', breed.description),
      ],
    );
  }

  Widget _buildNoBreedInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Just a cute cat!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text('No breed information available for this cat.'),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }
}
