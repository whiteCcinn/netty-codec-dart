import 'dart:io';
import 'frame.dart';

class FixedLengthBasedFrameConn implements FrameConn {
  int frameLength;

  Socket? socket;

  static List<int> readBuffer = List.filled(0, 0, growable: true);

  FixedLengthBasedFrameConn(
      { this.socket,
       this.frameLength = 0,
       onReadFrame,
       onError,
       onDone}) {
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

    if (readBuffer.length == 0) {
      return List.empty();
    }

    List<int> data = List.filled(frameLength, 0, growable: false);
    List.copyRange(data, 0, List.from(readBuffer.getRange(0, frameLength)));
    readBuffer.removeRange(0, frameLength);

    return data;
  }

  @override
  Future WriteFrame(List<int> byte) async {
    if (byte.length % frameLength != 0) {
      throw Exception('UnexpectedFixedLength');
    }
    List<int> newByte = List.from(byte, growable: true);
    socket!.add(newByte);
    await socket!.flush();
  }

  @override
  Future Close() async {
    await socket!.close();
  }
}
