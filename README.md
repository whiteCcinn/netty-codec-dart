# netty-codec-dart
Imp netty codec

- fixed_length
- delimiter_based
- length_field_based
- line_based

## length_field_based

### Server
```dart
dart --enable-asserts test/length_field_based_frame_conn_server_test.dart
Connection from 127.0.0.1:65257
Hello
```

### Client
```dart
dart --enable-asserts test/length_field_based_frame_conn_test.dart
连接成功
Hello too
```