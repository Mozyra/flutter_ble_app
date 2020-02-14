import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:fullled/domain/model/device.dart';
import 'package:fullled/domain/model/file.dart';

class BluetoothUtil {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription scanSubscription;
  BluetoothDevice currentDevice;
  BluetoothCharacteristic currentCharacteristic;
  String uuidDestination = '2a69e811-f1eb-4c2f-9086-7d6b7d682a2e';
  List<BluetoothService> services;
  Map<String, BluetoothDevice> blueDevices = {};

  File cat = File('Cat', 'png', FileType.IMAGE_FILE);
  File anotherCat = File('Cat2', 'jpg', FileType.IMAGE_FILE);

  Future<List<Device>> getBluetoothDevices() async {
    blueDevices.clear();
    disconnect();
    List<Device> devicesNew = [];
    if (await _flutterBlue.isOn) {
      scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 3))
          .listen((scanResult) {
        if (!blueDevices.containsKey(scanResult.device.id.toString())) {
          blueDevices[scanResult.device.id.toString()] = scanResult.device;
          devicesNew.add(_blueDeviceToDevice(scanResult.device));
        }
      });
      await Future.delayed(Duration(milliseconds: 3500));
      _stopScan();
    }
    return devicesNew;
  }

  _stopScan() {
    _flutterBlue.stopScan();
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  Future<Null> sendRequest(List<int> request) async {
    await currentCharacteristic.write(request);
  }

  Future<List<File>> getFiles() async {
    return Future.delayed(Duration(seconds: 1), () => [cat, anotherCat]);
  }

  Future<List<String>> getValues() async {
    return Future.delayed(Duration(seconds: 2), () => ['a','2', '3', '4', '2', 'z']);
  }

  Future<bool> connect(Device device) async {
    BluetoothDevice bluetoothDevice = _deviceToBlueDevice(device);
    await bluetoothDevice.connect(
        autoConnect: false, timeout: Duration(seconds: 5));
    currentDevice = bluetoothDevice;
    services = await currentDevice.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == uuidDestination) {
          currentCharacteristic = characteristic;
        }
      }
    }
    return isConnected();
  }

  Future<List<int>> getResponse() async {
    //await currentCharacteristic.setNotifyValue(true);
    List<int> response = [];
    StreamSubscription subscription = currentCharacteristic.value.listen((scanResult) {
      if (scanResult.length > response.length) {
        response = scanResult;
      }
    });
    await Future.delayed(Duration(seconds: 4));
    subscription.cancel();
    return response;
  }

  Future disconnect() async {
    List<BluetoothDevice> connectedDevices = await _flutterBlue.connectedDevices;
    for (BluetoothDevice connectedDevice in connectedDevices) {
      await connectedDevice.disconnect();
      Future.delayed(Duration(seconds: 6));
    }
    List<BluetoothDevice> connectedDevicesNew = await _flutterBlue.connectedDevices;
    for (var device in connectedDevicesNew) {
      print(device.name);
    }
  }

  Future<Null> reconnect() async {
      await connect(_blueDeviceToDevice(currentDevice));
  }

  Future<bool> isConnected() async {
    final state = await currentDevice.state.first;
    if (state == BluetoothDeviceState.connected) {
      return true;
    }
    else return false;
  }

  Stream<BluetoothState> getBluetoothState() async* {
    yield* _flutterBlue.state;
  }

  Stream<BluetoothDeviceState> getBluetoothDeviceState() async* {
    yield* currentDevice.state;
  }

  BluetoothDevice _deviceToBlueDevice(Device device) {
    return blueDevices[device.address];
  }

  Device _blueDeviceToDevice(BluetoothDevice device) {
    String name = device.name;
    String address = device.id.toString();
    return Device(name: name, address: address);
  }
}