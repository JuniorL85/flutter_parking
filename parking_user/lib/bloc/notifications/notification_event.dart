part of 'notification_bloc.dart';

sealed class NotificationEvent {}

class ScheduleNotification extends NotificationEvent {
  final String id;
  final String title;
  final String content;
  final DateTime deliveryTime;

  ScheduleNotification(
      {required this.id,
      required this.title,
      required this.content,
      required this.deliveryTime});
}

class CancelNotification extends NotificationEvent {
  final String id;

  CancelNotification({
    required this.id,
  });
}

class RequestPermission extends NotificationEvent {
  RequestPermission();
}

// class NotificationActionReceived extends NotificationEvent {
//   final String actionId;
//   final String notificationId;

//   NotificationActionReceived({
//     required this.actionId,
//     required this.notificationId,
//   });

//   List<Object?> get props => [actionId, notificationId];
// }
