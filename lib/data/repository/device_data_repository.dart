import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';

import 'package:fullled/data/bluetooth/bluetooth_util.dart';
import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/model/device.dart';
import 'package:fullled/domain/model/file.dart';
import 'package:fullled/domain/model/text_widget.dart';

class DeviceDataRepository extends DeviceRepository {
  final BluetoothUtil _bluetoothUtil;
  BlueState bluetoothState;
  BlueDeviceState bluetoothDeviceState;

  DeviceDataRepository(this._bluetoothUtil);

  @override
  Future<List<Device>> getBluetoothDevices() {
    return _bluetoothUtil.getBluetoothDevices();
  }

  @override
  Future<void> connect(Device device) {
    return _bluetoothUtil.connect(device);
  }

  @override
  Future<void> disconnect() {
    return _bluetoothUtil.disconnect();
  }

  @override
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

  @override
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
  Future<List<TextWidget>> getWidgets() async {
    final request = _encode('0;');
    final response = await _bluetoothUtil.sendRequest(request);
    final uuidList = _parseResponse(response).split(',');
    return uuidList
        .map((uuid) => TextWidget(uuid))
        .toList(growable: false);
  }

  @override
  Future<void> sendText(String uuid, String text) async {
    final request = _encode('1;$uuid;$text;');
    final response = await _bluetoothUtil.sendRequest(request);
    return _parseResponse(response);
  }

  @override
  Future<List<String>> getValues() async {
    await Future.delayed(Duration(seconds: 2));
    return ['a','2', '3', '4', '2', 'z'];
  }

  @override
  Future<List<File>> getFiles() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      File('Cat', 'png', FileType.IMAGE_FILE),
      File('Cat2', 'jpg', FileType.IMAGE_FILE)
    ];
  }

  String _parseResponse(List<int> response) {
    final result = _decode(response);
    final values = result.split(';');

    if (values.length > 1) {
      final responseId = values[0];
      final parameters = values[1];

      if (responseId == '0') {
        return parameters;
      } else {
        throw Exception(parameters);
      }
    }
    throw Exception('Unable to decode response');
  }

  List<int> _encode(String value) {
    final utf8encoder = Utf8Encoder();
    return utf8encoder.convert(value).toList(growable: false);
  }

  String _decode(List<int> values) {
    final utf8decoder = Utf8Decoder();
    return utf8decoder.convert(values);
  }
}

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