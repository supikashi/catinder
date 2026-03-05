import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'swipe_screen.dart';
import 'breeds_list_screen.dart';
import '../state/cat_provider.dart';
import '../state/auth_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catinder'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthProvider>().logout();
              },
            ),
            Consumer<CatProvider>(
              builder: (context, catProvider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        '${catProvider.likeCount}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.swipe), text: 'Swipe'),
              Tab(icon: Icon(Icons.list), text: 'Breeds'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SwipeScreen(),
            BreedsListScreen(),
          ],
        ),
      ),
    );
  }
}
