import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/occupancy_summary.dart';
import '../../../data/models/occupancy_model.dart';
import '../../dashboard/widgets/floor_filter.dart';
import '../../dashboard/widgets/floor_accordion.dart';
import '../../dashboard/widgets/room_card.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
class RoomSelectionPage extends StatefulWidget {
  final String bookingId;
  final String hostelId;
  final String tenantName;
  final String? accessCode;
  final String? preAllocatedRoomId;
  final String? preAllocatedBedNumber;
  final bool isRoomChange;

  const RoomSelectionPage({
    super.key,
    required this.bookingId,
    required this.hostelId,
    required this.tenantName,
    this.accessCode,
    this.preAllocatedRoomId,
    this.preAllocatedBedNumber,
    this.isRoomChange = false,
  });

  @override
  State<RoomSelectionPage> createState() => _RoomSelectionPageState();
}

class _RoomSelectionPageState extends State<RoomSelectionPage> {
  int _selectedFloorIndex = 0;

  @override
  void initState() {
    super.initState();
    // Clear any lingering snackbars from the previous screen
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });

    // Fetch occupancy for this hostel
    context.read<BookingsBloc>().add(FetchOccupancyForCheckin(widget.hostelId));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<BookingsBloc>().add(ClearCheckinData());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () {
            context.read<BookingsBloc>().add(ClearCheckinData());
            Navigator.pop(context);
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.isRoomChange 
                ? 'Move ${widget.tenantName} to...' 
                : 'Select Bed for ${widget.tenantName}',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: BlocConsumer<BookingsBloc, BookingsState>(
        listener: (context, state) {
          if (state.successMessage == 'Check-in completed successfully' && state.status == BookingsStatus.success) {
            ScaffoldMessenger.of(context).clearSnackBars();
            // Use a slight delay or frame callback to avoid !debugLocked error 
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                 Navigator.of(context).pop();
              }
            });
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
        },
        builder: (context, state) {
          if (state.status == BookingsStatus.loading && state.occupancy == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == BookingsStatus.failure && state.occupancy == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.errorMessage}'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookingsBloc>()
                        .add(FetchOccupancyForCheckin(widget.hostelId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.occupancy == null) {
            return const Center(child: Text('No occupancy data found'));
          }

          final occupancyModel = state.occupancy as OccupancyModel;
          final floorNames = [
            'All Floors',
            ...occupancyModel.floors.map((f) => f.floorName)
          ];

          return Stack(
            children: [
              Column(
                children: [
                  FloorFilter(
                    floors: floorNames,
                    selectedIndex: _selectedFloorIndex,
                    onSelected: (index) {
                      setState(() {
                        _selectedFloorIndex = index;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: _buildFloorsList(occupancyModel),
                  ),
                ],
              ),
              if (state.status == BookingsStatus.loading)
                Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
   );
  }

  Widget _buildFloorsList(OccupancyModel occupancyModel) {
    List<FloorData> filteredFloors;
    if (_selectedFloorIndex == 0) {
      filteredFloors = occupancyModel.floors;
    } else {
      if (_selectedFloorIndex - 1 < occupancyModel.floors.length) {
        filteredFloors = [occupancyModel.floors[_selectedFloorIndex - 1]];
      } else {
        filteredFloors = [];
      }
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: filteredFloors.length,
      itemBuilder: (context, index) {
        final floor = filteredFloors[index];
        return FloorAccordion(
          title: floor.floorName,
          bedInfo: floor.bedInfo,
          isInitialExpanded: _selectedFloorIndex != 0,
          rooms: floor.rooms
              .map(
                (room) {
                  final isPreAllocatedRoom = room.id == widget.preAllocatedRoomId;
                  return RoomCard(
                    roomNumber: room.roomNumber,
                    sharingType: room.sharingType,
                    occupancy: room.occupancy,
                    beds: room.beds,
                    onBedTap: (roomNumber, bedNumber) {
                      _showConfirmationDialog(context, room, bedNumber);
                    },
                    isPreAllocated: isPreAllocatedRoom,
                    preAllocatedBedNumber: isPreAllocatedRoom ? widget.preAllocatedBedNumber : null,
                  );
                },
              )
              .toList(),
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, Room room, String bedNumber) {
    // Map bed number label (A, B, C...) back to number if needed, 
    // but the backend expects the exact bedNumber from BedInfo.
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.isRoomChange ? 'Move Tenant' : 'Allocate Bed'),
        content: Text(
            'Confirm ${widget.isRoomChange ? "moving" : "allocating"} Bed $bedNumber in Room ${room.roomNumber} to ${widget.tenantName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              context.read<BookingsBloc>().add(
                    FinalizeCheckinEvent(
                      bookingId: widget.bookingId,
                      roomId: room.id,
                      bedNumber: bedNumber,
                      accessCode: widget.accessCode,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              widget.isRoomChange ? 'Confirm Move' : 'Confirm Check-in',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
