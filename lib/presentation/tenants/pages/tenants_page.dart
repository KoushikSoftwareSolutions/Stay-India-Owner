import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../../../injection_container.dart';
import '../bloc/tenants_bloc.dart';
import '../bloc/tenants_event.dart';
import '../bloc/tenants_state.dart';
import '../widgets/tenant_card.dart';
import '../widgets/maintenance_tab_view.dart';
import '../widgets/notices_tab_view.dart';
import '../../notices/pages/give_notice_page.dart';
import '../../maintenance/cubit/maintenance_cubit.dart';
import '../../notices/cubit/notice_cubit.dart';
import '../../../core/constants/api_constants.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../staff/cubit/staff_cubit.dart';
import 'add_tenant_page.dart';
import '../widgets/past_tenants_sheet.dart';
import '../../common_widgets/shimmer_loading.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final bloc = context.read<TenantsBloc>();
      if (!bloc.state.isPaginationLoading && !bloc.state.hasReachedMax) {
        bloc.add(const FetchTenants(isRefresh: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 200) {
              final bloc = context.read<TenantsBloc>();
              if (!bloc.state.isPaginationLoading &&
                  !bloc.state.hasReachedMax) {
                bloc.add(const FetchTenants(isRefresh: false));
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  height: 80.h,
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    alignment: Alignment.center,
                    child: _buildTabBar(),
                  ),
                ),
              ),
              ..._buildSliverContent(context),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  List<Widget> _buildSliverContent(BuildContext context) {
    if (_selectedTabIndex == 1) {
      return [const SliverFillRemaining(child: MaintenanceTabView())];
    }
    if (_selectedTabIndex == 2) {
      return [const SliverFillRemaining(child: NoticesTabView())];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        sliver: SliverToBoxAdapter(
          child: _buildSearchAndFilterHeader(context),
        ),
      ),
      BlocBuilder<TenantsBloc, TenantsState>(
        builder: (context, state) {
          if (state.status == TenantsStatus.loading && state.tenants.isEmpty) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const TenantCardSkeleton(),
                  childCount: 5,
                ),
              ),
            );
          }

          if (state.status == TenantsStatus.failure && state.tenants.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load tenants',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (state.tenants.isEmpty && state.status == TenantsStatus.success) {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  'No active tenants found',
                  style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < state.tenants.length) {
                    return _buildTenantCard(state.tenants[index]);
                  }
                  
                  if (state.isPaginationLoading) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return SizedBox(height: 80.h);
                },
                childCount: state.tenants.length + 1, // Items + Pagination/Bottom padding
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Tenants'),
          _buildTabItem(1, 'Maintenance'),
          _buildTabItem(2, 'Notice & Vacating'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedTabIndex = index);
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.greyText,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.roomCardBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.greyText, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          context.read<TenantsBloc>().add(SearchTenants(value));
                        },
                        decoration: InputDecoration(
                          hintText: 'Search tenant, room, phone...',
                          hintStyle: TextStyle(color: AppColors.greyText, fontSize: 15.sp),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  PastTenantsSheet.show(context);
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 48.h,
                  width: 48.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.roomCardBorder.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.history_rounded, color: AppColors.primaryBlue, size: 22.sp),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              height: 48.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.roomCardBorder),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.tune_rounded, color: AppColors.darkText, size: 22.sp),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    return TenantCard(
      name: tenant.fullName,
      phone: tenant.mobile,
      room: tenant.roomTypename,
      since: _formatDate(tenant.checkInDate),
      imageUrl: ApiConstants.getImageUrl(tenant.avatar),
      isVerified: tenant.kycVerified,
      tenantId: tenant.id,
      hostelId: tenant.hostelId,
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(date);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.year.toString().substring(2)}';
    } catch (_) {
      return date;
    }
  }

  Widget? _buildFAB(BuildContext context) {
    if (_selectedTabIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTenantPage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        icon: Icon(Icons.add, color: Colors.white, size: 22.sp),
        label: Text(
          'Add Tenant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );
    } else if (_selectedTabIndex == 2) {
      return FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GiveNoticePage()),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        icon: Icon(Icons.assignment_late_rounded, color: Colors.white, size: 22.sp),
        label: Text(
          'Give Notice',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      );
    }
    return null;
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
