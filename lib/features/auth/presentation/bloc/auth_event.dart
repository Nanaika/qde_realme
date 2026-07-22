abstract class AuthEvent {}

class LoginEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class RefreshEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}
