import 'dart:convert';
import 'dart:io';
import '../lib/src/delimiter_based_frame_conn.dart';
import '../lib/src/frame.dart';

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
  var onReadFrame = (List<int> data, FrameConn fc) async {
    print(utf8.decode(data));
    await fc.WriteFrame(utf8.encode('Hello too'));
  };

  DelimiterBasedFrameConn(
    client,
    delimiter: "\r\n",
    onReadFrame: onReadFrame,
    onError: (error) {
      print(error);
      client.close();
    },
    onDone: () {
      print('Client left');
      client.close();
    },
  );
}
