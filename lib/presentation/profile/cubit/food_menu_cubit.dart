import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_menu.dart';
import '../../../domain/repositories/food_menu_repository.dart';

// States
abstract class FoodMenuState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodMenuInitial extends FoodMenuState {}

class FoodMenuLoading extends FoodMenuState {}

class FoodMenuLoaded extends FoodMenuState {
  final FoodMenu menu;
  FoodMenuLoaded(this.menu);
  @override
  List<Object?> get props => [menu];
}

class FoodMenuSaving extends FoodMenuState {}

class FoodMenuSaved extends FoodMenuState {}

class FoodMenuError extends FoodMenuState {
  final String message;
  FoodMenuError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class FoodMenuCubit extends Cubit<FoodMenuState> {
  final FoodMenuRepository foodMenuRepository;

  FoodMenuCubit({required this.foodMenuRepository}) : super(FoodMenuInitial());

  Future<void> loadMenu(String hostelId, String day) async {
    emit(FoodMenuLoading());
    try {
      final menu = await foodMenuRepository.getFoodMenu(hostelId, day);
      emit(FoodMenuLoaded(menu));
    } catch (e) {
      emit(FoodMenuError(e.toString()));
    }
  }

  Future<void> saveMenu(FoodMenu menu) async {
    emit(FoodMenuSaving());
    try {
      await foodMenuRepository.saveFoodMenu(menu);
      emit(FoodMenuSaved());
    } catch (e) {
      emit(FoodMenuError(e.toString()));
    }
  }
}
