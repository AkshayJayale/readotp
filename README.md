# readotp

A Flutter plugin to read incoming SMS (OTP) messages on the device as a broadcast stream.

## Usage

1. **Request SMS Permission**
   - Use the [`permission_handler`](https://pub.dev/packages/permission_handler) package to request SMS permissions at runtime.
   - On Android, add the following to your `AndroidManifest.xml`:
     ```xml
     <uses-permission android:name="android.permission.RECEIVE_SMS" />
     <uses-permission android:name="android.permission.READ_SMS" />
     ```

2. **Create and Start the Plugin**
   ```dart
   final readOtp = ReadOtp();
   await Permission.sms.request(); // Request permission before starting
   readOtp.start();
   ```

3. **Listen to the SMS Stream**
   ```dart
   readOtp.smsStream.listen((sms) {
     print(sms.body);
     print(sms.sender);
     print(sms.timeReceived);
   });
   ```

4. **Dispose When Done**
   ```dart
   readOtp.dispose();
   ```

That's all you need to do!

For a complete example, see [`example/lib/main.dart`](example/lib/main.dart).
