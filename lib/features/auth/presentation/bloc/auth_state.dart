import 'package:qde_realme/features/auth/data/models/user_model.dart';

import '../../../../core/error/failures.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel currentUser;
  final bool isUserLoaded;
  final bool onModeration;

  AuthAuthenticated(this.currentUser, {this.isUserLoaded = false, this.onModeration = false});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final Failure failure;

  AuthError(this.failure);
}
