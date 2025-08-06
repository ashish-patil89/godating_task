import 'dart:async';

import '../model/product.dart';
import 'models/product_repository_state.dart';

class ProductRepository {
  final InMemoryProductCache _cache;
  final FakeRemoteProductApi _remoteApi;
  final StreamController<ProductRepositoryState> _controller =
      StreamController<ProductRepositoryState>.broadcast();

  ProductRepository(this._cache, this._remoteApi);

  InMemoryProductCache get cache => _cache;

  Future<List<Product>> fetchProducts({bool forceRefresh = false}) async {
    /// Show data from cache initially.
    _controller.add(
      ProductRepositoryState(
        products: _cache.products,
        isLoadingCache: true,
        isFetchingNetwork: false,
        isUpToDate: false,
        error: null,
      ),
    );

    /// Added some latency between cache and network call
    /// to see changes in UI.
    await Future.delayed(const Duration(seconds: 3));

    /// If cache is empty or stale or forceRefresh is true, fetch from network.
    if (_cache.isEmpty || _cache.isStale || forceRefresh) {
      /// Updating message in UI.
      _controller.add(
        ProductRepositoryState(
          products: _cache.products,
          isLoadingCache: false,
          isFetchingNetwork: true,
          isUpToDate: false,
          error: null,
        ),
      );
      try {
        final products = await _remoteApi.fetchProducts();

        /// To save the updated products in cache.
        _cache.saveProducts(products);
        _controller.add(
          ProductRepositoryState(
            products: products,
            isLoadingCache: false,
            isFetchingNetwork: false,
            isUpToDate: true,
            error: null,
          ),
        );
        return products;
      } catch (e) {
        /// If API fails then show cache products.
        _controller.add(
          ProductRepositoryState(
            products: _cache.products,
            isLoadingCache: false,
            isFetchingNetwork: false,
            isUpToDate: false,
            error: e.toString(),
          ),
        );
        return _cache.products;
      }
    } else {
      /// Show if data seems up to date.
      _controller.add(
        ProductRepositoryState(
          products: _cache.products,
          isLoadingCache: false,
          isFetchingNetwork: false,
          isUpToDate: true,
          error: null,
        ),
      );
      return _cache.products;
    }
  }

  Stream<ProductRepositoryState> watchProducts() => _controller.stream;
}

/// Data source for cache.
class InMemoryProductCache {
  List<Product> _products = [];
  DateTime? _lastUpdated;

  List<Product> get products => _products;
  DateTime? get lastUpdated => _lastUpdated;

  void saveProducts(List<Product> products) {
    _products = products;
    _lastUpdated = DateTime.now();
  }

  void clear() {
    _products = [];
    _lastUpdated = null;
  }

  bool get isEmpty => _products.isEmpty;
  bool get isStale {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inMinutes > 5;
  }
}

/// Data source for network.
class FakeRemoteProductApi {
  final bool shouldFail;
  FakeRemoteProductApi({this.shouldFail = false});

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(seconds: 2));
    if (shouldFail) {
      throw Exception('Network error');
    }
    final now = DateTime.now();
    return [
      Product(id: '1', name: 'Apple', price: 220, updatedAt: now),
      Product(id: '2', name: 'Banana', price: 80, updatedAt: now),
      Product(id: '3', name: 'Orange', price: 120, updatedAt: now),
      Product(id: '3', name: 'Mango', price: 60, updatedAt: now),
      Product(id: '3', name: 'Pinapple', price: 25, updatedAt: now),
      Product(id: '3', name: 'Grapes', price: 50, updatedAt: now),
    ];
  }
}
