import 'dart:io';
import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:fullled/domain/model/device.dart';

class BluetoothUtil {
  static const _UUID_PATTERN = '0000ec0e';

  final _flutterBlue = FlutterBlue.instance;

  BluetoothDevice _currentDevice;
  Map<String, BluetoothDevice> _blueDevices = {};

  Future<List<Device>> getBluetoothDevices() async {
    _blueDevices.clear();
    disconnect();
    final deviceList = List<Device>();
    if (await _flutterBlue.isOn) {
      final scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 3))
          .listen((scanResult) {
        if (!_blueDevices.containsKey(scanResult.device.id.toString())) {
          _blueDevices[scanResult.device.id.toString()] = scanResult.device;
          deviceList.add(_blueDeviceToDevice(scanResult.device));
        }
      });
      await Future.delayed(Duration(milliseconds: 3500));
      await _flutterBlue.stopScan();
      await scanSubscription.cancel();
    }
    return deviceList;
  }

  Future<void> connect(Device device) async {
    BluetoothDevice bluetoothDevice = _deviceToBlueDevice(device);
    await bluetoothDevice.connect(
      autoConnect: false,
      timeout: Duration(seconds: 5),
    );
    if (Platform.isAndroid) {
      await bluetoothDevice.requestMtu(512);
    }
    _currentDevice = bluetoothDevice;
  }

  Future<void> disconnect() async {
    final connectedDevices = await _flutterBlue.connectedDevices;
    for (final device in connectedDevices) {
      await device.disconnect();
    }
  }

  Stream<BluetoothState> getBluetoothState() async* {
    yield* _flutterBlue.state;
  }

  Stream<BluetoothDeviceState> getBluetoothDeviceState() async* {
    yield* _currentDevice.state;
  }

  Future<List<int>> sendRequest(List<int> request) async {
    final characteristic = await _getCharacteristic();
    await characteristic.write(request);
    List<int> response = await characteristic.read();
    return response;
  }

  Future<BluetoothCharacteristic> _getCharacteristic() async {
    final services = await _currentDevice.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString().startsWith(_UUID_PATTERN)) {
          return characteristic;
        }
      }
    }
    throw 'Device is not supported';
  }

  BluetoothDevice _deviceToBlueDevice(Device device) {
    return _blueDevices[device.address];
  }

  Device _blueDeviceToDevice(BluetoothDevice device) {
    String name = device.name;
    String address = device.id.toString();
    return Device(name: name, address: address);
  }
}