import 'package:flutter/foundation.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/category/category_repository.dart';
import '../data/repositories/customer/customer_repository.dart';
import '../data/repositories/invoice/invoice_repository.dart';
import '../data/repositories/product/product_repository.dart';
import '../data/repositories/stock/stock_repository.dart';
import '../data/repositories/supplier/supplier_repository.dart';
import '../data/services/auth_service.dart';
import '../data/services/image_picker/image_picker_service.dart';
import '../data/services/injector/injector_service.dart';

import '../data/services/http_service.dart';
import '../data/services/jwt/jwt_service.dart';
import '../data/services/pocket_base/pocket_base.dart';
import '../data/services/storage/cookie_storage_service_imp.dart';
import '../data/services/storage/secure_storage_storage_service_imp.dart';
import '../data/services/storage/storage_service.dart';
import '../ui/view_models/customer_view_model.dart';
import '../ui/view_models/home_view_model.dart';
import '../ui/view_models/order_view_model.dart';
import '../ui/view_models/stock_view_model.dart';
import '../ui/view_models/supplier_view_model.dart';

class Providers {
  static Future<void> setupControllers() async {
    // ===== Serviços =====

    final pbService = PocketBaseService.instance;

    injector.registerLazySingleton<HttpService>(() => HttpServiceImpl());

    injector.registerLazySingleton<StorageService>(
      () =>
          kIsWeb ? CookieStorageServiceImp() : SecureStorageStorageServiceImp(),
    );

    injector.registerFactory<JwtService>(() => JwtServiceImpl());

    injector.registerFactory<ImagePickerService>(() => ImagePickerService());

    injector.registerLazySingleton<AuthService>(
      () => AuthServiceImplPocketBase(
        SecureStorageStorageServiceImp(),
        injector.get<JwtService>(),
        pbService,
      ),
    );

    // ===== Repositórios =====

    injector.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(injector.get<AuthService>()),
    );

    injector.registerFactory<CategoryRepository>(
      () => CategoryRepositoryImpl(pbService),
    );

    injector.registerFactory<ProductRepository>(
      () => ProductRepositoryImpl(pbService, injector.get<HttpService>()),
    );

    injector.registerFactory<StockRepository>(
      () => StockRepositoryImpl(pbService),
    );

    injector.registerFactory<CustomerRepository>(
      () => CustomerRepositoryImpl(pbService),
    );

    injector.registerFactory<SupplierRepository>(
      () => SupplierRepositoryImpl(pbService),
    );

    injector.registerFactory<InvoiceRepository>(
      () => InvoiceRepositoryImpl(pbService),
    );

    // ===== ViewModels =====

    injector.registerLazySingleton<HomeViewModel>(
      () => HomeViewModel(injector.get<AuthRepository>()),
    );

    injector.registerLazySingleton<StockViewModel>(() => StockViewModel());
    injector.registerLazySingleton<SupplierViewModel>(
      () => SupplierViewModel(),
    );
    injector.registerLazySingleton<CustomerViewModel>(
      () => CustomerViewModel(),
    );
    injector.registerLazySingleton<OrderViewModel>(() => OrderViewModel());
  }
}
