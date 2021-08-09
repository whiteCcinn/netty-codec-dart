import 'dart:io';
import 'frame.dart';

class LineBasedFrameConn implements FrameConn {
  static const String flag = "\n";

  Socket? socket;

  static List<int> readBuffer = List.filled(0, 0, growable: true);

  LineBasedFrameConn({this.socket, onReadFrame, onError, onDone}) {
    socket!.listen((List<int> list) async {
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
    var index = readBuffer.indexOf(LineBasedFrameConn.flag.codeUnitAt(0));
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
    newByte.add(LineBasedFrameConn.flag.codeUnitAt(0));
    socket!.add(newByte);
    await socket!.flush();
  }

  @override
  Future Close() async {
    await socket!.close();
  }
}
