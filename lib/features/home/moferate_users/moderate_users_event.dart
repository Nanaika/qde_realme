abstract class ModerateUsersEvent {}

class ModerateUsersGetFirstEvent extends ModerateUsersEvent {}
class ModerateUsersGetNextEvent extends ModerateUsersEvent {}
class ModerateUserEvent extends ModerateUsersEvent {
  final bool isModerated;
  final String userId;

  ModerateUserEvent({this.isModerated = false, required this.userId});
}
