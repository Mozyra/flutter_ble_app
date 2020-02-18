import 'package:fullled/data/repository/device_data_repository.dart';

import '../model/device.dart';
import '../model/file.dart';
import '../model/text_widget.dart';

abstract class DeviceRepository {
  Future<List<Device>> getBluetoothDevices();
  Future<void> connect(Device device);
  Future<void> disconnect();
  Stream<BlueState> blueState();
  Stream<BlueDeviceState> blueDeviceState();
  Future<List<TextWidget>> getWidgets();
  Future<void> sendText(String uuid, String text);

  Future<List<String>> getValues();
  Future<List<File>> getFiles();
}