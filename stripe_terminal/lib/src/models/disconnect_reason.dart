/// Possible reasons for Bluetooth reader disconnects.
enum DisconnectReason {
  /// Unexpected disconnect.
  unknown,

  /// Terminal.disconnectReader was called.
  disconnectRequested,

  /// Terminal.rebootReader was called.
  rebootRequested,

  /// Reader disconnected after performing its required security reboot. This will
  /// happen if the reader has been running for 24 hours. To control this you can
  /// call Terminal.rebootReader which will reset the 24 hour timer.
  securityReboot,

  /// Reader disconnected because its battery was critically low and needs to be charged before it can be used.
  criticallyLowBattery,

  /// Reader was powered off.
  poweredOff,

  /// Bluetooth was disabled on the device.
  bluetoothDisabled,
}
