import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/maintenance.dart';
import '../../../injection_container.dart';
import '../cubit/maintenance_cubit.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> with SingleTickerProviderStateMixin {
  late final MaintenanceCubit _cubit;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cubit = sl<MaintenanceCubit>();
    _tabController = TabController(length: 2, vsync: this);
    _loadIssues();
  }

  void _loadIssues() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      _cubit.loadIssues(hostelId: hostelId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Maintenance',
            style: TextStyle(color: AppColors.darkText, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primaryBlue),
              onPressed: _loadIssues,
            ),
          ],
        ),
        body: BlocBuilder<MaintenanceCubit, MaintenanceState>(
          builder: (context, state) {
            final summary = state.summary;
            
            if (summary == null) {
              if (state is MaintenanceLoading || state is MaintenanceSaving) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MaintenanceError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text("No maintenance data available."));
            }

            // If we have summary, we show it, possibly with a subtle loading indicator
            return Column(
              children: [
                if (state is MaintenanceLoading || state is MaintenanceSaving)
                  const LinearProgressIndicator(minHeight: 2),
                _buildSummarySection(summary),
                _buildTabs(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTicketList(summary.items.where((i) => i.status.toUpperCase() != 'RESOLVED').toList()),
                      _buildTicketList(summary.items.where((i) => i.status.toUpperCase() == 'RESOLVED').toList()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _buildCreateTicketDialog(),
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummarySection(dynamic summary) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard('Total', summary.total.toString(), AppColors.primaryBlue)),
          SizedBox(width: 12.w),
          Expanded(child: _buildSummaryCard('Open', summary.open.toString(), const Color(0xFFF04438))),
          SizedBox(width: 12.w),
          Expanded(child: _buildSummaryCard('Resolved', summary.resolved.toString(), const Color(0xFF12B76A))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.greyText,
        indicatorColor: AppColors.primaryBlue,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildTicketList(List<Maintenance> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text('No tickets found', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(Maintenance ticket) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'TICKET #${ticket.id.substring(ticket.id.length - 4).toUpperCase()}',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ),
              _buildStatusBadge(ticket.status),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            ticket.title,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          if (ticket.description != null) ...[
            SizedBox(height: 4.h),
            Text(
              ticket.description!,
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: AppColors.greyText),
              SizedBox(width: 4.w),
              Text(
                DateFormat('dd MMM, hh:mm a').format(DateTime.parse(ticket.createdAt)),
                style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
              ),
              const Spacer(),
              if (ticket.roomId != null)
                Text(
                  'Room ${ticket.roomId}',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
            ],
          ),
          if (ticket.status.toUpperCase() != 'RESOLVED') ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showStatusUpdateSheet(ticket),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Update Status', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'OPEN': color = const Color(0xFFF04438); break;
      case 'IN_PROGRESS': color = const Color(0xFFF79009); break;
      case 'RESOLVED': color = const Color(0xFF12B76A); break;
      default: color = AppColors.greyText;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _showStatusUpdateSheet(Maintenance ticket) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Ticket Status', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),
            _buildStatusOption('IN_PROGRESS', 'Mark as In-Progress', Icons.auto_mode),
            _buildStatusOption('RESOLVED', 'Mark as Resolved', Icons.check_circle_outline),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    ).then((status) {
      if (status != null) {
        _cubit.updateIssue(ticket.id, status: status).then((_) => _loadIssues());
      }
    });
  }

  Widget _buildStatusOption(String status, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(label),
      onTap: () => Navigator.pop(context, status),
    );
  }

  void _buildCreateTicketDialog() {
    // Basic implementation for internal ticket creation
    final titleController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final hostelState = this.context.read<HostelCubit>().state;
              if (hostelState is HostelLoaded) {
                _cubit.createIssue(
                  hostelId: hostelState.hostels[hostelState.selectedHostelIndex].id,
                  title: titleController.text,
                  description: descController.text,
                  status: 'OPEN',
                ).then((_) {
                  Navigator.pop(context);
                  _loadIssues();
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
