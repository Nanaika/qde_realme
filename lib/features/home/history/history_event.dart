abstract class HistoryEvent {}

class HistoryGetFirstEvent extends HistoryEvent {
  final String userId;

  HistoryGetFirstEvent({required this.userId});
}

class HistoryGetNextEvent extends HistoryEvent {
  final String userId;

  HistoryGetNextEvent({required this.userId});
}
