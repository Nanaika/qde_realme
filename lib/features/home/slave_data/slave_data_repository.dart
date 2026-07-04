import 'package:qde_realme/features/home/slave_data/slave_data_model.dart';

abstract class SlaveDataRepository {
  Future<SlaveDataModel> getData(String id);
}
