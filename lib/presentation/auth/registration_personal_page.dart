import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import 'login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/auth_cubit.dart';
import '../../core/services/token_storage.dart';
import '../../injection_container.dart';
import 'registration_hostel_details_page.dart';
import '../../core/widgets/bouncing_button.dart';

class RegistrationPersonalPage extends StatefulWidget {
  const RegistrationPersonalPage({super.key});

  @override
  State<RegistrationPersonalPage> createState() => _RegistrationPersonalPageState();
}

class _RegistrationPersonalPageState extends State<RegistrationPersonalPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
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
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 8.w),
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
                width: 128.w, // Progress indicator
                color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is ProfileCompleted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationHostelDetailsPage(),
              ),
            );
          } else if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w, 
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8.h : 32.h),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                        child: _selectedImage == null
                            ? Icon(Icons.person, size: 50.sp, color: AppColors.primaryBlue)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.add_a_photo, size: 18.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    'Upload Profile Photo (Optional)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 32.h),
                // Form Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First Name *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your first name',
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
                        'Last Name *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your last name',
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
                        'Email Address *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
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
                        'Address *',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Enter your full address',
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
                      SizedBox(height: 34.h),
                      BouncingButton(
                        onTap: () async {
                          if (_isSubmitting || context.read<AuthCubit>().state is AuthLoading) return;
                          
                          final firstName = _firstNameController.text.trim();
                          final lastName = _lastNameController.text.trim();
                          final email = _emailController.text.trim();
                          final address = _addressController.text.trim();

                          if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all fields')),
                            );
                            return;
                          }

                          setState(() => _isSubmitting = true);

                          final authState = context.read<AuthCubit>().state;
                          String phone = '';
                          if (authState is AuthSuccess) {
                            phone = authState.owner.phone;
                          }
                          
                          if (phone.isEmpty) {
                             phone = await sl<TokenStorage>().getPhone() ?? '';
                          }
                          
                          if (!context.mounted) return;

                          context.read<AuthCubit>().completeProfile({
                            'firstName': firstName,
                            'lastName': lastName,
                            'email': email,
                            'phone': phone,
                            'address': address,
                            'avatar': _selectedImage?.path,
                          });

                          // Reset after a delay if navigation didn't happen
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _isSubmitting = false);
                          });
                        },
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading || _isSubmitting) {
                                return const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              return Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
