import '../../model/product.dart';


class ProductRepositoryState {
  final List<Product> products;
  final bool isLoadingCache;
  final bool isFetchingNetwork;
  final bool isUpToDate;
  final String? error;

  ProductRepositoryState({
    required this.products,
    required this.isLoadingCache,
    required this.isFetchingNetwork,
    required this.isUpToDate,
    this.error,
  });
}
