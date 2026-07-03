import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/error/failures.dart';
import 'package:qde_realme/features/auth/domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    add(CheckAuthEvent());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await repository.login();

      final user = await repository.getCurrentUser(FirebaseAuth.instance.currentUser!.uid);

      emit(AuthAuthenticated(user));
    } on Failure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await repository.logout();
      emit(AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    if (FirebaseAuth.instance.currentUser != null) {
      final user = await repository.getCurrentUser(FirebaseAuth.instance.currentUser!.uid);
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
