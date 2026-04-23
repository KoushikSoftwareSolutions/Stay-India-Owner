import '../../domain/entities/food_menu.dart';
import '../../domain/repositories/food_menu_repository.dart';
import '../data_sources/food_menu_remote_data_source.dart';
import '../models/food_menu_model.dart';

class FoodMenuRepositoryImpl implements FoodMenuRepository {
  final FoodMenuRemoteDataSource remoteDataSource;

  FoodMenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FoodMenu> getFoodMenu(String hostelId, String day) {
    return remoteDataSource.getFoodMenu(hostelId, day);
  }

  @override
  Future<void> saveFoodMenu(FoodMenu menu) {
    return remoteDataSource.saveFoodMenu(FoodMenuModel(
      hostelId: menu.hostelId,
      day: menu.day,
      breakfast: menu.breakfast,
      lunch: menu.lunch,
      dinner: menu.dinner,
      snacks: menu.snacks,
    ));
  }
}
