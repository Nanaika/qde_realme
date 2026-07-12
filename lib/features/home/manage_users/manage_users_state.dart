import 'package:qde_realme/features/auth/data/models/user_model.dart';

import '../../../core/error/failures.dart';

abstract class ManageUsersState {}

class ManageUsersInitial extends ManageUsersState {}

class ManageUsersLoading extends ManageUsersState {}

class ManageUsersSuccess extends ManageUsersState {
  final List<UserModel> users;
  ManageUsersSuccess({required this.users});
}

class ManageUsersError extends ManageUsersState {
  final Failure failure;

  ManageUsersError(this.failure);
}
