import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/product_repository.dart';
import '../repository/models/product_repository_state.dart';
import '../model/product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;
  late final Stream<ProductRepositoryState> _repoStream;
  late final StreamSubscription<ProductRepositoryState> _subscription;
  Timer? _staleTimer;

  ProductCubit(this.repository) : super(ProductInitial()) {
    _repoStream = repository.watchProducts();
    _subscription = _repoStream.listen(_onRepoState);
    fetchProducts();
  }

  void fetchProducts({bool forceRefresh = false}) async {
    // Show loading from cache state immediately
    final cacheProducts = repository.cache.products;
    emit(ProductLoaded(
      products: cacheProducts,
      isLoadingCache: true,
      isFetchingNetwork: false,
      isUpToDate: false,
    ));
    try {
      await repository.fetchProducts(forceRefresh: forceRefresh);
      _setupStaleTimer();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _setupStaleTimer() {
    _staleTimer?.cancel();
    final cache = repository.cache;
    final lastUpdated = cache.lastUpdated;
    if (lastUpdated == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(lastUpdated);
    final remaining = Duration(minutes: 2) - elapsed;
    if (remaining.isNegative) {
      // Already stale, fetch immediately
      fetchProducts(forceRefresh: true);
    } else {
      _staleTimer = Timer(remaining, () {
        fetchProducts(forceRefresh: true);
      });
    }
  }

  void _onRepoState(ProductRepositoryState repoState) {
    if (repoState.error != null && repoState.error!.isNotEmpty) {
      emit(ProductError(repoState.error!, products: repoState.products));
    } else {
      emit(ProductLoaded(
        products: repoState.products,
        isLoadingCache: repoState.isLoadingCache,
        isFetchingNetwork: repoState.isFetchingNetwork,
        isUpToDate: repoState.isUpToDate,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    _staleTimer?.cancel();
    return super.close();
  }
}