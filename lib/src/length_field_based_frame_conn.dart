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

  EncoderConfig(this.lengthFieldLength, this.lengthAdjustment,
      this.lengthIncludesLengthFieldLength);
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

  DecoderConfig(this.lengthFieldOffset, this.lengthFieldLength,
      this.lengthAdjustment, this.initialBytesToStrip);
}

class LengthFieldBasedFrameConn implements FrameConn {
  EncoderConfig encoderConfig;
  DecoderConfig decoderConfig;
  Socket socket;

  static List<int> readBuffer = List.filled(0, 0, growable: true);

  LengthFieldBasedFrameConn(
      this.encoderConfig, this.decoderConfig, this.socket) {
    socket.listen(ReadFrame);
  }

  @override
  void ReadFrame(List<int> list) {
    readBuffer.addAll(list);

    /// discard header(offset)s
    if (decoderConfig.lengthFieldOffset > 0) {
      Iterable<int> header =
          readBuffer.getRange(0, decoderConfig.lengthFieldOffset);
    }
  }

  Map<String, dynamic> getUnadjustedFrameLength() {
    var m = Map();
    switch (encoderConfig.lengthFieldLength) {
      case 1:
        {
            m['lenBuf'] =
        }
        break;
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
