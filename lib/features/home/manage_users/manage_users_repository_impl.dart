import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

import 'manage_users_remote_datasource.dart';
import 'manage_users_repository.dart';

class ManageUsersRepositoryImpl implements ManageUsersRepository {
  final ManageUsersRemoteDatasource remoteDataSource;
  final NetworkInfo networkInfo;

  ManageUsersRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<List<UserModel>> get() async {
    return await remoteDataSource.get();
  }

  @override
  Future<void> pay(String userId) async {
    await remoteDataSource.pay(userId);
  }
}
