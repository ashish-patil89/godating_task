import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../repository/product_repository.dart';

class ProductListScreen extends StatelessWidget {
  final ProductRepository repository;
  const ProductListScreen({super.key, required this.repository});

  String _statusText(ProductState state) {
    if (state is ProductLoading) return 'Loading...';
    if (state is ProductLoaded) {
      if (state.isLoadingCache) return 'Loading from cache...';
      if (state.isFetchingNetwork) return 'Fetching from network...';
      if (state.isUpToDate) return 'Up-to-date';
    }
    if (state is ProductError) return 'Error in fetching products';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(repository),
      child: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError && state.message.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          List products = [];
          if (state is ProductLoaded) {
            products = state.products;
          } else if (state is ProductError) {
            products = state.products;
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Products')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _statusText(state),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              context.read<ProductCubit>().fetchProducts(
                                forceRefresh: true,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              context.read<ProductCubit>().fetchProducts(
                                forceError: true,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: (state is ProductLoading)
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                      ? const Center(child: Text('No products'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                              ),
                              trailing: Text(
                                'Updated: ${product.updatedAt.hour}:${product.updatedAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
