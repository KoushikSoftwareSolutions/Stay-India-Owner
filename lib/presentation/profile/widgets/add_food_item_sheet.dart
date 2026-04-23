import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class AddFoodItemSheet extends StatefulWidget {
  final String day;
  final String mealType;
  final void Function(Map<String, dynamic> item) onSave;

  const AddFoodItemSheet({
    super.key,
    required this.day,
    required this.mealType,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String day,
    required String mealType,
    required void Function(Map<String, dynamic> item) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFoodItemSheet(
        day: day,
        mealType: mealType,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddFoodItemSheet> createState() => _AddFoodItemSheetState();
}

class _AddFoodItemSheetState extends State<AddFoodItemSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  bool _isVeg = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adding to: ${widget.day} • ${widget.mealType}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildLabel('Dish Name *'),
                  _buildTextField(_nameController, hint: 'e.g. Idli Sambar'),
                  SizedBox(height: 20.h),
                  _buildLabel('Description'),
                  _buildTextField(
                    _descController,
                    hint: 'e.g. Soft idlis with sambar & chutney',
                    maxLines: 2,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price (₹)'),
                            _buildTextField(
                              _priceController,
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Category'),
                            Row(
                              children: [
                                _buildCategoryOption('Veg', true),
                                SizedBox(width: 12.w),
                                _buildCategoryOption('Non-Veg', false),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48.h),
                  _buildSaveButton(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption(String label, bool isVeg) {
    final isSelected = _isVeg == isVeg;
    return GestureDetector(
      onTap: () => setState(() => _isVeg = isVeg),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? (isVeg ? Colors.green : Colors.red)
                : AppColors.roomCardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? (isVeg ? Colors.green : Colors.red)
                : AppColors.greyText,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add New Dish',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.greyText, size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
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
      style: TextStyle(fontSize: 16.sp, color: AppColors.darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.greyText, fontSize: 14.sp),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final name = _nameController.text.trim();
          if (name.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a dish name')),
            );
            return;
          }
          Navigator.pop(context);
          widget.onSave({
            'name': name,
            'desc': _descController.text.trim(),
            'price': double.tryParse(_priceController.text) ?? 0.0,
            'isVeg': _isVeg,
            'isActive': true,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Add to Menu',
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
