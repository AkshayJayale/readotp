import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readotp/readotp.dart';

void main() {
  // const channel = MethodChannel("readotp");
  TestWidgetsFlutterBinding.ensureInitialized();
  late final readotp plugin;
  setUpAll(() {
    plugin = readotp()..read();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      "readotp",
      const StandardMethodCodec().encodeSuccessEnvelope(
          ['Flutter', 'Sender798', 1659933434088.toString()]),
      (data) async {
        log('hello');
      },
    );
  });

  tearDown(() {
    plugin.dispose();
  });

  group('read sms plugin tests', () {
    test('instance', () {
      expect(plugin, isA<readotp>());
    });

    test('expect stream of type SMS', () {
      expect(plugin.smsStream, isA<Stream<Message>>());
    });

    test('check output', () {
      Message sms =
          Message.fromList(['Flutter', 'Sender798', 1659933434088.toString()]);
      final future = plugin.smsStream.first;
      future.then((val) {
        expect(val.body, sms.body);
        expect(val.sender, sms.sender);
        expect(val.timeReceived, sms.timeReceived);
      });
      expect(future, completes);
    });
  });
}
