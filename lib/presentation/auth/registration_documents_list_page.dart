import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import 'registration_documents_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/document_cubit.dart';
import '../../injection_container.dart';

class RegistrationDocumentsListPage extends StatelessWidget {
  const RegistrationDocumentsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> documents = [
      {
        'title': 'Trade License',
        'subtitle': 'TL-2024-BLR-00456',
        'expiry': 'Exp: 2025-12-31',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Fire Safety Certificate',
        'subtitle': 'FS-KA-2024-1122',
        'expiry': 'Exp: 2025-06-15',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'FSSAI License',
        'subtitle': 'FSSAI-10024000012345',
        'expiry': 'Exp: 2026-03-01',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'title': 'Police NOC',
        'subtitle': 'NOC-BLR-2023-789',
        'expiry': 'Exp: 2025-01-31',
        'image': 'https://via.placeholder.com/150'
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
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
              width: 256.w, // More progress indicator
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => sl<DocumentCubit>(),
              child: const RegistrationDocumentsPage(),
            ),
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),
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
                    SizedBox(height: 32.h),
                    ...documents.map((doc) => _buildDocumentCard(doc)),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => sl<DocumentCubit>(),
                          child: const RegistrationDocumentsPage(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, String> doc) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&q=80&w=200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['title']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  doc['subtitle']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12.sp, color: AppColors.greyText),
                    SizedBox(width: 4.w),
                    Text(
                      doc['expiry']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.visibility_outlined, color: AppColors.greyText, size: 20.sp),
        ],
      ),
    );
  }
}
