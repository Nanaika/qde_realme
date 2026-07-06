import 'package:qde_realme/features/auth/data/models/user_model.dart';

import '../../../core/error/failures.dart';

abstract class ModerateUsersState {}

class ModerateUsersInitial extends ModerateUsersState {}

class ModerateUsersLoading extends ModerateUsersState {}

class ModerateUsersSuccess extends ModerateUsersState {
  final List<UserModel> items;
  final bool isMoreLoading;
  final String? error;

  ModerateUsersSuccess({required this.items, this.isMoreLoading = false, this.error});

  ModerateUsersSuccess copyWith({List<UserModel>? items, bool? isMoreLoading, String? error}) {
    return ModerateUsersSuccess(
      items: items ?? this.items,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      error: error ?? this.error,
    );
  }
}

class ModerateUsersError extends ModerateUsersState {
  final Failure failure;

  ModerateUsersError(this.failure);
}
