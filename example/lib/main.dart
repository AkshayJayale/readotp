import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readotp/readotp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ReadOtp _readOtp = ReadOtp();
  String sms = 'No SMS received';
  String sender = 'No SMS received';
  String time = 'No SMS received';

  @override
  void initState() {
    super.initState();
    _requestPermissionAndListen();
  }

  Future<void> _requestPermissionAndListen() async {
    final granted = await _getPermission();
    if (granted) {
      _readOtp.start();
      _readOtp.smsStream.listen((event) {
        setState(() {
          sms = event.body;
          sender = event.sender;
          time = event.timeReceived.toString();
        });
      });
    }
  }

  Future<bool> _getPermission() async {
    if (await Permission.sms.status == PermissionStatus.granted) {
      return true;
    } else {
      return await Permission.sms.request() == PermissionStatus.granted;
    }
  }

  @override
  void dispose() {
    _readOtp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New SMS received: $sms'),
              Text('Sender: $sender'),
              Text('Received at: $time'),
            ],
          ),
        ),
      ),
    );
  }
}
