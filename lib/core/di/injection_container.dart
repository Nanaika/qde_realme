import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:qde_realme/core/network/api_client.dart';
import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/core/notifications/notification_handler.dart';
import 'package:qde_realme/core/notifications/notification_service.dart';
import 'package:qde_realme/core/services/analytics_service.dart';
import 'package:qde_realme/core/services/excel_service.dart';
import 'package:qde_realme/core/services/storage_service.dart';
import 'package:qde_realme/core/services/theme_service.dart';
import 'package:qde_realme/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:qde_realme/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qde_realme/features/auth/domain/repositories/auth_repository.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/home/add_sale/add_sale_bloc.dart';
import 'package:qde_realme/features/home/moferate_users/moderate_users_bloc.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/add_item/add_item_bloc.dart';
import '../../features/home/add_item/add_item_remote_datasource.dart';
import '../../features/home/add_item/add_item_repository.dart';
import '../../features/home/add_item/add_item_repository_impl.dart';
import '../../features/home/add_items/add_items_bloc.dart';
import '../../features/home/add_items/add_items_remote_datasource.dart';
import '../../features/home/add_items/add_items_repository.dart';
import '../../features/home/add_items/add_items_repository_impl.dart';
import '../../features/home/add_sale/add_sale_remote_datasource.dart';
import '../../features/home/add_sale/add_sale_repository.dart';
import '../../features/home/add_sale/add_sale_repository_impl.dart';
import '../../features/home/confirm_account/confirm_account_bloc.dart';
import '../../features/home/confirm_account/confirm_account_remote_datasource.dart';
import '../../features/home/confirm_account/confirm_account_repository.dart';
import '../../features/home/confirm_account/confirm_account_repository_impl.dart';
import '../../features/home/moderate_sales/moderate_sales_bloc.dart';
import '../../features/home/moderate_sales/moderate_sales_remote_datasource.dart';
import '../../features/home/moderate_sales/moderate_sales_repository.dart';
import '../../features/home/moderate_sales/moderate_sales_repository_impl.dart';
import '../../features/home/moferate_users/moderate_users_remote_datasource.dart';
import '../../features/home/moferate_users/moderate_users_repository.dart';
import '../../features/home/moferate_users/moderate_users_repository_impl.dart';
import '../../features/home/slave_data/slave_data_remote_datasource.dart';
import '../../features/home/slave_data/slave_data_repository.dart';
import '../../features/home/slave_data/slave_data_repository_impl.dart';
import '../services/remote_config_service.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
    firebaseInitialized = true;
  } catch (e) {}
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(() => FlutterLocalNotificationsPlugin());

  // Network
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt()));
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Services
  getIt.registerLazySingleton<StorageService>(() => StorageServiceImpl(getIt()));
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsServiceImpl());
  getIt.registerLazySingleton<ThemeService>(() => ThemeServiceImpl(getIt()));

  if (firebaseInitialized) {
    getIt.registerLazySingleton<NotificationHandler>(() => NotificationHandler(getIt()));
    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(
        localNotifications: getIt(),
        firebaseMessaging: getIt<FirebaseMessaging>(),
        handler: getIt(),
      ),
    );
  }
  getIt.registerSingleton(RemoteConfigService());
  getIt.registerSingleton(ExcelService());

  // Auth Feature
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //Confirm account

  getIt.registerLazySingleton<ConfirmAccountRemoteDataSource>(() => ConfirmAccountRemoteDataSourceImpl());
  getIt.registerLazySingleton<ConfirmAccountRepository>(
    () => ConfirmAccountRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //add sale
  getIt.registerLazySingleton<AddSaleRemoteDataSource>(() => AddSaleRemoteDataSourceImpl());
  getIt.registerLazySingleton<AddSaleRepository>(
        () => AddSaleRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //slave data
  getIt.registerLazySingleton<SlaveDataRemoteDataSource>(() => SlaveDataRemoteDataSourceImpl());
  getIt.registerLazySingleton<SlaveDataRepository>(
        () => SlaveDataRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //add item
  getIt.registerLazySingleton<AddItemRemoteDataSource>(() => AddItemRemoteDataSourceImpl());
  getIt.registerLazySingleton<AddItemRepository>(
        () => AddItemRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //add items
  getIt.registerLazySingleton<AddItemsRemoteDataSource>(() => AddItemsRemoteDataSourceImpl());
  getIt.registerLazySingleton<AddItemsRepository>(
        () => AddItemsRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );

  //moderate users
  getIt.registerLazySingleton<ModerateUsersRemoteDataSource>(() => ModerateUsersRemoteDataSourceImpl());
  getIt.registerLazySingleton<ModerateUsersRepository>(
        () => ModerateUsersRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );
  //moderate sales
  getIt.registerLazySingleton<ModerateSalesRemoteDataSource>(() => ModerateSalesRemoteDataSourceImpl());
  getIt.registerLazySingleton<ModerateSalesRepository>(
        () => ModerateSalesRepositoryImpl(remoteDataSource: getIt(), networkInfo: getIt()),
  );


  getIt.registerLazySingleton(() => AuthBloc(repository: getIt()));
  getIt.registerLazySingleton(() => ConfirmAccountBloc(repository: getIt()));
  getIt.registerLazySingleton(() => AddSaleBloc(repository: getIt()));
  getIt.registerLazySingleton(() => SlaveDataBloc(repository: getIt()));
  getIt.registerLazySingleton(() => AddItemBloc(repository: getIt()));
  getIt.registerLazySingleton(() => AddItemsBloc(repository: getIt(), excelService: getIt()));
  getIt.registerLazySingleton(() => ModerateUsersBloc(repository: getIt()));
  getIt.registerLazySingleton(() => ModerateSalesBloc(repository: getIt()));
}
