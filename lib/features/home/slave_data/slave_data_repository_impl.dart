import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_model.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_remote_datasource.dart';
import 'package:qde_realme/features/home/slave_data/slave_data_repository.dart';

class SlaveDataRepositoryImpl implements SlaveDataRepository {
  final SlaveDataRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SlaveDataRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<SlaveDataModel> getData(String id) async {
    return await remoteDataSource.getData(id);
  }
}
