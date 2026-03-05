import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/breeds_provider.dart';
import 'breed_details_screen.dart';

class BreedsListScreen extends StatefulWidget {
  const BreedsListScreen({super.key});

  @override
  State<BreedsListScreen> createState() => _BreedsListScreenState();
}

class _BreedsListScreenState extends State<BreedsListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<BreedsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadBreeds(),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        final breeds = provider.breeds;

        if (breeds.isEmpty) {
          return const Center(child: Text('No breeds found'));
        }

        return ListView.builder(
          itemCount: breeds.length,
          itemBuilder: (context, index) {
            final breed = breeds[index];
            return ListTile(
              title: Text(breed.name),
              subtitle: Text(breed.origin),
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
      },
    );
  }
}
