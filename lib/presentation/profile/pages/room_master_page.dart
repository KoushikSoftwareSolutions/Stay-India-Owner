import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/room_detail.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/room_cubit.dart';
import '../widgets/add_room_master_sheet.dart';
import '../../dashboard/bloc/dashboard_bloc.dart';
import '../../dashboard/bloc/dashboard_event.dart';

class RoomMasterPage extends StatelessWidget {
  const RoomMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RoomCubit>()..getRooms(isMaster: true),
      child: const _RoomMasterView(),
    );
  }
}

class _RoomMasterView extends StatefulWidget {
  const _RoomMasterView();

  @override
  State<_RoomMasterView> createState() => _RoomMasterViewState();
}

class _RoomMasterViewState extends State<_RoomMasterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Room Master',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                height: 48.h,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppColors.darkText,
                  unselectedLabelColor: const Color(0xFF667085),
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'AC'),
                    Tab(text: 'Non-AC'),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.roomCardBorder),
            ],
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
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is RoomLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RoomError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          final rooms = state is RoomLoaded ? state.rooms : <RoomDetail>[];
          return TabBarView(
            controller: _tabController,
            children: [
              _RoomListBuilder(rooms: rooms, filter: 'All'),
              _RoomListBuilder(rooms: rooms, filter: 'AC'),
              _RoomListBuilder(rooms: rooms, filter: 'Non-AC'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final hostelId = _hostelId(context);
          AddRoomMasterSheet.show(
            context,
            roomCubit: context.read<RoomCubit>(),
            onSave: (data) => context.read<RoomCubit>().createRoom(
                  hostelId: hostelId,
                  roomTypename: data['roomTypename'],
                  floor: data['floor'],
                  sharingType: data['sharingType'],
                  roomType: data['roomType'],
                  rent: data['rent'],
                  deposit: data['deposit'],
                  maintenance: data['maintenance'],
                  isMaster: true,
                ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _RoomListBuilder extends StatelessWidget {
  final List<RoomDetail> rooms;
  final String filter;

  const _RoomListBuilder({required this.rooms, required this.filter});

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'All'
        ? rooms
        : rooms.where((r) {
            if (filter == 'AC') return r.roomType == 'AC';
            return r.roomType == 'NON-AC';
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No rooms found',
          style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _RoomMasterCard(room: filtered[index]),
    );
  }
}

class _RoomMasterCard extends StatelessWidget {
  final RoomDetail room;

  const _RoomMasterCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final isAc = room.roomType == 'AC';
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
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
                          Flexible(
                            child: Text(
                              room.roomTypename,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _TypeBadge(isAc: isAc),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${room.sharingType}  •  Floor ${room.floor}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: room.isActive,
                    onChanged: (value) {
                      final updated = RoomDetail(
                        id: room.id,
                        hostelId: room.hostelId,
                        roomTypename: room.roomTypename,
                        floor: room.floor,
                        sharingType: room.sharingType,
                        roomType: room.roomType,
                        rent: room.rent,
                        deposit: room.deposit,
                        maintenance: room.maintenance,
                        isActive: value,
                        isMaster: room.isMaster,
                        beds: room.beds,
                      );
                      context.read<RoomCubit>().updateRoom(updated);
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryBlue,
                    inactiveTrackColor: const Color(0xFFEAECF0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _FinanceItem(label: 'Rent', value: '₹${room.rent.toStringAsFixed(0)}'),
                SizedBox(width: 24.w),
                _FinanceItem(label: 'Deposit', value: '₹${room.deposit.toStringAsFixed(0)}'),
                SizedBox(width: 24.w),
                _FinanceItem(label: 'Maintenance', value: '₹${room.maintenance.toStringAsFixed(0)}'),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: const Color(0xFFF5F8FF),
                    textColor: AppColors.primaryBlue,
                    borderColor: const Color(0xFFD1E0FF),
                    onPressed: () => AddRoomMasterSheet.show(
                      context,
                      room: room,
                      roomCubit: context.read<RoomCubit>(),
                      onSave: (data) => context.read<RoomCubit>().updateRoom(
                            RoomDetail(
                              id: room.id,
                              hostelId: room.hostelId,
                              roomTypename: data['roomTypename'],
                              floor: data['floor'],
                              sharingType: data['sharingType'],
                              roomType: data['roomType'],
                              rent: data['rent'],
                              deposit: data['deposit'],
                              maintenance: data['maintenance'],
                              isActive: room.isActive,
                              isMaster: true,
                              beds: room.beds,
                            ),
                          ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: const Color(0xFFFFF1F0),
                    textColor: const Color(0xFFF04438),
                    borderColor: const Color(0xFFFEE4E2),
                    onPressed: () => _showDeleteDialog(context, room),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Divider(height: 1, color: AppColors.roomCardBorder.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, RoomDetail room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete "${room.roomTypename}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<RoomCubit>().deleteRoom(room.id, isMaster: true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final bool isAc;
  const _TypeBadge({required this.isAc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isAc ? const Color(0xFFEFF4FF) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAc ? Icons.ac_unit : Icons.wb_sunny_outlined,
            size: 14.sp,
            color: isAc ? AppColors.primaryBlue : const Color(0xFFFB923C),
          ),
          SizedBox(width: 6.w),
          Text(
            isAc ? 'AC' : 'Non-AC',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isAc ? AppColors.primaryBlue : const Color(0xFFFB923C),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  final String label;
  final String value;
  const _FinanceItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF667085),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
          side: BorderSide(color: borderColor),
        ),
      ),
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
