import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import 'registration_personal_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../main_navigation_page.dart';
import 'cubit/auth_cubit.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String? otp;
  const OtpPage({super.key, required this.phone, this.otp});


  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _timerValue = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _timerValue = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerValue > 0) {
        if (mounted) setState(() => _timerValue--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          final shouldRegister = state.isNewUser || !state.owner.isProfileComplete;
          if (shouldRegister) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const RegistrationPersonalPage()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
              (route) => false,
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is OtpSentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
          _startTimer();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 100.w,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                SizedBox(width: 16.w),
                const Icon(Icons.arrow_back, color: Colors.black),
                SizedBox(width: 4.w),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
              vertical: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 10.h : 40.h),
                // Logo
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: MediaQuery.of(context).viewInsets.bottom > 0 ? 60.w : 100.w,
                  height: MediaQuery.of(context).viewInsets.bottom > 0 ? 60.w : 100.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: Colors.white,
                    size: MediaQuery.of(context).viewInsets.bottom > 0 ? 30.w : 50.w,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Sign in with your mobile number',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.greyText,
                  ),
                ),
                if (widget.otp != null && widget.otp!.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  Text(
                    "OTP: ${widget.otp}",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                      letterSpacing: 8.w,
                    ),
                  ),
                ],
                SizedBox(height: 40.h),
                // OTP Card
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'OTP sent to +91 ${widget.phone}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.greyText,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          6,
                          (index) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      final otp = _controllers.map((e) => e.text).join();
                                      context.read<AuthCubit>().verifyOtp(widget.phone, otp);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: state is AuthLoading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : Text(
                                      'Verify & Login',
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _timerValue > 0 
                                ? "Resend OTP in 00:${_timerValue.toString().padLeft(2, '0')} " 
                                : "Didn't receive OTP? ",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.greyText,
                            ),
                          ),
                          _timerValue == 0 
                              ? GestureDetector(
                                  onTap: () {
                                    context.read<AuthCubit>().resendOtp(widget.phone);
                                  },
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
