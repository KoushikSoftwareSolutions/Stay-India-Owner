import '../entities/food_menu.dart';

abstract class FoodMenuRepository {
  Future<FoodMenu> getFoodMenu(String hostelId, String day);
  Future<void> saveFoodMenu(FoodMenu menu);
}
