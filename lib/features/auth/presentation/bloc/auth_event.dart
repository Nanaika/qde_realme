abstract class AuthEvent {}

class LoginEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class RefreshEvent extends AuthEvent {}

class DeleteUserEvent extends AuthEvent {
  final String userId;

  DeleteUserEvent({required this.userId});
}

class CheckAuthEvent extends AuthEvent {}
