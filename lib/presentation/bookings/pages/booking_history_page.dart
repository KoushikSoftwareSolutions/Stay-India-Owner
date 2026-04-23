import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_state.dart';
import '../widgets/booking_card.dart';
import '../../../domain/entities/booking.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking History',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: AppColors.roomCardBorder),
        ),
      ),
      body: BlocBuilder<BookingsBloc, BookingsState>(
        builder: (context, state) {
          if (state.bookings.isEmpty) {
            return Center(
              child: Text(
                'No booking history found',
                style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
              ),
            );
          }

          // Group bookings by Month Year
          final groupedBookings = <String, List<Booking>>{};
          
          for (final booking in state.bookings) {
            try {
              final date = DateTime.parse(booking.checkInDate ?? '');
              final monthYear = DateFormat('MMMM yyyy').format(date);
              if (!groupedBookings.containsKey(monthYear)) {
                groupedBookings[monthYear] = [];
              }
              groupedBookings[monthYear]!.add(booking);
            } catch (e) {
              // Fallback for invalid dates
              const monthYear = 'Other';
              if (!groupedBookings.containsKey(monthYear)) {
                groupedBookings[monthYear] = [];
              }
              groupedBookings[monthYear]!.add(booking);
            }
          }

          final months = groupedBookings.keys.toList();
          // We assume state.bookings is already sorted DESC, 
          // but let's ensure the months order respects the most recent date in each group.

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final items = groupedBookings[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthHeader(month),
                  SizedBox(height: 12.h),
                  ...items.map((b) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: BookingCard(
                      booking: b,
                      isCompact: true,
                    ),
                  )),
                  SizedBox(height: 12.h),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(String month) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        month,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}
