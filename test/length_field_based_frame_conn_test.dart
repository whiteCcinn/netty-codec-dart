import 'dart:convert';
import 'dart:io';

import '../lib/src/frame.dart';
import '../lib/src/length_field_based_frame_conn.dart';

void main() async {
  var serverUrl = '127.0.0.1';
  var serverPort = 4567;
  var socket;
  await Socket.connect(serverUrl, serverPort, timeout: Duration(seconds: 2))
      .then((s) {
    // print("connected");
    socket = s;
  }).onError((error, stackTrace) {
    // print("connect failed");
    print(error);
    print(stackTrace);
  });

  EncoderConfig encoderConfig = EncoderConfig(
      lengthFieldLength: 4,
      lengthAdjustment: 0,
      lengthIncludesLengthFieldLength: false);
  DecoderConfig decoderConfig = DecoderConfig(
      lengthFieldOffset: 0,
      lengthFieldLength: 4,
      lengthAdjustment: 0,
      initialBytesToStrip: 4);

  var onReadFrame = (List<int> data, FrameConn fc) {
    print(utf8.decode(data));
  };

  var fc = LengthFieldBasedFrameConn(
    encoderConfig: encoderConfig,
    decoderConfig: decoderConfig,
    socket: socket,
    onDone: null,
    onReadFrame: onReadFrame,
    onError: null,
  );

  var data = utf8.encode('Hello');
  await fc.WriteFrame(data);
}
