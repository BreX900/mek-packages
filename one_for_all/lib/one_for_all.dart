library;

class ApiScheme {
  final Type hostExceptionCodes;
  final Type? flutterExceptionCodes;

  const ApiScheme({
    required this.hostExceptionCodes,
    this.flutterExceptionCodes,
  });
}

class DataScheme {
  const DataScheme();
}

class HostExceptionScheme {
  const HostExceptionScheme();
}

class FlutterExceptionScheme {
  const FlutterExceptionScheme();
}
