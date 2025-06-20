/// Represents an SMS message received by the application.
class Message {
  /// The body/content of the received message.
  final String body;

  /// The sender's contact address (phone number).
  final String sender;

  /// The timestamp when the SMS was received.
  final DateTime timeReceived;

  /// Creates a [Message] instance.
  const Message({
    required this.body,
    required this.sender,
    required this.timeReceived,
  });

  /// Creates a [Message] instance from a list of objects
  /// received from the broadcast stream of the event channel.
  ///
  /// [data] should be a list where:
  ///   - data[0]: message body (String)
  ///   - data[1]: sender address (String)
  ///   - data[2]: timestamp in milliseconds since epoch (String or int)
  factory Message.fromList(List<dynamic> data) {
    return Message(
      body: data[0] as String,
      sender: data[1] as String,
      timeReceived: DateTime.fromMillisecondsSinceEpoch(
        int.parse(data[2].toString()),
      ),
    );
  }
}
