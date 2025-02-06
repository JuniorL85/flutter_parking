part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final Map<String, int> scheduledIds;
  final Map<String, String>? lastAction;

  const NotificationState({required this.scheduledIds, this.lastAction});

  bool isIdScheduled(String id) => scheduledIds.containsKey(id);

  @override
  List<Object?> get props => [scheduledIds];
}
