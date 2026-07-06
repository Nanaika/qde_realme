import 'package:qde_realme/features/auth/data/models/user_model.dart';

abstract class ModerateUsersRepository {
  Future<List<UserModel>> getFirst();

  Future<List<UserModel>> getNext();

  bool get hasReachedMax;
}
