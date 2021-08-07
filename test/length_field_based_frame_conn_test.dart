import 'dart:io';

import 'dart:typed_data';

void main() {
  var b = new ByteData(2);
  b.setUint16(0, 65530);
  b.buffer.asUint8List()[1] = 2;
  print(b.buffer.asUint8List());


  // var header []byte
  // var err error
  // if fc.decoderConfig.LengthFieldOffset > 0 { //discard header(offset)
  // header, err = ReadN(fc.r, fc.decoderConfig.LengthFieldOffset)
  //   if err != nil {
  //   return nil, err
  //   }
  //   }
  //
  //   lenBuf, frameLength, err := fc.getUnadjustedFrameLength()
  //     if err != nil {
  //     return nil, err
  //     }
  //
  //     // real message length
  //     msgLength := int(frameLength) + fc.decoderConfig.LengthAdjustment
  // msg, err := ReadN(fc.r, msgLength)
  // if err != nil {
  // return nil, err
  // }
  //
  // fullMessage := make([]byte, len(header)+len(lenBuf)+msgLength)
  // copy(fullMessage, header)
  // copy(fullMessage[len(header):], lenBuf)
  // copy(fullMessage[len(header)+len(lenBuf):], msg)
  //
  // return fullMessage[fc.decoderConfig.InitialBytesToStrip:], nil
}
