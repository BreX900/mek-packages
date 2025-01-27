import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';

class AppPhysicalReaderDelegate with PhysicalReaderDelegate {
  @override
  void onAcceptTermsOfService() {
    print('onAcceptTermsOfService');
  }
}
