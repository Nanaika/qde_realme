import '../../../core/error/failures.dart';
import 'history_model.dart';

abstract class HistoryState {}

class HistoryStateInitial extends HistoryState {}

class HistoryStateLoading extends HistoryState {}

class HistoryStateSuccess extends HistoryState {
  final List<HistoryModel> items;
  final bool isMoreLoading;
  final String? error;

  HistoryStateSuccess({
    required this.items,
    this.isMoreLoading = false,
    this.error,
  });

  HistoryStateSuccess copyWith({
    List<HistoryModel>? items,
    bool? isMoreLoading,
    String? error,
  }) {
    return HistoryStateSuccess(
      items: items ?? this.items,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      error: error ?? this.error,
    );
  }
}

class HistoryStateError extends HistoryState {
  final Failure failure;

  HistoryStateError(this.failure);
}
