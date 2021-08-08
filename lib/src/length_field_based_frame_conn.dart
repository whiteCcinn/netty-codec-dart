import 'dart:collection';
import 'dart:io';

import 'dart:typed_data';

import 'frame.dart';
import 'util.dart';

/// EncoderConfig config for encoder.
class EncoderConfig {
  /// LengthFieldLength is the length of the length field.
  int lengthFieldLength;

  /// LengthAdjustment is the compensation value to add to the value of the length field
  int lengthAdjustment;

  /// // LengthIncludesLengthFieldLength is true, the length of the prepended length field is added to the value of the prepended length field
  bool lengthIncludesLengthFieldLength;

  EncoderConfig(
      {required this.lengthFieldLength,
      required this.lengthAdjustment,
      required this.lengthIncludesLengthFieldLength});
}

/// DecoderConfig config for decoder.
class DecoderConfig {
  /// LengthFieldOffset is the offset of the length field
  int lengthFieldOffset;

  /// LengthFieldLength is the length of the length field
  int lengthFieldLength;

  /// LengthAdjustment is the compensation value to add to the value of the length field
  int lengthAdjustment;

  /// InitialBytesToStrip is the number of first bytes to strip out from the decoded frame
  int initialBytesToStrip;

  DecoderConfig(
      {required this.lengthFieldOffset,
      required this.lengthFieldLength,
      required this.lengthAdjustment,
      required this.initialBytesToStrip});
}

class LengthFieldBasedFrameConn implements FrameConn {
  EncoderConfig encoderConfig;
  DecoderConfig decoderConfig;

  /// if SocketClient, the socket must be set
  /// if SocketServer, the socket can not be set
  Socket socket;

  int bytesRead = 0;
  static List<int> readBuffer = List.filled(0, 0, growable: true);

  LengthFieldBasedFrameConn(
      {required this.encoderConfig,
      required this.decoderConfig,
      required this.socket,
      required onReadFrame,
      required onError,
      required onDone}) {
    socket.listen((List<int> list) {
      List<int> data = ReadFrame(list);
      if (onReadFrame != null) {
        onReadFrame(data, this);
      }
    }, onDone: onDone, onError: onError);
  }

  @override
  List<int> ReadFrame(List<int> list) {
    readBuffer.addAll(list);

    Iterable<int> header = Iterable.empty();

    /// discard header(offset)s
    if (decoderConfig.lengthFieldOffset > 0) {
      header = readBuffer.getRange(bytesRead, decoderConfig.lengthFieldOffset);
      bytesRead += decoderConfig.lengthFieldOffset;
    }

    Map<String, dynamic> m = getUnadjustedFrameLength();
    Iterable<int> lenBuf = m['lenBuf'];
    int frameLength = m['n'];

    /// real message length
    var msgLength = frameLength + decoderConfig.lengthAdjustment;
    var msg = readBuffer.getRange(bytesRead, bytesRead + msgLength);
    bytesRead += msgLength;

    var fullMessage = List.filled(header.length + lenBuf.length + msg.length, 0,
        growable: false);
    List.copyRange(fullMessage, fullMessage.length, List.from(header));
    List.copyRange(fullMessage, header.length, List.from(lenBuf));
    List.copyRange(fullMessage, header.length + lenBuf.length, List.from(msg));

    List<int> data = List.from(fullMessage.getRange(
        decoderConfig.initialBytesToStrip, fullMessage.length));

    readBuffer.removeRange(0, bytesRead);
    bytesRead = 0;

    return data;
  }

  Map<String, dynamic> getUnadjustedFrameLength() {
    var m = Map<String, dynamic>();
    switch (encoderConfig.lengthFieldLength) {
      case 1:
        {
          int byte = 1;
          var lenBuf = readBuffer.getRange(bytesRead, bytesRead + byte);
          m['lenBuf'] = lenBuf;
          bytesRead += byte;
          var b = ByteData.sublistView(Uint8List.fromList(lenBuf.toList()));
          m['n'] = b.getUint8(0);
        }
        break;
      case 2:
        {
          int byte = 2;
          var lenBuf = readBuffer.getRange(bytesRead, bytesRead + byte);
          m['lenBuf'] = lenBuf;
          bytesRead += byte;
          var b = ByteData.sublistView(Uint8List.fromList(lenBuf.toList()));
          m['n'] = b.getUint16(0, Endian.big);
        }
        break;
      case 3:
        {
          int byte = 3;
          var lenBuf = readBuffer.getRange(bytesRead, bytesRead + byte);
          m['lenBuf'] = lenBuf;
          bytesRead += byte;
          var b = ByteData.sublistView(Uint8List.fromList(lenBuf.toList()));
          m['n'] = ReadByteData24(Endian.big, b);
        }
        break;
      case 4:
        {
          int byte = 4;
          var lenBuf = readBuffer.getRange(bytesRead, bytesRead + byte);
          m['lenBuf'] = lenBuf;
          bytesRead += byte;
          var b = ByteData.sublistView(Uint8List.fromList(lenBuf.toList()));
          m['n'] = b.getUint32(0);
        }
        break;
      case 8:
        {
          int byte = 8;
          var lenBuf = readBuffer.getRange(bytesRead, bytesRead + byte);
          m['lenBuf'] = lenBuf;
          bytesRead += byte;
          var b = ByteData.sublistView(Uint8List.fromList(lenBuf.toList()));
          m['n'] = b.getUint64(0);
        }
        break;
      default:
        throw Exception('unSupport length');
    }

    return m;
  }

  @override
  Future WriteFrame(List<int> byte) async {
    var length = byte.length + encoderConfig.lengthAdjustment;
    if (encoderConfig.lengthIncludesLengthFieldLength) {
      length += encoderConfig.lengthFieldLength;
    }

    if (length < 0) {
      throw Exception('length < 0');
    }

    switch (encoderConfig.lengthFieldLength) {
      case 1:
        {
          if (length >= 256) {
            throw FormatException('length does not fit into a byte: ', length);
          }
          var b = new ByteData(1);
          b.setUint8(0, length);
          socket.add(b.buffer.asUint8List());
        }
        break;
      case 2:
        {
          if (length >= 65536) {
            throw FormatException(
                'length does not fit into a short integer: ', length);
          }
          var b = new ByteData(2);
          b.setUint16(0, length);
          socket.add(b.buffer.asUint8List());
        }
        break;
      case 3:
        {
          if (length >= 16777216) {
            throw FormatException(
                'length does not fit into a medium integer: ', length);
          }
          var b = NewByteData24(Endian.big, length);
          socket.add(b.buffer.asUint8List());
        }
        break;
      case 4:
        {
          var b = new ByteData(4);
          b.setUint32(0, length);
          socket.add(b.buffer.asUint8List());
        }
        break;
      case 8:
        {
          var b = new ByteData(8);
          b.setUint64(0, length);
          socket.add(b.buffer.asUint8List());
        }
        break;
      default:
        throw Exception('UnSupportLength');
    }

    socket.add(byte);
    await socket.flush();
  }

  @override
  Future Close() async {
    await socket.close();
  }
}
