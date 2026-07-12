import '../../../core/network/network_info.dart';
import 'bonuses_remote_datasource.dart';
import 'bonuses_repository.dart';

class BonusesRepositoryImpl implements BonusesRepository {
  final BonusesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BonusesRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Map<String, String>> get() async {
    return await remoteDataSource.get();
  }

  @override
  Future<void> update(Map<String, String> bonuses) async {
    await remoteDataSource.update(bonuses);
  }
}
