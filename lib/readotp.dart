import 'dart:async';
export 'model/message.dart';
import 'package:flutter/services.dart';
import 'package:readotp/model/message.dart';

/// Provides a stream of incoming SMS messages (OTP) using a platform event channel.
class ReadOtp {
  /// Event channel for receiving SMS messages from the native platform.
  static const EventChannel _channel = EventChannel('readotp');

  /// Controller for the stream of [Message] objects.
  final StreamController<Message> _controller =
      StreamController<Message>.broadcast();

  /// Subscription to the native event channel stream.
  StreamSubscription<dynamic>? _channelStreamSubscription;

  /// The stream of incoming SMS messages as [Message] objects.
  Stream<Message> get smsStream => _controller.stream;

  /// Starts listening to the native event channel and adds [Message] to [smsStream] when received.
  void start() {
    _channelStreamSubscription =
        _channel.receiveBroadcastStream().listen((event) {
      if (!_controller.isClosed && event != null) {
        _controller.sink.add(Message.fromList(event as List<dynamic>));
      }
    });
  }

  /// Disposes resources and cancels the stream subscription.
  void dispose() {
    _channelStreamSubscription?.cancel();
    _controller.close();
  }
}
