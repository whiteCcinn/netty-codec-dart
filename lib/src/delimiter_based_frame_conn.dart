import 'dart:io';
import 'frame.dart';

class DelimiterBasedFrameConn implements FrameConn {
  String delimiter;

  Socket socket;

  static List<int> readBuffer = List.filled(0, 0, growable: true);

  DelimiterBasedFrameConn({
    required this.socket,
    required this.delimiter,
    required onReadFrame,
    required onError,
    required onDone}) {
    socket.listen((List<int> list) async {
      /// Stick the TCP package
      while (true) {
        List<int> data = ReadFrame(list);
        if (data.isEmpty) {
          return;
        }
        if (onReadFrame != null) {
          await onReadFrame(data, this);
        }
        list = List.empty();
      }
    }, onDone: onDone, onError: onError);
  }

  @override
  List<int> ReadFrame(List<int> list) {
    readBuffer.addAll(list);
    var index = readBuffer.indexOf(delimiter.codeUnitAt(0));
    if (index > 0) {
      List<int> data = List.filled(index, 0, growable: true);
      List.copyRange(data, 0, List.from(readBuffer.getRange(0, index)));
      readBuffer.removeRange(0, index + 1);

      return data;
    }

    return List.empty();
  }

  @override
  Future WriteFrame(List<int> byte) async {
    List<int> newByte = List.from(byte, growable: true);
    newByte.add(delimiter.codeUnitAt(0));
    socket.add(newByte);
    await socket.flush();
  }

  @override
  Future Close() async {
    await socket.close();
  }
}
