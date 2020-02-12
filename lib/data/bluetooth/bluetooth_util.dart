import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:fullled/domain/model/device.dart';
import 'package:fullled/domain/model/file.dart';


class BluetoothUtil {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  Stream flutterBlueState;
  BluetoothState blueState = BluetoothState.unknown;
  BluetoothDeviceState bluetoothDeviceState;
  StreamSubscription scanSubscription;
  BluetoothDevice currentDevice;
  BluetoothState currentState;

  Map<String, BluetoothDevice> blueDevices = {};

  File cat = File('Cat', 'png', FileType.IMAGE_FILE);
  File anotherCat = File('Cat2', 'jpg', FileType.IMAGE_FILE);

  Future<List<Device>> getBluetoothDevices() async {
    blueDevices.clear();
    disconnect();
    if (await _flutterBlue.isOn) {
      List<Device> devicesNew = [];
      scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 3))
          .listen((scanResult) {
        if (!blueDevices.containsKey(scanResult.device.id.toString())) {
          blueDevices[scanResult.device.id.toString()] = scanResult.device;
          devicesNew.add(_blueDeviceToDevice(scanResult.device));
        }
      });
      await Future.delayed(Duration(milliseconds: 3500));
      _stopScan();
      return devicesNew;
    }
  }

  _stopScan() {
    _flutterBlue.stopScan();
    scanSubscription?.cancel();
    scanSubscription = null;
  }

  Future<List<File>> getFiles() async {
    disconnect();
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
    return isConnected();
  }

  Future<Null> sendText(String text) async {
    Utf8Encoder utf8encoder = Utf8Encoder();
    List<int> convertedText;
    convertedText = utf8encoder.convert(text);
    List<BluetoothService> services = await currentDevice.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic char in service.characteristics) {
        if (char.properties.write) {
          await char.write(convertedText);
          print('$text sended in ${char.uuid}.');
        }
      }
    }
  }

  Future disconnect() async {
    await currentDevice?.disconnect();
  }

  Future<Null> reconnect() async {
      await connect(_blueDeviceToDevice(currentDevice));
  }

  //Future<bool> isOn()

  Future<bool> isConnected() async {
    var state = await currentDevice.state.first;
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