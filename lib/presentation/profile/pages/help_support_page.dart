import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  int _expandedIndex = 0;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add a new tenant?',
      'answer':
          'Go to the Room Occupancy page, tap on any vacant bed, and select "Add Tenant". Fill in the tenant details including KYC documents and payment information.',
    },
    {
      'question': 'How do I collect rent payments?',
      'answer':
          'Select a tenant from the Tenants list, tap on "Add Payment", enter the amount and payment mode, and save to update the history.',
    },
    {
      'question': 'How do I transfer a tenant to another bed?',
      'answer':
          'Open the tenant details, select "Transfer Bed", choose the target room and bed number, and confirm the transfer.',
    },
    {
      'question': 'How do I process a tenant checkout?',
      'answer':
          'In the tenant details, tap on "Checkout", clear any outstanding dues, and confirm the release of the occupied bed.',
    },
    {
      'question': 'How do I manage staff access?',
      'answer':
          'Go to Staff Management in Settings to add new members and define their specific permission levels.',
    },
    {
      'question': 'How do I report a maintenance issue?',
      'answer':
          'Tenants can report via their app, or you can manually add a complaint in the "Complaints" section of the dashboard.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactActions(),
            SizedBox(height: 32.h),
            _buildSectionHeader(
              Icons.description_outlined,
              'Frequently Asked Questions',
            ),
            SizedBox(height: 16.h),
            _buildFaqList(),
            SizedBox(height: 32.h),
            _buildQuickLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildContactCard(
            'Call Us',
            Icons.phone_outlined,
            const Color(0xFF2C5EBD),
          ),
          SizedBox(width: 12.w),
          _buildContactCard(
            'WhatsApp',
            Icons.chat_bubble_outline,
            const Color(0xFF10B981),
          ),
          SizedBox(width: 12.w),
          _buildContactCard(
            'Email',
            Icons.mail_outline,
            const Color(0xFFF97316),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.darkText),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: List.generate(_faqs.length, (index) {
          final isExpanded = _expandedIndex == index;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isExpanded
                    ? AppColors.primaryBlue.withValues(alpha: 0.3)
                    : AppColors.roomCardBorder,
              ),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                onExpansionChanged: (expanded) {
                  if (expanded) setState(() => _expandedIndex = index);
                },
                title: Text(
                  _faqs[index]['question']!,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
                trailing: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.darkText,
                  size: 20.sp,
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: Text(
                      _faqs[index]['answer']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF667085),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          _buildLinkItem('Video Tutorials'),
          _buildLinkItem('User Guide (PDF)'),
          _buildLinkItem('Privacy Policy'),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.roomCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          Icon(Icons.open_in_new, size: 18.sp, color: const Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}
