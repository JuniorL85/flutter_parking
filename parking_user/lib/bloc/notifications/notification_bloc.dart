import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'notification_state.dart';
part 'notification_event.dart';

class NotificationBloc
    extends HydratedBloc<NotificationEvent, NotificationState> {
  final NotificationsRepository repository;

  NotificationBloc(this.repository)
      : super(const NotificationState(scheduledIds: {})) {
    on<NotificationEvent>((event, emit) async {
      switch (event) {
        case ScheduleNotification(
            :final id,
            :final title,
            :final content,
            :final deliveryTime
          ):
          await _onScheduleNotification(deliveryTime, title, content, id, emit);

        case CancelNotification(:final id):
          await _onCancelNotification(id, emit);

        case RequestPermission():
          await _onRequestPermission(emit);

        // case NotificationActionReceived(:final actionId, :final notificationId):
        //   _onNotificationActionReceived(actionId, notificationId, emit);
      }
    });
  }

  Future<dynamic> _onRequestPermission(Emitter<NotificationState> emit) async {
    final permission = await repository.requestPermissions();
    emit(NotificationState(scheduledIds: const {}, permission: permission));
  }

  Future<void> _onCancelNotification(
      String id, Emitter<NotificationState> emit) async {
    final notificationId = state.scheduledIds[id];
    if (notificationId != null) {
      await repository.cancelScheduledNotificaion(notificationId);
      final newState = Map<String, int>.from(state.scheduledIds);
      newState.remove(id);
      emit(NotificationState(scheduledIds: newState));
    }
  }

  Future<void> _onScheduleNotification(DateTime deliveryTime, String title,
      String content, String id, Emitter<NotificationState> emit) async {
    var random = Random();

    int notificationId = random.nextInt((pow(2, 31).toInt() - 1));

    await repository.scheduleNotification(
        id: notificationId,
        title: title,
        content: content,
        deliveryTime: deliveryTime);

    final newState = Map<String, int>.from(state.scheduledIds);
    newState[id] = notificationId;
    emit(NotificationState(scheduledIds: newState));
  }

  // void _onNotificationActionReceived(
  //     String actionId, String notificationId, Emitter<NotificationState> emit) {
  //   print("User selected action: $actionId for notification: $notificationId");

  //   // You can store the response in the state if needed
  //   emit(
  //     NotificationState(
  //       scheduledIds: state.scheduledIds,
  //       lastAction: {'id': notificationId, 'action': actionId},
  //     ),
  //   );
  // }

  @override
  NotificationState? fromJson(Map<String, dynamic> json) {
    if (json['scheduledIds'] == null) {
      return const NotificationState(scheduledIds: {});
    } else {
      return NotificationState(scheduledIds: json['scheduledIds']);
    }
  }

  @override
  Map<String, dynamic>? toJson(NotificationState state) {
    return {'scheduledIds': state.scheduledIds};
  }
}
