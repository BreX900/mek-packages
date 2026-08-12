import 'package:mek_stripe_terminal/src/terminal_exception.dart';
import 'package:one_for_all/one_for_all.dart';

@SerializableClass(hostToFlutter: true)
class ClearCachedCredentialsResult {
  final bool isSuccessful;
  final TerminalException? error;

  const ClearCachedCredentialsResult({required this.isSuccessful, required this.error});
}
