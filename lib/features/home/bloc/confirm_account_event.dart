import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ConfirmAccountEvent {}

class ConfirmEvent extends ConfirmAccountEvent {
  final UserModel user;
  ConfirmEvent(this.user);
}

