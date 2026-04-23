import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/main_navigation_page.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/registration_personal_page.dart';
import 'presentation/profile/cubit/hostel_cubit.dart';
import 'presentation/bookings/bloc/bookings_bloc.dart';
import 'presentation/dashboard/bloc/dashboard_bloc.dart';
import 'presentation/tenants/bloc/tenants_bloc.dart';
import 'presentation/maintenance/cubit/maintenance_cubit.dart';
import 'presentation/notices/cubit/notice_cubit.dart';
import 'presentation/staff/cubit/staff_cubit.dart';
import 'presentation/payments/cubit/payment_cubit.dart';

import 'domain/repositories/room_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/repositories/tenant_repository.dart';
import 'domain/repositories/maintenance_repository.dart';
import 'domain/repositories/notice_repository.dart';
import 'domain/repositories/staff_repository.dart';

import 'core/services/token_storage.dart';
import 'core/services/notification_service.dart';
import 'core/utils/logger.dart';

import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global Error Handling Barrier
  FlutterError.onError = (details) {
    AppLogger.error('❌ FLUTTER FRAMEWORK ERROR: ${details.exception}', details.exception, details.stack);
  };
  
  // Custom Error Widget for Production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'An unexpected error occurred. Our team has been notified.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Restart logic or simple back
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('❌ ASYNC/PLATFORM ERROR: $error', error, stack);
    return true;
  };

  await di.init();
  await di.sl<NotificationService>().init();
  await di.sl<NotificationService>().requestPermissions();
  
  AppLogger.info('Stay India Owner App Initialized');
  
  runApp(const StayIndiaOwnerApp());
}

class StayIndiaOwnerApp extends StatelessWidget {
  const StayIndiaOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthCubit>()..loadCurrentUser(),
        ),
        BlocProvider(
          create: (context) => di.sl<HostelCubit>()..getHostels(),
        ),
        BlocProvider(
          create: (context) => di.sl<BookingsBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<DashboardBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TenantsBloc>(),
        ),
        BlocProvider(create: (context) => di.sl<MaintenanceCubit>()),
        BlocProvider(create: (context) => di.sl<NoticeCubit>()),
        BlocProvider(create: (context) => di.sl<StaffCubit>()),
        BlocProvider(create: (context) => di.sl<PaymentCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Stay India Owner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        // Only rebuild AuthGate for major state changes
        return current is AuthInitial || 
               current is AuthSuccess || 
               current is Unauthenticated ||
               (previous is AuthInitial && current is AuthLoading);
      },
      builder: (context, state) {
        AppLogger.debug('AuthGate: Building with state: $state');
        if (state is AuthInitial || (state is AuthLoading && state is! AuthSuccess)) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150.h,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.apartment_rounded,
                      size: 120.sp,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  SizedBox(height: 48.h),
                  const CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthRestorationError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 80.sp, color: Colors.grey),
                    SizedBox(height: 32.h),
                    Text(
                      'Connection Error',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'We couldn\'t restore your session. Please check your internet connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
                    ),
                    SizedBox(height: 40.h),
                    ElevatedButton(
                      onPressed: () => context.read<AuthCubit>().loadCurrentUser(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                    TextButton(
                      onPressed: () => context.read<AuthCubit>().logout(),
                      child: Text('Go to Login', style: TextStyle(color: AppColors.greyText, fontSize: 14.sp)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (state is AuthSuccess) {
          final shouldRegister = state.isNewUser || !state.owner.isProfileComplete;
          return shouldRegister 
            ? const RegistrationPersonalPage() 
            : const MainNavigationPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
