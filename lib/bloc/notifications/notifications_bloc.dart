import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';
import 'package:letscheck/global_router.dart';

class NotificationsBloc extends Bloc<NotificationEvent, NotificationsState> {
  NotificationsBloc() : super(NotificationsState(enabled: false, route: '')) {
    on<NotificationInit>((event, emit) async {
      if (event.payload != '') {
        emit(NotificationsState(
          enabled: event.enabled,
          route: event.payload,
        ));
      } else {
        emit(NotificationsState(
            enabled: event.enabled, route: GlobalRouter().buildUri(routeHome)));
      }
    });
  }
}
