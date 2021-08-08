import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../lib/src/frame.dart';
import '../lib/src/length_field_based_frame_conn.dart';

void main() async {
  // bind the socket server to an address and port
  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4567);

  // listen for clent connections to the server
  server.listen((Socket socket) {
    handleConnection(socket);
  });
}

void handleConnection(Socket client) {
  print('Connection from'
      ' ${client.remoteAddress.address}:${client.remotePort}');
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
    fc.WriteFrame(utf8.encode('Hello too'));
  };

  LengthFieldBasedFrameConn(
    encoderConfig: encoderConfig,
    decoderConfig: decoderConfig,
    onReadFrame: onReadFrame,
    onError: (error) {
      print(error);
      client.close();
    },
    onDone: () {
      print('Client left');
      client.close();
    },
    socket: client,
  );
}
