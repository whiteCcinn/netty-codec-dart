import 'dart:typed_data';

ByteData NewByteData24(Endian byteOrder, int v) {
  var b = ByteData(3);
  if (byteOrder == Endian.little) {
    b.buffer.asUint8List()[0] = v;
    b.buffer.asUint8List()[1] = v >> 8;
    b.buffer.asUint8List()[2] = v >> 16;
  } else {
    b.buffer.asUint8List()[2] = v;
    b.buffer.asUint8List()[1] = v >> 8;
    b.buffer.asUint8List()[0] = v >> 16;
  }

  return b;
}

int ReadByteData24(Endian byteOrder, ByteData b) {
  if (byteOrder == Endian.little) {
    return b.buffer.asUint8List()[0] |
        b.buffer.asUint8List()[1] << 8 |
        b.buffer.asUint8List()[2] << 16;
  } else {
    return b.buffer.asUint8List()[2] |
    b.buffer.asUint8List()[1] << 8 |
    b.buffer.asUint8List()[0] << 16;
  }
}
