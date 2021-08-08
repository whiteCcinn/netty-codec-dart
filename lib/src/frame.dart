/// refer to:
/// 1. https://github.com/netty/netty/blob/eb7f751ba519cbcab47d640cd18757f09d077b55/codec/src/main/java/io/netty/handler/codec/LengthFieldBasedFrameDecoder.java
/// 2. https://github.com/netty/netty/blob/eb7f751ba519cbcab47d640cd18757f09d077b55/codec/src/main/java/io/netty/handler/codec/LengthFieldPrepender.java

/// FrameConn is a conn that can send and receive framed data.
abstract class FrameConn {
  // Reads a "frame" from the connection.
  List<int> ReadFrame(List<int> data);

  // Writes a "frame" to the connection.
  Future WriteFrame(List<int> byte);

  // Closes the connections, truncates any buffers.
  Future Close();
}
