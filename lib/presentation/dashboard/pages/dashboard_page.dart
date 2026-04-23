import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/summary_cards.dart';
import '../widgets/floor_filter.dart';
import '../widgets/floor_accordion.dart';
import '../widgets/room_card.dart';
import '../../maintenance/pages/maintenance_page.dart';
import '../../bookings/pages/bookings_page.dart';
import '../../payments/pages/rent_payments_page.dart';
import '../../../domain/entities/occupancy_summary.dart';
import '../../../data/models/occupancy_model.dart';
import '../../../domain/entities/daily_operations.dart';
import '../widgets/app_drawer.dart';
import '../../tenants/widgets/past_tenants_sheet.dart';
import '../../tenants/pages/tenants_page.dart';
import '../../../core/widgets/bouncing_wrapper.dart';
import '../../common_widgets/shimmer_loading.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardView();
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final hostelState = context.read<HostelCubit>().state;
            if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
              final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
              context.read<DashboardBloc>().add(FetchDashboardData(hostelId));
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: RepaintBoundary(child: DashboardHeader())),
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const _DashboardSearchSection(),
                      SizedBox(height: 16.h),
                      // Granular Loading/Error state for the summary area
                      BlocBuilder<DashboardBloc, DashboardState>(
                        buildWhen: (p, c) => p.status != c.status || p.occupancy != c.occupancy || p.dailyOperations != c.dailyOperations || p.selectedFloorIndex != c.selectedFloorIndex,
                        builder: (context, state) {
                          if (state.status == DashboardStatus.loading && state.occupancy == null) {
                            return const _DashboardLoadingSection();
                          } else if (state.status == DashboardStatus.failure) {
                            return Center(child: Text('Error: ${state.errorMessage}'));
                          } else if (state.occupancy == null) {
                            return const Center(child: Text('No occupancy data'));
                          }
                          return RepaintBoundary(child: _DashboardDataSection(state: state));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Granular Floor list
              const _ManageFloorsSection(),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}


class _DashboardSearchSection extends StatelessWidget {
  const _DashboardSearchSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.greyText, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              'Search tenant, room, phone...',
              style: TextStyle(
                color: AppColors.greyText,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoadingSection extends StatelessWidget {
  const _DashboardLoadingSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(child: StatCardSkeleton()),
              SizedBox(width: 8),
              Expanded(child: StatCardSkeleton()),
            ],
          ),
          SizedBox(height: 16.h),
          const PropertyCardSkeleton(),
          SizedBox(height: 16.h),
          const PropertyCardSkeleton(),
        ],
      ),
    );
  }
}

class _DashboardDataSection extends StatelessWidget {
  final DashboardState state;
  const _DashboardDataSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.dailyOperations != null) ...[
          const _DashboardSectionTitle('Daily Operations'),
          SizedBox(height: 12.h),
          _DailyOperationsCards(ops: state.dailyOperations!),
          SizedBox(height: 24.h),
        ],
        const _DashboardSectionTitle('Occupancy Summary'),
        SizedBox(height: 12.h),
        _SummaryCards(occupancy: state.occupancy!),
        SizedBox(height: 24.h),
        _DashboardFloorFilter(state: state),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class _DashboardSectionTitle extends StatelessWidget {
  final String title;
  const _DashboardSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        title.trim(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

class _DailyOperationsCards extends StatelessWidget {
  final DailyOperations ops;
  const _DailyOperationsCards({required this.ops});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          BouncingWrapper(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BookingsPage()),
            ),
            child: SummaryCard(
              count: ops.todayCheckIns.toString(),
              label: 'Check-Ins',
              backgroundColor: AppColors.primaryBlue,
              textColor: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          BouncingWrapper(
            onTap: () => PastTenantsSheet.show(context),
            child: SummaryCard(
              count: ops.todayCheckOuts.toString(),
              label: 'Check-Outs',
              backgroundColor: AppColors.awayYellow,
              textColor: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          BouncingWrapper(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MaintenancePage()),
            ),
            child: SummaryCard(
              count: ops.pendingMaintenance.toString(),
              label: 'Maintenance',
              backgroundColor: AppColors.noticeOrange,
              textColor: Colors.white,
            ),
          ),
          SizedBox(width: 8.w),
          BouncingWrapper(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RentPaymentsPage()),
            ),
            child: SummaryCard(
              count: '₹${ops.overdueRent.amount.toInt()}',
              label: 'Overdue Rent',
              backgroundColor: Colors.red.shade400,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Occupancy occupancy;
  const _SummaryCards({required this.occupancy});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          SummaryCard(
            count: occupancy.totalBeds.toString(),
            label: 'Total',
            backgroundColor: AppColors.totalBlue,
            textColor: AppColors.totalBlueText,
            isLarge: true,
          ),
          SizedBox(width: 8.w),
          SummaryCard(
            count: occupancy.freeBeds.toString(),
            label: 'Free',
            backgroundColor: AppColors.freeGreen,
            textColor: AppColors.white,
          ),
          SizedBox(width: 8.w),
          SummaryCard(
            count: occupancy.occupiedBeds.toString(),
            label: 'Occupied',
            backgroundColor: AppColors.occupiedBlue,
            textColor: AppColors.white,
          ),
          SizedBox(width: 8.w),
          SummaryCard(
            count: occupancy.noticeBeds.toString(),
            label: 'Notice',
            backgroundColor: AppColors.noticeOrange,
            textColor: AppColors.white,
          ),
          SizedBox(width: 8.w),
          SummaryCard(
            count: occupancy.awayBeds.toString(),
            label: 'Away',
            backgroundColor: AppColors.awayYellow,
            textColor: AppColors.white,
          ),
          SizedBox(width: 8.w),
          SummaryCard(
            count: occupancy.reservedBeds.toString(),
            label: 'Reserved',
            backgroundColor: Colors.blueGrey.shade400,
            textColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class _DashboardFloorFilter extends StatelessWidget {
  final DashboardState state;
  const _DashboardFloorFilter({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.occupancy is! OccupancyModel) return const SizedBox.shrink();
    final occupancyModel = state.occupancy as OccupancyModel;
    final floorNames = [
      'All Floors',
      ...occupancyModel.floors.map((f) => f.floorName)
    ];

    return FloorFilter(
      floors: floorNames,
      selectedIndex: state.selectedFloorIndex,
      onSelected: (index) {
        context.read<DashboardBloc>().add(ChangeFloorFilter(index));
      },
    );
  }
}

class _ManageFloorsSection extends StatelessWidget {
  const _ManageFloorsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) => p.occupancy != c.occupancy || p.selectedFloorIndex != c.selectedFloorIndex,
      builder: (context, state) {
        if (state.occupancy is! OccupancyModel) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        
        final occupancyModel = state.occupancy as OccupancyModel;

        List<FloorData> filteredFloors;
        if (state.selectedFloorIndex == 0) {
          filteredFloors = occupancyModel.floors;
        } else {
          if (state.selectedFloorIndex - 1 < occupancyModel.floors.length) {
            filteredFloors = [occupancyModel.floors[state.selectedFloorIndex - 1]];
          } else {
            filteredFloors = [];
          }
        }

        if (filteredFloors.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Text(
                  'Manage Your Floors',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final floor = filteredFloors[index];
                    return RepaintBoundary(
                      child: FloorAccordion(
                        key: ValueKey('floor_${floor.floorName}'),
                        title: floor.floorName,
                        bedInfo: floor.bedInfo,
                        isInitialExpanded: state.selectedFloorIndex != 0,
                        rooms: floor.rooms
                            .map(
                              (room) => RoomCard(
                                key: ValueKey('room_${floor.floorName}_${room.roomNumber}'),
                                roomNumber: room.roomNumber,
                                sharingType: room.sharingType,
                                occupancy: room.occupancy,
                                beds: room.beds,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                  childCount: filteredFloors.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
