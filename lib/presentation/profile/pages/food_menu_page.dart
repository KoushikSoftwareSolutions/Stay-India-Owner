import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/food_menu.dart';
import '../../../injection_container.dart';
import '../cubit/hostel_cubit.dart';
import '../cubit/hostel_state.dart';
import '../cubit/food_menu_cubit.dart';
import '../widgets/add_food_item_sheet.dart';
import '../../common_widgets/shimmer_loading.dart';

class FoodMenuPage extends StatefulWidget {
  const FoodMenuPage({super.key});

  @override
  State<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _mealTabController;
  late FoodMenuCubit _cubit;
  int _selectedDayIndex = 0;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

  // Local menu data natively using FoodItem structures
  final Map<String, Map<String, List<FoodItem>>> _menuData = {};

  @override
  void initState() {
    super.initState();
    _mealTabController = TabController(length: 4, vsync: this);
    _cubit = sl<FoodMenuCubit>();
    for (final day in _days) {
      _menuData[day] = {
        'Breakfast': [],
        'Lunch': [],
        'Dinner': [],
        'Snacks': [],
      };
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDay());
  }

  @override
  void dispose() {
    _mealTabController.dispose();
    _cubit.close();
    super.dispose();
  }

  String get _hostelId {
    final state = context.read<HostelCubit>().state;
    if (state is HostelLoaded && state.hostels.isNotEmpty) {
      return state.hostels[state.selectedHostelIndex].id;
    }
    return '';
  }

  void _loadDay() {
    final hostelId = _hostelId;
    if (hostelId.isEmpty) return;
    _cubit.loadMenu(hostelId, _dayKeys[_selectedDayIndex]);
  }

  void _applyMenuToLocal(FoodMenu menu) {
    final day = _days[_selectedDayIndex];
    setState(() {
      _menuData[day] = {
        'Breakfast': List<FoodItem>.from(menu.breakfast),
        'Lunch': List<FoodItem>.from(menu.lunch),
        'Dinner': List<FoodItem>.from(menu.dinner),
        'Snacks': List<FoodItem>.from(menu.snacks),
      };
    });
  }

  Future<void> _saveCurrentDay() async {
    final hostelId = _hostelId;
    if (hostelId.isEmpty) return;
    final day = _days[_selectedDayIndex];
    final menu = FoodMenu(
      hostelId: hostelId,
      day: _dayKeys[_selectedDayIndex],
      breakfast: _menuData[day]!['Breakfast']!,
      lunch: _menuData[day]!['Lunch']!,
      dinner: _menuData[day]!['Dinner']!,
      snacks: _menuData[day]!['Snacks']!,
    );
    await _cubit.saveMenu(menu);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<FoodMenuCubit, FoodMenuState>(
        listener: (context, state) {
          if (state is FoodMenuLoaded) {
            _applyMenuToLocal(state.menu);
          } else if (state is FoodMenuSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu saved successfully')),
            );
          } else if (state is FoodMenuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
              'Food Menu',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60.h),
              child: Column(
                children: [
                  _buildDaySelector(),
                  Divider(
                    height: 1,
                    color: AppColors.roomCardBorder.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              _buildMealTypeTabs(),
              Expanded(
                child: BlocBuilder<FoodMenuCubit, FoodMenuState>(
                  builder: (context, state) {
                    if (state is FoodMenuLoading) {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: 5,
                        itemBuilder: (context, index) => const TenantCardSkeleton(),
                      );
                    }
                    return TabBarView(
                      controller: _mealTabController,
                      children: _mealTypes
                          .map((type) => _buildFoodList(type))
                          .toList(),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => AddFoodItemSheet.show(
              context,
              day: _days[_selectedDayIndex],
              mealType: _mealTypes[_mealTabController.index],
              onSave: (itemData) {
                final day = _days[_selectedDayIndex];
                final mealType = _mealTypes[_mealTabController.index];
                setState(() {
                  _menuData[day]![mealType]!.add(FoodItem(
                    name: itemData['name'],
                    desc: itemData['desc'],
                    price: itemData['price'],
                    isVeg: itemData['isVeg'],
                    isActive: itemData['isActive'],
                  ));
                });
                _saveCurrentDay();
              },
            ),
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDayIndex = index);
              _loadDay();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.roomCardBorder,
                ),
              ),
              child: Text(
                _days[index],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.darkText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealTypeTabs() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.roomCardBorder),
        ),
        child: TabBar(
          controller: _mealTabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: AppColors.darkText,
          unselectedLabelColor: AppColors.greyText,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 13.sp),
          labelPadding: EdgeInsets.zero,
          tabs: _mealTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
    );
  }

  Widget _buildFoodList(String mealType) {
    final day = _days[_selectedDayIndex];
    final items = _menuData[day]?[mealType] ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48.sp,
                color: AppColors.greyText.withValues(alpha: 0.5)),
            SizedBox(height: 16.h),
            Text('No items added for this meal',
                style: TextStyle(fontSize: 15.sp, color: AppColors.greyText)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.roomCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _buildCategoryBadge(item.isVeg),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: item.isActive,
                      onChanged: (val) {
                         // Active state toggle logic locally
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: const Color(0xFFEAECF0),
                    ),
                  ),
                ],
              ),
              if (item.desc.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(item.desc,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.greyText)),
              ],
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (item.price > 0)
                    Text(
                      '₹${item.price}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _menuData[day]![mealType]!.removeAt(index);
                      });
                      _saveCurrentDay();
                    },
                    icon: Icon(Icons.delete_outline,
                        size: 20.sp, color: Colors.red.withValues(alpha: 0.7)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryBadge(bool isVeg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isVeg ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isVeg
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, size: 10.sp,
              color: isVeg ? Colors.green : Colors.red),
          SizedBox(width: 4.w),
          Text(
            isVeg ? 'Veg' : 'Non-Veg',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isVeg ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
