abstract class SlaveDataEvent {}

class GetDataEvent extends SlaveDataEvent {
  final String id;

  GetDataEvent(this.id);
}
