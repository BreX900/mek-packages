import 'dart:async';

import 'package:mek_stripe_terminal/src/models/disconnect_reason.dart';
import 'package:mek_stripe_terminal/src/models/reader.dart';
import 'package:mek_stripe_terminal/src/models/reader_software_update.dart';
import 'package:mek_stripe_terminal/src/terminal_exception.dart';

typedef Cancellable = Future<void> Function();

sealed class ReaderDelegateAbstract {}

/// The [ReaderDelegate] mixin is a common abstraction across the different listener interfaces.
/// It should exist for the entire duration of your connection to a reader. It will receive events
/// related to the status of the reader.
mixin ReaderDelegate {
  /// The Terminal reported an event from the reader (e.g. a card was inserted).
  void onReportReaderEvent(ReaderEvent event) {}
}

/// The [ReaderReconnectionDelegate] mixin is implemented in order to receive updates from auto reconnection.
///
/// If opting in to auto reconnections, [onReaderReconnectStarted] will be triggered instead of
/// [MobileReaderDelegate.onDisconnect].
mixin ReaderReconnectionDelegate {
  /// The reader has lost connection to the SDK and reconnection attempts have been started.
  ///
  /// In your implementation of this method, you should notify your user that the reader disconnected
  /// and that reconnection attempts are being made.
  void onReaderReconnectStarted(
    Reader reader,
    Cancellable cancelReconnect,
    DisconnectReason reason,
  ) {}

  /// The SDK was not able to reconnect to the previously connected bluetooth reader. The SDK is now
  /// disconnected from any readers.
  ///
  /// In your implementation of this method, you should notify your user that the reader has disconnected.
  ///
  /// Requires autoReconnectOnUnexpectedDisconnect is set to true in the [BluetoothConnectionConfig]
  void onReaderReconnectFailed(Reader reader) {}

  /// The SDK was able to reconnect to the previously connected Bluetooth reader.
  ///
  /// In your implementation of this method, you should notify your user that reader connection has
  /// been re-established.
  ///
  /// Requires autoReconnectOnUnexpectedDisconnect is set to true in the [BluetoothConnectionConfig]
  void onReaderReconnectSucceeded(Reader reader) {}
}

mixin ReaderDisconnectDelegate {
  /// Optional method that is called when the reader has disconnected from the SDK and includes the
  /// reason for the disconnect.
  void onDisconnect(DisconnectReason reason) {}
}

mixin ReaderPortableDelegate {
  /// The SDK is reporting that the reader has started installation of a required update that must
  /// be completed before the reader can be used.
  void onStartInstallingUpdate(ReaderSoftwareUpdate update, Cancellable cancelUpdate);

  /// The terminal reported progress on a reader software update.
  void onReportReaderSoftwareUpdateProgress(double progress);

  /// The terminal has finished installing a [ReaderSoftwareUpdate].
  void onFinishInstallingUpdate(ReaderSoftwareUpdate? update, TerminalException? exception);

  /// This method is called to request that a message be displayed in your app. For example, if the
  /// message is [ReaderDisplayMessage.swipeCard], your app should instruct the user to present the card again by swiping it.
  void onRequestReaderDisplayMessage(ReaderDisplayMessage message);

  /// This method is called when the reader begins waiting for input. Your app should prompt the
  /// customer to present a source using one of the given input options. If the reader emits a
  /// message, the [onRequestReaderDisplayMessage] method will be called.
  void onRequestReaderInput(List<ReaderInputOption> options);
}

/// The [MobileReaderDelegate] class is a listener that should exist for the entire duration of
/// your connection to a reader. It will receive events related to the status of the reader, as well
/// as opportunities to update the reader's software.
abstract class MobileReaderDelegate extends ReaderDelegateAbstract
    with
        ReaderDelegate,
        ReaderReconnectionDelegate,
        ReaderDisconnectDelegate,
        ReaderPortableDelegate {
  /// The Terminal reports [batteryLevel], [batteryStatus] and [isCharging] status every 10 minutes
  // ignore: avoid_positional_boolean_parameters
  void onBatteryLevelUpdate(double batteryLevel, BatteryStatus? batteryStatus, bool isCharging) {}

  /// The Terminal reported that the reader's battery level is low
  void onReportLowBatteryWarning() {}

  /// NOTE: An implementation of this method is required for bluetooth and usb readers.
  void onReportAvailableUpdate(ReaderSoftwareUpdate update);
}

/// The [HandoffReaderDelegate] class is a listener that should exist for the entire duration of
/// your connection to a reader. It will receive events related to the status of the reader.
abstract class HandoffReaderDelegate extends ReaderDelegateAbstract
    with ReaderDelegate, ReaderDisconnectDelegate {}

/// The [InternetReaderDelegate] class is a listener that should exist for the entire duration of
/// your connection to an internet reader. It will receive events related to the status of the reader.
abstract class InternetReaderDelegate extends ReaderDelegateAbstract
    with ReaderDisconnectDelegate {}

/// The [TapToPayReaderDelegate] class is a listener that should exist for the entire duration of
/// your connection to a tap-to-pay reader. It will receive events related to the status of the reader.
///
/// NOTE: [ReaderPortableDelegate] methods are required for IOS only
abstract class TapToPayReaderDelegate extends ReaderDelegateAbstract
    with ReaderReconnectionDelegate, ReaderDisconnectDelegate, ReaderPortableDelegate {
  /// The reader is reporting that, as part of preparing to accept payments, the terms of service
  /// has been accepted.
  void onAcceptTermsOfService() {}
}
