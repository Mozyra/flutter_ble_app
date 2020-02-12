import 'package:fullled/data/bluetooth/bluetooth_util.dart';

class BluetoothModule {
  static BluetoothUtil _bluetoothUtil;

  static BluetoothUtil bluetoothUtil() {
    if (_bluetoothUtil == null) {
      _bluetoothUtil = BluetoothUtil();
    }
    return _bluetoothUtil;
  }
}