import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../profile/cubit/hostel_cubit.dart';
import '../profile/cubit/hostel_state.dart';
import 'registration_documents_page.dart';
import 'cubit/document_cubit.dart';
import '../../injection_container.dart';

class RegistrationHostelImagesPage extends StatefulWidget {
  final String hostelId;

  const RegistrationHostelImagesPage({super.key, required this.hostelId});

  @override
  State<RegistrationHostelImagesPage> createState() => _RegistrationHostelImagesPageState();
}

class _RegistrationHostelImagesPageState extends State<RegistrationHostelImagesPage> {
  final List<File> _selectedImages = [];
  final int _maxImages = 10;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 10 images allowed')),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      final newFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      setState(() {
        // Add only up to the remaining limit
        int remaining = _maxImages - _selectedImages.length;
        _selectedImages.addAll(newFiles.take(remaining));
      });

      if (newFiles.length > (_maxImages - (_selectedImages.length - newFiles.length))) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Only $_maxImages images can be uploaded. Some were skipped.')),
          );
        }
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _handleContinue() {
    if (_selectedImages.isEmpty) {
      // Allow skipping images if needed, or enforce at least one?
      // User said "give an option", so I'll allow skip/continue.
      _navigateToDocuments();
      return;
    }

    context.read<HostelCubit>().uploadHostelImages(
      id: widget.hostelId,
      filePaths: _selectedImages.map((f) => f.path).toList(),
    );
  }

  void _navigateToDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<DocumentCubit>(),
          child: RegistrationDocumentsPage(hostelId: widget.hostelId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostelCubit, HostelState>(
      listener: (context, state) {
        if (state is HostelOperationSuccess && state.message.contains('Images uploaded successfully')) {
          _navigateToDocuments();
        } else if (state is HostelError) {
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
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 4,
                width: 320.w, // Progress indicator (increasing)
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Hostel Photos',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add up to 10 photos of your property to attract tenants.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 32.h),
                
                Expanded(
                  child: _selectedImages.isEmpty
                      ? _buildEmptyState()
                      : _buildImageGrid(),
                ),
                
                SizedBox(height: 24.h),
                
                BlocBuilder<HostelCubit, HostelState>(
                  builder: (context, state) {
                    final isLoading = state is HostelLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _selectedImages.isEmpty ? 'Skip for Now' : 'Upload & Continue',
                                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 64.sp, color: AppColors.primaryBlue.withOpacity(0.5)),
            SizedBox(height: 16.h),
            Text(
              'Tap to select photos',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
            SizedBox(height: 8.h),
            Text(
              'Maximum 10 images allowed',
              style: TextStyle(fontSize: 14.sp, color: AppColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: _selectedImages.length + (_selectedImages.length < _maxImages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _selectedImages.length) {
                return _buildAddMoreButton();
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '${_selectedImages.length} / $_maxImages images selected',
          style: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(Icons.add_a_photo_outlined, color: AppColors.primaryBlue, size: 30.sp),
      ),
    );
  }
}
