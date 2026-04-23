import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/food_menu_model.dart';

abstract class FoodMenuRemoteDataSource {
  Future<FoodMenuModel> getFoodMenu(String hostelId, String day);
  Future<void> saveFoodMenu(FoodMenuModel menu);
}

class FoodMenuRemoteDataSourceImpl implements FoodMenuRemoteDataSource {
  final Dio dio;

  FoodMenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<FoodMenuModel> getFoodMenu(String hostelId, String day) async {
    try {
      final response = await dio.get('${ApiConstants.foodMenu}/$hostelId/$day');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return FoodMenuModel.fromJson(data is Map<String, dynamic> ? data : {});
      } else {
        throw Exception('Failed to fetch food menu');
      }
    } on DioException catch (e) {
      // 404 means no menu set for this day — return empty
      if (e.response?.statusCode == 404) {
        return FoodMenuModel(hostelId: hostelId, day: day);
      }
      throw Exception('Error fetching food menu: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching food menu: $e');
    }
  }

  @override
  Future<void> saveFoodMenu(FoodMenuModel menu) async {
    try {
      final response = await dio.post(
        ApiConstants.foodMenu,
        data: menu.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save food menu');
      }
    } catch (e) {
      throw Exception('Error saving food menu: $e');
    }
  }
}
