abstract class ManageUsersEvent {}

class ManageUsersGetEvent extends ManageUsersEvent {}

class ManageUsersPayEvent extends ManageUsersEvent {
  final String userId;
  ManageUsersPayEvent({required this.userId});
}
