import 'package:qde_realme/features/home/history/history_model.dart';

abstract class HistoryRepository {
  Future<List<HistoryModel>> getFirst(String userId);

  Future<List<HistoryModel>> getNext(String userId);

  bool get hasReachedMax;
}
