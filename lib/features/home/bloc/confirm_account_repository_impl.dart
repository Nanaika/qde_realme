import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';

import 'confirm_account_remote_datasource.dart';
import 'confirm_account_repository.dart';

class ConfirmAccountRepositoryImpl implements ConfirmAccountRepository {
  final ConfirmAccountRemoteDataSource  remoteDataSource;
  final NetworkInfo networkInfo;

  ConfirmAccountRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<dynamic> confirm(UserModel user) async {
    await remoteDataSource.confirm(user);
  }
}
