import '../../domain/entities/food_menu.dart';

class FoodMenuModel extends FoodMenu {
  FoodMenuModel({
    required super.hostelId,
    required super.day,
    super.breakfast,
    super.lunch,
    super.dinner,
    super.snacks,
  });

  factory FoodMenuModel.fromJson(Map<String, dynamic> json) {
    List<FoodItem> extractItems(dynamic mealData) {
      if (mealData == null) return [];
      if (mealData is Map) {
        final items = mealData['items'];
        if (items is List) {
          return items.whereType<Map>().map((e) => FoodItem(
                name: e['name']?.toString() ?? '',
                desc: e['description']?.toString() ?? '',
                price: (e['price'] is num) ? (e['price'] as num).toDouble() : double.tryParse(e['price']?.toString() ?? '0') ?? 0.0,
                isVeg: e['foodType'] == 'VEG' || e['foodType'] == null,
                isActive: e['isAvailable'] ?? true,
              )).where((item) => item.name.isNotEmpty).toList();
        }
      }
      return [];
    }

    return FoodMenuModel(
      hostelId: json['hostel'] ?? '',
      day: json['day'] ?? '',
      breakfast: extractItems(json['breakfast']),
      lunch: extractItems(json['lunch']),
      dinner: extractItems(json['dinner']),
      snacks: extractItems(json['snacks']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> toItemObjects(List<FoodItem> items) =>
        items.map((item) => {
              'name': item.name,
              'description': item.desc,
              'price': item.price,
              'foodType': item.isVeg ? 'VEG' : 'NON_VEG',
              'isAvailable': item.isActive,
            }).toList();

    return {
      'hostelId': hostelId,
      'day': day,
      'breakfast': {'items': toItemObjects(breakfast)},
      'lunch': {'items': toItemObjects(lunch)},
      'dinner': {'items': toItemObjects(dinner)},
      'snacks': {'items': toItemObjects(snacks)},
    };
  }
}
