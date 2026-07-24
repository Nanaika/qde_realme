import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/core/error/failures.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/auth/domain/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<RefreshEvent>(_onRefreshUser);
    add(CheckAuthEvent());
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      await repository.login();

      // final user = await repository.getCurrentUser(FirebaseAuth.instance.currentUser!.uid);
      // print('============LOGIN===============  ${user}');
      //
      // emit(AuthAuthenticated(user, isUserLoaded: true));
      add(CheckAuthEvent());
    } on Failure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // await repository.logout();
      emit(AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(AuthError(failure));
    } catch (e) {
      emit(AuthError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    if (FirebaseAuth.instance.currentUser != null) {
      emit(
        AuthAuthenticated(
          UserModel(
            id: FirebaseAuth.instance.currentUser!.uid,
            email: FirebaseAuth.instance.currentUser!.email!,
          ),
          isUserLoaded: false,
        ),
      );

      final user = await repository.getCurrentUser(FirebaseAuth.instance.currentUser!.uid);
      emit(AuthAuthenticated(user, isUserLoaded: true));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshUser(RefreshEvent event, Emitter<AuthState> emit) async {
    final user = await repository.getCurrentUser(FirebaseAuth.instance.currentUser!.uid);
    emit(AuthAuthenticated(user));
  }
}
