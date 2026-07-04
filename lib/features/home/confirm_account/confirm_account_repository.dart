import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ConfirmAccountRepository {
  Future confirm(UserModel user);

}