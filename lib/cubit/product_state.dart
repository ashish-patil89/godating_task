import '../model/product.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool isLoadingCache;
  final bool isFetchingNetwork;
  final bool isUpToDate;
  ProductLoaded({
    required this.products,
    required this.isLoadingCache,
    required this.isFetchingNetwork,
    required this.isUpToDate,
  });
}

class ProductError extends ProductState {
  final String message;
  final List<Product> products;
  ProductError(this.message, {this.products = const []});
}