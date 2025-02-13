part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final Map<String, int> scheduledIds;
  final Map<String, String>? lastAction;
  final bool? permission;

  const NotificationState(
      {required this.scheduledIds, this.lastAction, this.permission});

  bool isIdScheduled(String id) => scheduledIds.containsKey(id);

  @override
  List<Object?> get props => [scheduledIds];
}
