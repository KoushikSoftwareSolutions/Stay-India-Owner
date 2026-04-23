class FoodItem {
  final String name;
  final String desc;
  final double price;
  final bool isVeg;
  final bool isActive;

  FoodItem({
    required this.name,
    this.desc = '',
    this.price = 0.0,
    this.isVeg = true,
    this.isActive = true,
  });
}

class FoodMenu {
  final String hostelId;
  final String day; // 'mon' | 'tue' | ... | 'sun'
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
  final List<FoodItem> snacks;

  FoodMenu({
    required this.hostelId,
    required this.day,
    this.breakfast = const [],
    this.lunch = const [],
    this.dinner = const [],
    this.snacks = const [],
  });
}
