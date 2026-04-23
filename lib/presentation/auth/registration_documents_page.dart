import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../main_navigation_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'cubit/document_cubit.dart';
import 'cubit/document_state.dart';
import '../profile/cubit/hostel_cubit.dart';
import '../profile/cubit/hostel_state.dart';

class RegistrationDocumentsPage extends StatefulWidget {
  final bool isFromProfile;
  final String? hostelId;
  const RegistrationDocumentsPage({
    super.key,
    this.isFromProfile = false,
    this.hostelId,
  });

  @override
  State<RegistrationDocumentsPage> createState() => _RegistrationDocumentsPageState();
}

class _RegistrationDocumentsPageState extends State<RegistrationDocumentsPage> {
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  String? _selectedLicenseType;
  String? _filePath;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    context.read<HostelCubit>().getHostels();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 1.w),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 4,
              width: 100.w, // Full progress indicator
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<DocumentCubit, DocumentState>(
            listener: (context, state) {
              if (state is DocumentOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.isFromProfile ? 'Document uploaded successfully' : 'Profile registration complete!')),
                );
                if (widget.isFromProfile) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationPage()),
                    (route) => false,
                  );
                }
              } else if (state is DocumentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<HostelCubit, HostelState>(
            listener: (context, state) {
              if (state is HostelError) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading hostels: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w, 
            vertical: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.h : 34.h),
              Text(
                'Upload Your Documents',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Upload a business license or certificat', // Matching typo
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.greyText,
                ),
              ),
              SizedBox(height: 34.h),
              
              Text(
                'License Type *',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLicenseType,
                    hint: Text('Select license type', style: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp)),
                    isExpanded: true,
                    items: const {
                      'FSSAI License': 'fssai',
                      'Trade License': 'trade_license',
                      'Fire Safety Certificate': 'fire_safety',
                      'Police NOC': 'police_noc',
                    }.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value, // API enum value
                        child: Text(entry.key), // Display label
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLicenseType = newValue;
                      });
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              Text(
                'License Number *',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _licenseNumberController,
                decoration: InputDecoration(
                  hintText: 'e.g. TL-2024-BLR-00',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                'Expiry Date *',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _expiryDateController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    // Store ISO 8601 format for API (YYYY-MM-DD)
                    final month = pickedDate.month.toString().padLeft(2, '0');
                    final day = pickedDate.day.toString().padLeft(2, '0');
                    setState(() {
                      _expiryDateController.text = "${pickedDate.year}-$month-$day";
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'dd-mm-yyyy',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16.sp),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: _pickDocument,
                child: Container(
                  width: double.infinity,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      style: BorderStyle.solid, // Flutter doesn't have dashed natively easily without custom paint, but I'll make it light
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Using a light grey background and centered content to mimic the dashed box feel
                      Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_outlined, size: 40.w, color: Colors.grey.shade400),
                            SizedBox(height: 12.h),
                            Text(
                              _fileName ?? 'Upload Document',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: _fileName != null ? AppColors.primaryBlue : AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'FSSAI Certificate, Trade License,\nFire Safety Certificate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: BlocBuilder<DocumentCubit, DocumentState>(
                  builder: (context, state) {
                    final isLoading = state is DocumentLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : () {
                        final hostelState = context.read<HostelCubit>().state;
                        final String? finalHostelId = widget.hostelId ?? (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty ? hostelState.hostels.first.id : null);
                        
                        if (finalHostelId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No hostel found. Please create a hostel first.')),
                          );
                          return;
                        }

                        if (_selectedLicenseType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a license type')),
                          );
                          return;
                        }

                        if (_filePath == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a document file to upload')),
                          );
                          return;
                        }

                        context.read<DocumentCubit>().uploadDocument(
                          hostelId: finalHostelId,
                          licenseType: _selectedLicenseType!,
                          licenseNumber: _licenseNumberController.text,
                          expiryDate: _expiryDateController.text.isNotEmpty ? _expiryDateController.text : null,
                          filePath: _filePath!,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        disabledBackgroundColor: AppColors.primaryBlue.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
