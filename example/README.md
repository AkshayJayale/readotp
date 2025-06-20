# readotp_example

Demonstrates how to use the `readotp` plugin to receive incoming SMS (OTP) messages in a Flutter app.

## Getting Started

This project is a starting point for a Flutter application using the `readotp` plugin.

## Usage Notes

- **Permissions:**
  - This plugin requires SMS permissions. Make sure to request and handle SMS permissions at runtime using the [`permission_handler`](https://pub.dev/packages/permission_handler) package.
  - On Android, add the following permissions to your `AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />
    ```

- **Plugin Initialization:**
  - Create an instance of `ReadOtp` and call `start()` to begin listening for SMS messages.
  - Listen to the `smsStream` for incoming messages.
  - Always call `dispose()` when done to clean up resources.

### Example

```dart
final ReadOtp readOtp = ReadOtp();

// Request permission before starting
await Permission.sms.request();

readOtp.start();
readOtp.smsStream.listen((message) {
  print('Received SMS: \\${message.body} from \\${message.sender}');
});

// When done
readOtp.dispose();
```

For more details, see the main example in `example/lib/main.dart`.

---

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
