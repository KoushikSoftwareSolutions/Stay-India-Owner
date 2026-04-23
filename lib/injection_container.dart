import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'core/services/token_storage.dart';
import 'core/constants/api_constants.dart';
import 'core/socket/socket_service.dart';
import 'core/services/notification_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/hostel_repository.dart';
import 'domain/repositories/booking_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'domain/repositories/food_menu_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/tenant_repository.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/repositories/owner_community_repository.dart';
import 'domain/repositories/tenant_detail_repository.dart';
import 'domain/repositories/complaints_repository.dart';
import 'domain/repositories/notice_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/repositories/maintenance_repository.dart';
import 'domain/repositories/staff_repository.dart';
import 'domain/repositories/document_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'data/data_sources/auth_remote_data_source.dart';
import 'data/data_sources/dashboard_remote_data_source.dart';
import 'data/data_sources/hostel_remote_data_source.dart';
import 'data/data_sources/booking_remote_data_source.dart';
import 'data/data_sources/room_remote_data_source.dart';
import 'data/data_sources/food_menu_remote_data_source.dart';
import 'data/data_sources/settings_remote_data_source.dart';
import 'data/data_sources/tenant_remote_data_source.dart';
import 'data/data_sources/community_remote_data_source.dart';
import 'data/data_sources/owner_community_remote_data_source.dart';
import 'data/data_sources/tenant_detail_remote_data_source.dart';
import 'data/data_sources/complaints_remote_data_source.dart';
import 'data/data_sources/notice_remote_data_source.dart';
import 'data/data_sources/payment_remote_data_source.dart';
import 'data/data_sources/maintenance_remote_data_source.dart';
import 'data/data_sources/staff_remote_data_source.dart';
import 'data/data_sources/document_remote_data_source.dart';
import 'data/data_sources/user_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'data/repositories/hostel_repository_impl.dart';
import 'data/repositories/booking_repository_impl.dart';
import 'data/repositories/room_repository_impl.dart';
import 'data/repositories/food_menu_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/repositories/tenant_repository_impl.dart';
import 'data/repositories/community_repository_impl.dart';
import 'data/repositories/owner_community_repository_impl.dart';
import 'data/repositories/tenant_detail_repository_impl.dart';
import 'data/repositories/complaints_repository_impl.dart';
import 'data/repositories/notice_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'data/repositories/maintenance_repository_impl.dart';
import 'data/repositories/staff_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';
import 'core/utils/logger.dart';
import 'core/network/error_interceptor.dart';
import 'core/network/connectivity_interceptor.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/profile/cubit/hostel_cubit.dart';
import 'presentation/profile/cubit/room_cubit.dart';
import 'presentation/profile/cubit/food_menu_cubit.dart';
import 'presentation/profile/cubit/settings_cubit.dart';
import 'presentation/community/cubit/community_cubit.dart';
import 'presentation/community/cubit/owner_community_cubit.dart';
import 'presentation/tenants/cubit/tenant_detail_cubit.dart';
import 'presentation/tenants/cubit/complaints_cubit.dart';
import 'presentation/notices/cubit/notice_cubit.dart';
import 'presentation/payments/cubit/payment_cubit.dart';
import 'presentation/maintenance/cubit/maintenance_cubit.dart';
import 'presentation/staff/cubit/staff_cubit.dart';
import 'presentation/auth/cubit/document_cubit.dart';
import 'presentation/community/cubit/announcement_cubit.dart';
import 'presentation/bookings/bloc/bookings_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';
import 'presentation/tenants/bloc/tenants_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory(() => AuthCubit(authRepository: sl(), tokenStorage: sl()));
  sl.registerFactory(() => HostelCubit(hostelRepository: sl()));
  sl.registerFactory(() => RoomCubit(roomRepository: sl()));
  sl.registerFactory(() => FoodMenuCubit(foodMenuRepository: sl()));
  sl.registerFactory(() => SettingsCubit(settingsRepository: sl()));
  sl.registerFactory(() => CommunityCubit(communityRepository: sl(), socketService: sl()));
  sl.registerFactory(() => OwnerCommunityCubit(ownerCommunityRepository: sl()));
  sl.registerFactory(() => TenantDetailCubit(tenantDetailRepository: sl()));
  sl.registerFactory(() => ComplaintsCubit(complaintsRepository: sl()));
  sl.registerFactory(() => NoticeCubit(noticeRepository: sl()));
  sl.registerFactory(() => PaymentCubit(paymentRepository: sl()));
  sl.registerFactory(() => MaintenanceCubit(maintenanceRepository: sl()));
  sl.registerFactory(() => StaffCubit(staffRepository: sl()));
  sl.registerFactory(() => DocumentCubit(documentRepository: sl()));
  sl.registerFactory(() => AnnouncementCubit(communityRepository: sl()));
  sl.registerFactory(() => BookingsBloc(repository: sl(), roomRepository: sl()));
  sl.registerFactory(() => DashboardBloc(
    roomRepository: sl(),
    dashboardRepository: sl(),
    socketService: sl(),
  ));
  sl.registerFactory(() => TenantsBloc(
    tenantRepository: sl(),
  ));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HostelRepository>(
    () => HostelRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FoodMenuRepository>(
    () => FoodMenuRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OwnerCommunityRepository>(
    () => OwnerCommunityRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TenantDetailRepository>(
    () => TenantDetailRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NoticeRepository>(
    () => NoticeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton<HostelRemoteDataSource>(
    () => HostelRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<FoodMenuRemoteDataSource>(
    () => FoodMenuRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TenantRemoteDataSource>(
    () => TenantRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<OwnerCommunityRemoteDataSource>(
    () => OwnerCommunityRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TenantDetailRemoteDataSource>(
    () => TenantDetailRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ComplaintsRemoteDataSource>(
    () => ComplaintsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NoticeRemoteDataSource>(
    () => NoticeRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );

  // Services
  sl.registerLazySingleton(() => TokenStorage(
        storage: sl<FlutterSecureStorage>(),
      ));

  // Socket
  sl.registerLazySingleton<SocketService>(() {
    final socketBaseUrl = ApiConstants.baseUrl.endsWith('/api') 
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 4) 
        : ApiConstants.baseUrl;
    return SocketService(baseUrl: socketBaseUrl)..connect();
  });

  // Notification Service
  sl.registerLazySingleton(() => NotificationService());

  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ));

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    
    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sl<TokenStorage>().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Sync with stayindia's successful header handling
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
          } else {
            options.headers['Content-Type'] ??= 'application/json';
          }
          options.headers['Accept'] = 'application/json';

          AppLogger.debug('[REQUEST] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            AppLogger.warning('🛑 Session expired (401). Logging out...');
            sl<AuthCubit>().logout();
          } else if (e.response?.statusCode == 403) {
            AppLogger.warning('🚫 Access forbidden (403). Possible permission issue.');
          }
          return handler.next(e);
        },
      ),
      ErrorInterceptor(),
    ]);
    
    return dio;
  });
}
