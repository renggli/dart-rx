library rx.testing.test_message;

import 'package:rx/src/core/notifications.dart';

class TestMessage<T> {
  final int frame;
  final Notification<T> notification;

  TestMessage(this.frame, this.notification);
}
