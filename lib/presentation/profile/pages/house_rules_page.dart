import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/settings_cubit.dart';

class HouseRulesPage extends StatefulWidget {
  const HouseRulesPage({super.key});

  @override
  State<HouseRulesPage> createState() => _HouseRulesPageState();
}

class _HouseRulesPageState extends State<HouseRulesPage> {
  final _entryTimeController = TextEditingController();
  final _visitorPolicyController = TextEditingController();
  final _otherRulesController = TextEditingController();

  late final SettingsCubit _cubit;

  String _hostelId(BuildContext context) {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      return hostelState.hostels[hostelState.selectedHostelIndex].id;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _cubit = sl<SettingsCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostelId = _hostelId(context);
      if (hostelId.isNotEmpty) {
        _cubit.loadSettings(hostelId);
      }
    });
  }

  @override
  void dispose() {
    _entryTimeController.dispose();
    _visitorPolicyController.dispose();
    _otherRulesController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            final r = state.settings.houseRules;
            _entryTimeController.text = r.entryTime;
            _visitorPolicyController.text = r.visitorPolicy;
            _otherRulesController.text = r.otherRules;
          } else if (state is SettingsSaveSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.darkText),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'House Rules',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Divider(
                height: 1,
                color: AppColors.roomCardBorder.withValues(alpha: 0.5),
              ),
            ),
          ),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Entry Time'),
                    _buildTextField(_entryTimeController,
                        hint: 'e.g. 10:00 PM'),
                    SizedBox(height: 24.h),
                    _buildLabel('Visitor Policy'),
                    _buildTextField(
                      _visitorPolicyController,
                      hint: 'Enter visitor policy',
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.h),
                    _buildLabel('Other Rules'),
                    _buildTextField(
                      _otherRulesController,
                      hint: 'Enter other rules and regulations',
                      maxLines: 4,
                    ),
                    SizedBox(height: 48.h),
                    _buildSaveButton(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style:
          TextStyle(fontSize: 16.sp, color: AppColors.darkText, height: 1.4),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.greyText.withValues(alpha: 0.7),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.roomCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.roomCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, SettingsState state) {
    final isSaving = state is SettingsSaving;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving
            ? null
            : () {
                final hostelId = _hostelId(context);
                if (hostelId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hostel selected')),
                  );
                  return;
                }
                _cubit.updateHouseRules(
                  hostelId,
                  entryTime: _entryTimeController.text,
                  visitorPolicy: _visitorPolicyController.text,
                  otherRules: _otherRulesController.text,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        icon: isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Icon(Icons.save_outlined, color: Colors.white, size: 20.sp),
        label: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
