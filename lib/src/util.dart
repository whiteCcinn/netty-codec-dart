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
