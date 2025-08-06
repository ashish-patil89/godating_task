import 'package:flutter/material.dart';

import 'repository/product_repository.dart';
import 'ui/product_list_screen.dart';

void main() {
  final cache = InMemoryProductCache();
  final remoteApi = FakeRemoteProductApi();
  final repository = ProductRepository(cache, remoteApi);
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final ProductRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProductListScreen(repository: repository),
    );
  }
}
