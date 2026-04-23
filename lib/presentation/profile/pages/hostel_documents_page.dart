import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/cubit/document_cubit.dart';
import '../../auth/cubit/document_state.dart';
import '../../auth/registration_documents_page.dart';
import '../../../injection_container.dart';

class HostelDocumentsPage extends StatefulWidget {
  final String hostelId;
  const HostelDocumentsPage({super.key, required this.hostelId});

  @override
  State<HostelDocumentsPage> createState() => _HostelDocumentsPageState();
}

class _HostelDocumentsPageState extends State<HostelDocumentsPage> {
  late final DocumentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<DocumentCubit>();
    _cubit.getDocuments(widget.hostelId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Documents',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: _cubit,
                child: RegistrationDocumentsPage(
                  isFromProfile: true,
                  hostelId: widget.hostelId,
                ),
              ),
            ),
          ).then((_) => _cubit.getDocuments(widget.hostelId)),
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocConsumer<DocumentCubit, DocumentState>(
          listener: (context, state) {
            if (state is DocumentOperationSuccess && state.message.contains('deleted')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is DocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DocumentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading documents', style: TextStyle(fontSize: 16.sp, color: Colors.red)),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () => _cubit.getDocuments(widget.hostelId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is DocumentLoaded) {
              if (state.documents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 48.sp, color: AppColors.greyText.withValues(alpha: 0.5)),
                      SizedBox(height: 16.h),
                      Text(
                        'No documents uploaded',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.greyText),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(24.w),
                itemCount: state.documents.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final doc = state.documents[index];
                  return _buildDocumentCard(doc);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDocumentCard(dynamic doc) {
    // Determine title based on licenseType
    String title = doc.licenseType.toString().replaceAll('_', ' ').toUpperCase();
    if (doc.licenseType == 'fssai') title = 'FSSAI License';
    if (doc.licenseType == 'trade_license') title = 'Trade License';
    if (doc.licenseType == 'fire_safety') title = 'Fire Safety Certificate';
    if (doc.licenseType == 'police_noc') title = 'Police NOC';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.description, color: AppColors.primaryBlue, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  doc.licenseNumber ?? 'No number provided',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
                ),
                if (doc.expiryDate != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12.sp, color: AppColors.greyText),
                      SizedBox(width: 4.w),
                      Text(
                        'Exp: ${doc.expiryDate.toString().split('T').first}',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _cubit.deleteDocument(doc.id, widget.hostelId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
