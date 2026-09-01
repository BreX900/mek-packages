import '../terminal_exception.dart';

class ClearCachedCredentialsResultApi {
  final bool isSuccessful;
  final TerminalExceptionApi? error;

  const ClearCachedCredentialsResultApi({required this.isSuccessful, required this.error});
}
