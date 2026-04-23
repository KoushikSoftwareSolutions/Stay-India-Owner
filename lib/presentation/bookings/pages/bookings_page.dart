import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import '../widgets/booking_card.dart';
import 'room_selection_page.dart';
import 'booking_history_page.dart';
import '../../common_widgets/shimmer_loading.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingsView();
  }
}

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<BookingsBloc, BookingsState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.errorMessage != null && state.status == BookingsStatus.failure) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }

            // Navigate to RoomSelectionPage when a booking is scanned
            if (state.status == BookingsStatus.success && state.scannedBooking != null) {
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<BookingsBloc>(),
                    child: RoomSelectionPage(
                      bookingId: state.scannedBooking!.bookingId,
                      hostelId: state.scannedBooking!.hostelId,
                      tenantName: state.scannedBooking!.tenantName,
                      preAllocatedRoomId: state.scannedBooking!.roomId,
                      preAllocatedBedNumber: state.scannedBooking!.bedNumber,
                    ),
                  ),
                ),
              );
              // Clear the scanned trigger immediately after navigation to prevent loop
              context.read<BookingsBloc>().add(ClearScannedBooking());
            }
          },
          child: BlocBuilder<BookingsBloc, BookingsState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildHeader(context, state),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildMainContent(context, state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BookingsState state) {
    final pendingCount =
        state.bookings.where((b) => ['CONFIRMED', 'PENDING_PAYMENT', 'IDLE'].contains(b.status.toUpperCase())).length;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bookings',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<BookingsBloc>(),
                        child: const BookingHistoryPage(),
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.history, color: AppColors.primaryBlue, size: 28.sp),
              ),
              if (pendingCount > 0) ...[
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB267),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$pendingCount Pending',
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, BookingsState state) {
    if (state.status == BookingsStatus.loading && state.bookings.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 5,
        itemBuilder: (context, index) => const TenantCardSkeleton(),
      );
    }
    
    if (state.status == BookingsStatus.failure && state.bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            'Error: ${state.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final requests = state.bookings
        .where((b) => ['CONFIRMED', 'PENDING_PAYMENT', 'IDLE'].contains(b.status.toUpperCase()))
        .toList();
    final checkIns = state.bookings
        .where((b) => b.status.toUpperCase() == 'CHECKED_IN')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BookingsBloc>().add(FetchBookings());
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Requests',
                requests.length,
                AppColors.primaryBlue,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            sliver: requests.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No requests found',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => BookingCard(booking: requests[index]),
                      childCount: requests.length,
                    ),
                  ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            sliver: SliverToBoxAdapter(
              child: _buildSectionHeader(
                'Check ins',
                checkIns.length,
                const Color(0xFF12B76A),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            sliver: checkIns.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No check-ins found',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => BookingCard(booking: checkIns[index]),
                      childCount: checkIns.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }


}
