import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ModerateUsersRepository {
  Future<List<UserModel>> getFirst();

  Future<List<UserModel>> getNext();

  Future<void> moderateUser(bool isModerated, String userId);

  bool get hasReachedMax;
}
