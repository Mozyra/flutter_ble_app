import 'package:fullled/data/repository/device_data_repository.dart';

import '../model/device.dart';
import '../model/file.dart';

abstract class DeviceRepository {
  Future<List<Device>> getBluetoothDevices();
  Future<bool> connect(Device device);
  Future<void> disconnect();
  Future<Null> reconnect();
  Future<List<String>> getValues();
  Future<Null> sendText(String text);
  Future<List<File>> getFiles();
  Stream<BlueState> blueState();
  Stream<BlueDeviceState> blueDeviceState();
}