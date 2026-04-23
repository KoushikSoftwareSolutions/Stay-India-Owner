import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/maintenance.dart';
import '../../maintenance/cubit/maintenance_cubit.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';
import '../../common_widgets/shimmer_loading.dart';

class MaintenanceTabView extends StatefulWidget {
  const MaintenanceTabView({super.key});

  @override
  State<MaintenanceTabView> createState() => _MaintenanceTabViewState();
}

class _MaintenanceTabViewState extends State<MaintenanceTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadIssues();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadIssues() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<MaintenanceCubit>().loadIssues(hostelId: hostelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaintenanceCubit, MaintenanceState>(
      listener: (context, state) {
        if (state is MaintenanceSuccess) {
          _reloadIssues();
        }
      },
      builder: (context, state) {
        if (state is MaintenanceLoading || state is MaintenanceSaving || state is MaintenanceSuccess) {
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 80.h),
            itemCount: 8,
            itemBuilder: (context, index) => const TenantCardSkeleton(),
          );
        } else if (state is MaintenanceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _reloadIssues,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is MaintenanceLoaded || (state.summary != null)) {
          final summary = state.summary!;
          final filteredTickets = _filterTickets(summary.items);
          final groupedItems = _buildGroupedListItems(filteredTickets);
          
          return RefreshIndicator(
            onRefresh: () async => _reloadIssues(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 80.h),
              itemCount: 4 + groupedItems.length,
              itemBuilder: (context, index) {
                if (index == 0) return _buildSearchBar();
                if (index == 1) return Column(children: [SizedBox(height: 16.h), _buildFilterPills(summary.items)]);
                if (index == 2) return Column(children: [SizedBox(height: 20.h), _buildSummaryCards(summary)]);
                if (index == 3) return SizedBox(height: 24.h);
                
                return groupedItems[index - 4];
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<Maintenance> _filterTickets(List<Maintenance> items) {
    return items.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.roomId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Open' && t.status == 'OPEN') ||
          (_selectedFilter == 'In Progress' && t.status == 'IN_PROGRESS') ||
          (_selectedFilter == 'Fixed' && t.status == 'RESOLVED');

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
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
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
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
    );
  }

  Widget _buildFilterPills(List<Maintenance> allTickets) {
    final filters = ['All', 'Open', 'In Progress', 'Fixed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          int count = 0;
          if (f == 'All') {
            count = allTickets.length;
          } else if (f == 'Open') {
            count = allTickets.where((t) => t.status == 'OPEN').length;
          } else if (f == 'In Progress') {
            count = allTickets.where((t) => t.status == 'IN_PROGRESS').length;
          } else if (f == 'Fixed') {
            count = allTickets.where((t) => t.status == 'RESOLVED').length;
          }

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = f),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.roomCardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f == 'Open') Icon(Icons.warning_amber_rounded, size: 14.sp, color: isSelected ? Colors.white : AppColors.darkText),
                    if (f == 'In Progress') Icon(Icons.access_time, size: 14.sp, color: isSelected ? Colors.white : AppColors.darkText),
                    if (f == 'Fixed') Icon(Icons.check_circle_outline, size: 14.sp, color: isSelected ? Colors.white : AppColors.darkText),
                    if (f != 'All') SizedBox(width: 6.w),
                    Text(
                      '$f ($count)',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(dynamic summary) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryVerticalCard(
            label: 'Open',
            count: summary.open.toString(),
            color: const Color(0xFFF04438),
            bgColor: const Color(0xFFFEF3F2),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildSummaryVerticalCard(
            label: 'In Progress',
            count: summary.inProgress.toString(),
            color: const Color(0xFFF79009),
            bgColor: const Color(0xFFFEF9F2),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildSummaryVerticalCard(
            label: 'Fixed',
            count: summary.resolved.toString(),
            color: const Color(0xFF12B76A),
            bgColor: const Color(0xFFF0FDF4),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryVerticalCard({required String label, required String count, required Color color, required Color bgColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedListItems(List<Maintenance> tickets) {
    if (tickets.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40.h),
            child: Text('No tickets found', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          ),
        ),
      ];
    }

    final open = tickets.where((t) => t.status == 'OPEN').toList();
    final inProgress = tickets.where((t) => t.status == 'IN_PROGRESS').toList();
    final fixed = tickets.where((t) => t.status == 'RESOLVED').toList();

    List<Widget> sections = [];
    if (open.isNotEmpty) {
      sections.add(_buildSectionHeader('Open Issues', const Color(0xFFF04438), Icons.warning_amber_rounded));
      sections.addAll(open.map((t) => _buildMaintenanceCard(t)));
    }
    if (inProgress.isNotEmpty) {
      sections.add(_buildSectionHeader('In Progress', const Color(0xFFF79009), Icons.access_time));
      sections.addAll(inProgress.map((t) => _buildMaintenanceCard(t)));
    }
    if (fixed.isNotEmpty) {
      sections.add(_buildSectionHeader('Fixed Issues', const Color(0xFF12B76A), Icons.check_circle_outline));
      sections.addAll(fixed.map((t) => _buildMaintenanceCard(t)));
    }
    return sections;
  }

  Widget _buildSectionHeader(String title, Color color, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: color),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildMaintenanceCard(Maintenance ticket) {
    String dateStr = '---';
    try {
      final dt = DateTime.parse(ticket.createdAt);
      dateStr = DateFormat('dd MMM').format(dt);
    } catch (_) {}

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showIssueDetailsSheet(ticket),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
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
                children: [
                  Container(
                    height: 48.h,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.build_outlined, size: 22.sp, color: AppColors.darkText),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Room ${ticket.roomId ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reported on $dateStr',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppColors.greyText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label = status.replaceAll('_', ' ');
    switch (status.toUpperCase()) {
      case 'OPEN': color = const Color(0xFFF04438); label = 'Open'; break;
      case 'IN_PROGRESS': color = const Color(0xFFF79009); label = 'In Progress'; break;
      case 'RESOLVED': color = const Color(0xFF12B76A); label = 'Fixed'; break;
      default: color = AppColors.greyText;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toUpperCase() == 'RESOLVED' ? Icons.check_circle_outline : Icons.error_outline,
            size: 10.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showIssueDetailsSheet(Maintenance ticket) {
    final maintenanceCubit = context.read<MaintenanceCubit>();
    String selectedStatus = ticket.status;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: maintenanceCubit,
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Details',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _buildStatusBadge(ticket.status),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Info Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.roomCardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.title,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 16.sp, color: AppColors.greyText),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Room ${ticket.roomId ?? 'N/A'}',
                                    style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                                  ),
                                  SizedBox(width: 16.w),
                                  Icon(Icons.warning_amber_rounded, size: 16.sp, color: const Color(0xFFF04438)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    ticket.priority ?? 'High Priority',
                                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFFF04438), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Timeline
                        Text(
                          'Timeline',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3F2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(Icons.calendar_today_outlined, color: const Color(0xFFB42318), size: 18.sp),
                              ),
                              SizedBox(width: 16.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reported',
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                                  ),
                                  Text(
                                    _formatDate(ticket.createdAt),
                                    style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Update Status
                        Text(
                          'Update Status',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _buildStatusBox(
                              'Open',
                              Icons.cancel_outlined,
                              selectedStatus == 'OPEN',
                              const Color(0xFF2952A3),
                              () => setModalState(() => selectedStatus = 'OPEN'),
                            ),
                            SizedBox(width: 8.w),
                            _buildStatusBox(
                              'In Progress',
                              Icons.build_outlined,
                              selectedStatus == 'IN_PROGRESS',
                              const Color(0xFF667085),
                              () => setModalState(() => selectedStatus = 'IN_PROGRESS'),
                            ),
                            SizedBox(width: 8.w),
                            _buildStatusBox(
                              'Fixed',
                              Icons.check_circle_outline,
                              selectedStatus == 'RESOLVED',
                              const Color(0xFF12B76A),
                              () => setModalState(() => selectedStatus = 'RESOLVED'),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),

                // Footer Action
                Container(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<MaintenanceCubit>().updateIssue(ticket.id, status: selectedStatus);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF12B76A),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedStatus == 'RESOLVED' ? Icons.check_circle_outline : Icons.update,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            selectedStatus == 'RESOLVED' ? 'Mark as Fixed' : 'Update Status',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildStatusBox(String label, IconData icon, bool isSelected, Color activeColor, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isSelected ? activeColor : AppColors.roomCardBorder),
            ),
            child: Column(
              children: [
                Icon(icon, color: isSelected ? Colors.white : AppColors.greyText, size: 24.sp),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }
}
