import 'package:qde_realme/core/network/network_info.dart';
import 'package:qde_realme/features/home/history/history_model.dart';
import 'package:qde_realme/features/home/history/history_remote_datasource.dart';

import 'history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  bool hasReachedMax = false;

  @override
  Future<List<HistoryModel>> getFirst(String userId) async {
    hasReachedMax = false;

    final items = await remoteDataSource.getFirst(userId);

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }

  @override
  Future<List<HistoryModel>> getNext(String userId) async {
    if (hasReachedMax) return [];

    final items = await remoteDataSource.getNext(userId);

    if (items.isEmpty) {
      hasReachedMax = true;
    }

    return items;
  }
}
