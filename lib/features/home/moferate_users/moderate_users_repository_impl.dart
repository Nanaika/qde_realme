import 'package:qde_realme/core/network/network_info.dart';

import '../../auth/data/models/user_model.dart';
import 'moderate_users_remote_datasource.dart';
import 'moderate_users_repository.dart';

class ModerateUsersRepositoryImpl implements ModerateUsersRepository {
  final ModerateUsersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ModerateUsersRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  bool hasReachedMax = false;

  @override
  Future<List<UserModel>> getFirst() async {
    hasReachedMax = false;

    final items = await remoteDataSource.getFirst();

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }

  @override
  Future<List<UserModel>> getNext() async {
    if (hasReachedMax) return [];

    final items = await remoteDataSource.getNext();

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }
}
