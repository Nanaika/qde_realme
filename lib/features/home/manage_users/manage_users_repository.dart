import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ManageUsersRepository {
  Future<List<UserModel>> get();
  Future<void> pay(String userId);
}
