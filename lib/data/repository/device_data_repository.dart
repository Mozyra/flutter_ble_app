import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import '../bluetooth/bluetooth_util.dart';
import 'package:fullled/domain/model/device.dart';
import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/model/file.dart';

enum BlueState {
  unknown,
  unavailable,
  unauthorized,
  turningOn,
  on,
  turningOff,
  off
}

enum BlueDeviceState {
  disconnected,
  connecting,
  connected,
  disconnecting
}

class DeviceDataRepository extends DeviceRepository {
  final BluetoothUtil _bluetoothUtil;
  BlueState bluetoothState;
  BlueDeviceState bluetoothDeviceState;

  DeviceDataRepository(this._bluetoothUtil);

  Stream<BlueState> blueState() {
    return _bluetoothUtil.getBluetoothState().map((state) {
      switch (state) {
        case BluetoothState.unknown:
          bluetoothState = BlueState.unknown;
          break;
        case BluetoothState.unavailable:
          bluetoothState = BlueState.unavailable;
          break;
        case BluetoothState.unauthorized:
          bluetoothState = BlueState.unauthorized;
          break;
        case BluetoothState.turningOn:
          bluetoothState = BlueState.turningOn;
          break;
        case BluetoothState.on:
          bluetoothState = BlueState.on;
          break;
        case BluetoothState.turningOff:
          bluetoothState = BlueState.turningOff;
          break;
        case BluetoothState.off:
          bluetoothState = BlueState.off;
          break;
      }
      return bluetoothState;
    });
  }

  Stream<BlueDeviceState> blueDeviceState(){
    return _bluetoothUtil.getBluetoothDeviceState().map((state) {
        switch (state) {
          case BluetoothDeviceState.disconnected:
            bluetoothDeviceState = BlueDeviceState.disconnected;
            break;
          case BluetoothDeviceState.connecting:
            bluetoothDeviceState = BlueDeviceState.connecting;
            break;
          case BluetoothDeviceState.connected:
            bluetoothDeviceState = BlueDeviceState.connected;
            break;
          case BluetoothDeviceState.disconnecting:
            bluetoothDeviceState = BlueDeviceState.disconnecting;
            break;
      }
        return bluetoothDeviceState;
    });
  }

  @override
  Future<List<Device>> getBluetoothDevices() async {
    return _bluetoothUtil.getBluetoothDevices();
  }

  Future<bool> connect(Device device) async {
    return await _bluetoothUtil.connect(device);
  }

  Future<void> disconnect() async {
    return _bluetoothUtil.disconnect();
  }

  Future<Null> reconnect() async {
    return _bluetoothUtil.reconnect();
  }

  Future<List<String>> getValues() async {
    return _bluetoothUtil.getValues();
  }

  Future<Null> sendText(String text) async {
    return _bluetoothUtil.sendText(text);
  }

  Future<List<File>> getFiles() async {
    return _bluetoothUtil.getFiles();
  }
}