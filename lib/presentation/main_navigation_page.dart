import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth/cubit/auth_cubit.dart';
import 'auth/login_page.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard/pages/dashboard_page.dart';
import 'bookings/pages/bookings_page.dart';
import 'tenants/pages/tenants_page.dart';
import 'profile/pages/profile_page.dart';
import 'bookings/bloc/bookings_bloc.dart';
import 'bookings/bloc/bookings_state.dart';
import 'profile/widgets/add_hostel_sheet.dart';
import 'profile/cubit/hostel_cubit.dart';
import 'profile/cubit/hostel_state.dart';
import 'dashboard/bloc/dashboard_bloc.dart';
import 'dashboard/bloc/dashboard_event.dart';
import 'community/pages/communities_hub_page.dart';
import 'community/pages/announcement_page.dart';
import 'notices/cubit/notice_cubit.dart';
import 'tenants/bloc/tenants_bloc.dart';
import 'tenants/bloc/tenants_event.dart';
import 'maintenance/cubit/maintenance_cubit.dart';
import 'staff/cubit/staff_cubit.dart';
import 'bookings/bloc/bookings_event.dart';
import '../injection_container.dart';
import '../core/socket/socket_service.dart';
import '../core/services/notification_service.dart';
import '../core/utils/logger.dart';
import '../../core/widgets/bouncing_wrapper.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  StreamSubscription? _bookingSubscription;
  StreamSubscription? _refreshSubscription;
  String? _currentHostelId;
  
  // Cache pages to prevent constant recreation and performance degradation
  final List<Widget> _pages = [];
  String? _lastHostelIdForPages;

  @override
  void initState() {
    super.initState();
    _bookingSubscription = sl<SocketService>().bookingStream.listen(_onNewBooking);
    // Removed redundant _refreshSubscription as DashboardBloc already listens to this stream
  }

  void _initializePages(String hostelId, String hostelName) {
    _lastHostelIdForPages = hostelId;
    _pages.clear();
    _pages.addAll([
      DashboardPage(key: ValueKey('dash_$hostelId')),
      BookingsPage(key: ValueKey('book_$hostelId')),
      CommunitiesHubPage(
        key: ValueKey('comm_$hostelId'),
        hostelId: hostelId,
        hostelName: hostelName,
      ),
      TenantsPage(key: ValueKey('tenant_$hostelId')),
      const ProfilePage(),
    ]);
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  void _onNewBooking(Map<String, dynamic> data) {
    if (!mounted) return;

    final tenantName = data['tenantName'] ?? 'New Tenant';
    final sharingType = data['sharingType'] ?? '';
    final amount = data['amount'] ?? 0;

    sl<NotificationService>().showNotification(
      id: DateTime.now().millisecond,
      title: 'New Booking Found! 🎁',
      body: '$tenantName booked a $sharingType room (₹$amount)',
      payload: 'booking',
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Booking Found!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  Text('$tenantName booked a $sharingType room (₹$amount)', style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 1),
        ),
      ),
    );

    if (_currentIndex == 0 && _currentHostelId != null) {
      context.read<DashboardBloc>().add(FetchDashboardData(_currentHostelId!));
    }
  }

  void _setupSocket(String hostelId) {
    if (_currentHostelId == hostelId) return;

    if (_currentHostelId != null) {
      sl<SocketService>().leaveCommunity(_currentHostelId!);
    }

    _currentHostelId = hostelId;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthSuccess) {
      sl<SocketService>().joinCommunity(hostelId, authState.owner.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<HostelCubit, HostelState>(
          listenWhen: (previous, current) {
            if (previous is! HostelLoaded || current is! HostelLoaded) return true;
            final prevHostelId = previous.hostels[previous.selectedHostelIndex].id;
            final currHostelId = current.hostels[current.selectedHostelIndex].id;
            return prevHostelId != currHostelId;
          },
          listener: (context, state) {
            if (state is HostelLoaded && state.hostels.isNotEmpty) {
              final hostelId = state.hostels[state.selectedHostelIndex].id;
              _setupSocket(hostelId);
              
              AppLogger.info('🔄 Hostel changed to $hostelId. Triggering initial sync.');
              
              // Trigger initial data fetch for global blocs when hostel changes
              context.read<DashboardBloc>().add(FetchDashboardData(hostelId));
              context.read<BookingsBloc>().add(FetchBookings());
              context.read<TenantsBloc>().add(const FetchTenants(isRefresh: true));
              context.read<MaintenanceCubit>().loadIssues(hostelId: hostelId);
              context.read<NoticeCubit>().loadNotices(hostelId: hostelId);
              context.read<StaffCubit>().loadStaff(hostelId);
            }
          },
        ),
      ],
      child: BlocBuilder<HostelCubit, HostelState>(
        buildWhen: (previous, current) {
          if (previous is! HostelLoaded || current is! HostelLoaded) return true;
          return previous.selectedHostelIndex != current.selectedHostelIndex ||
                 previous.hostels.length != current.hostels.length;
        },
        builder: (context, hostelState) {
          if (hostelState is HostelInitial || hostelState is HostelLoading) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            );
          }

          if (hostelState is HostelError) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 16.h),
                    Text('Error: ${hostelState.message}', textAlign: TextAlign.center),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<HostelCubit>().getHostels(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (hostelState is HostelLoaded) {
            if (hostelState.hostels.isEmpty) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work_outlined, size: 80.sp, color: AppColors.greyText),
                        SizedBox(height: 16.h),
                        Text('No Hostels Found', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8.h),
                        Text('You need to add a hostel to start managing it.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.greyText)),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const AddHostelSheet(),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h)),
                          child: const Text('Add Your First Hostel', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
            final hostelName = hostelState.hostels[hostelState.selectedHostelIndex].name;
            _initializePages(hostelId, hostelName);

            return BlocListener<BookingsBloc, BookingsState>(
              listener: (context, state) {
                if (state.status == BookingsStatus.success && 
                   (state.successMessage?.contains('completed') ?? false)) {
                  context.read<DashboardBloc>().add(FetchDashboardData(hostelId));
                }
              },
              child: Scaffold(
                body: IndexedStack(index: _currentIndex, children: _pages),
                bottomNavigationBar: _buildBottomNav(context, hostelId),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String? hostelId) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 4.h,
        top: 8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildNavItem(context, 0, Icons.home_rounded, 'Dashboard', hostelId)),
          Expanded(child: _buildNavItem(context, 1, Icons.library_books_outlined, 'Bookings', hostelId)),
          Expanded(child: _buildCentralNavItem(context, 2, 'Communities', hostelId)),
          Expanded(child: _buildNavItem(context, 3, Icons.person_search_outlined, 'Tenants', hostelId)),
          Expanded(child: _buildNavItem(context, 4, Icons.person_outline_rounded, 'Profile', hostelId)),
        ],
      ),
    );
  }

  Widget _buildCentralNavItem(BuildContext context, int index, String label, String? hostelId) {
    final isSelected = _currentIndex == index;
    return BouncingWrapper(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0 && hostelId != null) {
          context.read<DashboardBloc>().add(FetchDashboardData(hostelId, forceRefresh: true));
        }
      },
      scaleFactor: 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(Icons.forum_rounded, color: Colors.white, size: 26.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String? hostelId) {
    final isSelected = _currentIndex == index;
    return BouncingWrapper(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0 && hostelId != null) {
          context.read<DashboardBloc>().add(FetchDashboardData(hostelId, forceRefresh: true));
        }
      },
      scaleFactor: 0.90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.greyText, size: 26.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : AppColors.greyText,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

