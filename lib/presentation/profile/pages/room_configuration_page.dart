import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/room_detail.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/room_cubit.dart';
import '../widgets/add_room_sheet.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/bloc/dashboard_event.dart';

class RoomConfigurationPage extends StatelessWidget {
  const RoomConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomCubit>()..getRooms(),
      child: const _RoomConfigurationView(),
    );
  }
}

class _RoomConfigurationView extends StatelessWidget {
  const _RoomConfigurationView();

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Room Configuration',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => AddRoomSheet.show(
                  context,
                  roomCubit: context.read<RoomCubit>(),
                  onSave: (data) {
                    final hostelId = _hostelId(context);
                    context.read<RoomCubit>().createRoom(
                          hostelId: hostelId,
                          roomTypename: data['roomTypename'],
                          floor: data['floor'],
                          sharingType: data['sharingType'],
                          roomType: data['roomType'],
                          rent: data['rent'],
                          deposit: data['deposit'],
                          maintenance: data['maintenance'],
                          isMaster: false,
                        );
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.add, size: 18.sp),
                label: Text(
                  'Add Room',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(
            height: 1,
            color: AppColors.roomCardBorder.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh Dashboard data instantly
            final hostelId = _hostelId(context);
            if (hostelId.isNotEmpty) {
              context.read<DashboardBloc>().add(FetchDashboardData(hostelId, forceRefresh: true));
            }
          } else if (state is RoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RoomError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)),
            );
          }
           final allRooms = state is RoomLoaded ? state.rooms : <RoomDetail>[];
           final rooms = allRooms.where((r) => !r.isMaster).toList();
          if (rooms.isEmpty) {
            return Center(
              child: Text(
                'No rooms configured',
                style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(24.w),
            itemCount: rooms.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomCard(context, room);
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, RoomDetail room) {
    final floorLabel =
        room.floor == 0 ? 'Ground Floor' : 'Floor ${room.floor}';
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          room.roomTypename,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildTypeBadge(room.roomType == 'AC'),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${room.sharingType}  •  $floorLabel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteDialog(context, room),
                icon: Icon(
                  Icons.delete_outline,
                  color: const Color(0xFFF04438),
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildInfoItem('Rent', '₹${room.rent.toStringAsFixed(0)}'),
              SizedBox(width: 24.w),
              _buildInfoItem(
                  'Deposit', '₹${room.deposit.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(bool isAc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAc ? const Color(0xFFEFF4FF) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        isAc ? 'AC' : 'Non-AC',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isAc ? AppColors.primaryBlue : const Color(0xFFFB923C),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              TextStyle(fontSize: 12.sp, color: const Color(0xFF667085)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, RoomDetail room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Room'),
        content:
            Text('Are you sure you want to delete "${room.roomTypename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RoomCubit>().deleteRoom(room.id, isMaster: false);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
