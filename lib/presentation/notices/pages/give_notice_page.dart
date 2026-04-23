import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/tenant.dart';
import '../../../domain/repositories/tenant_repository.dart';
import '../../../injection_container.dart';
import '../cubit/notice_cubit.dart';
import '../../profile/cubit/hostel_cubit.dart';
import '../../profile/cubit/hostel_state.dart';

class GiveNoticePage extends StatefulWidget {
  const GiveNoticePage({super.key});

  @override
  State<GiveNoticePage> createState() => _GiveNoticePageState();
}

class _GiveNoticePageState extends State<GiveNoticePage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _tenantSearchController = TextEditingController();

  DateTime _noticeDate = DateTime.now();
  DateTime _vacatingDate = DateTime.now().add(const Duration(days: 30));

  Tenant? _selectedTenant;
  List<Tenant> _allTenants = [];
  List<Tenant> _filteredTenants = [];
  bool _isLoadingTenants = false;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    setState(() => _isLoadingTenants = true);
    try {
      final tenants = await sl<TenantRepository>().getTenants();
      if (!mounted) return;
      final hostelState = context.read<HostelCubit>().state;
      if (hostelState is HostelLoaded) {
        final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
        if (mounted) {
          setState(() {
            _allTenants = tenants.where((t) => t.hostelId == hostelId).toList();
            _isLoadingTenants = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTenants = false);
    }
  }

  void _filterTenants(String query) {
    setState(() {
      _filteredTenants = _allTenants.where((t) {
        final fullName = t.fullName.toLowerCase();
        final mobile = t.mobile.toLowerCase();
        return fullName.contains(query.toLowerCase()) || mobile.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NoticeCubit>(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Give Notice',
            style: TextStyle(color: AppColors.darkText, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
      body: BlocListener<NoticeCubit, NoticeState>(
        listener: (context, state) {
          if (state is NoticeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notice submitted successfully'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is NoticeSubmitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Tenant Details'),
                SizedBox(height: 16.h),
                _buildTenantSelector(),
                if (_selectedTenant != null) ...[
                  SizedBox(height: 16.h),
                  _buildSelectedTenantInfo(),
                ],
                SizedBox(height: 32.h),
                _buildSectionTitle('Dates'),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker('Notice Date', _noticeDate, (d) => setState(() => _noticeDate = d))),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildDatePicker('Vacating Date', _vacatingDate, (d) => setState(() => _vacatingDate = d))),
                  ],
                ),
                SizedBox(height: 32.h),
                _buildSectionTitle('Reason (Optional)'),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Relocating for work',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.roomCardBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.roomCardBorder)),
                  ),
                ),
                SizedBox(height: 48.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primaryBlue));
  }

  Widget _buildTenantSelector() {
    return Column(
      children: [
        TextFormField(
          controller: _tenantSearchController,
          decoration: InputDecoration(
            hintText: 'Search tenant by name or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoadingTenants ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.roomCardBorder)),
          ),
          onChanged: _filterTenants,
        ),
        if (_tenantSearchController.text.isNotEmpty && _selectedTenant == null)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            constraints: BoxConstraints(maxHeight: 200.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredTenants.length,
              itemBuilder: (context, index) {
                final t = _filteredTenants[index];
                return ListTile(
                  title: Text(t.fullName),
                  subtitle: Text('${t.mobile} • ${t.roomTypename}'),
                  onTap: () {
                    setState(() {
                      _selectedTenant = t;
                      _tenantSearchController.clear();
                      _filteredTenants = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedTenantInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primaryBlue, child: Text(_selectedTenant!.firstName[0], style: const TextStyle(color: Colors.white))),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_selectedTenant!.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
              Text('${_selectedTenant!.roomTypename} • Bed: ${_selectedTenant!.bedNumber}', style: TextStyle(color: AppColors.greyText, fontSize: 13.sp)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _selectedTenant = null)),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime selectedDate, Function(DateTime) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColors.greyText)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2025), lastDate: DateTime(2030));
            if (date != null) onSelected(date);
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(border: Border.all(color: AppColors.roomCardBorder), borderRadius: BorderRadius.circular(12.r)),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<NoticeCubit, NoticeState>(
      builder: (context, state) {
        final isLoading = state is NoticeSubmitting;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_selectedTenant == null || isLoading) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: isLoading
                ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Confirm Notice', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedTenant != null) {
      context.read<NoticeCubit>().createNotice(
            hostelId: _selectedTenant!.hostelId,
            tenantId: _selectedTenant!.id,
            roomId: _selectedTenant!.roomId,
            bedNumber: _selectedTenant!.bedNumber,
            vacatingDate: DateFormat('yyyy-MM-dd').format(_vacatingDate),
            reason: _reasonController.text,
          );
    }
  }
}
