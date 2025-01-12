import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {}

class NotificationInit extends NotificationEvent {
  final bool enabled;
  final String payload;

  NotificationInit({required this.enabled, required this.payload});

  @override
  List<Object> get props => [enabled, payload];

  @override
  String toString() => "Notification enabled='$enabled', payload='$payload'";
}
