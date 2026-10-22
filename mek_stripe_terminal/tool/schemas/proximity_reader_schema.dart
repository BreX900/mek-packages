import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class ProximityReaderPlatformApi {
  @async
  bool isAccountLinked({required String token});

  @async
  void linkAccount({required String token});

  @async
  void presentHowToTap();
}
