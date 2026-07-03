import 'dart:io';

import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future login() async {
    if (Platform.isAndroid) {
      await remoteDataSource.signInWithGoogle();
    } else if (Platform.isIOS) {
      await remoteDataSource.signInWithApple();
    }
  }

  @override
  Future logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<UserModel> getCurrentUser(String id) async{
    return await remoteDataSource.getCurrentUser(id);
  }
}
