import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/data/repository/device_data_repository.dart';
import 'package:fullled/internal/dependencies/bluetooth/bluetooth_module.dart';

class DeviceRepositoryModule {
  static DeviceRepository _deviceDataRepository;

  static DeviceRepository deviceRepository() {
    if (_deviceDataRepository == null) {
      _deviceDataRepository = DeviceDataRepository(
        BluetoothModule.bluetoothUtil(),
      );
    }
    return _deviceDataRepository;
  }
}