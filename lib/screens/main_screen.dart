import 'package:flutter/material.dart';
import 'swipe_screen.dart';
import 'breeds_list_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catinder'),
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
