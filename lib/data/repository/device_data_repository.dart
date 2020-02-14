import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import '../bluetooth/bluetooth_util.dart';
import 'package:fullled/domain/model/device.dart';
import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/model/file.dart';
import 'package:fullled/domain/model/text_widget.dart';

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

  @override
  Future<List<File>> getFiles() async {
    return _bluetoothUtil.getFiles();
  }

  @override
  Future<Null> sendText(String uuid, String text) async {
    print(text);
    List<int> request = _getWriteRequest(uuid, text);
    await _bluetoothUtil.sendRequest(request);
    List<String> response = await _getResponse();
    if (response.isEmpty) {
      return await null;
    }
  }

  @override
  Future<List<TextWidget>> getWidgets() async {
    List<int> request = _getReadRequest();
    await _bluetoothUtil.sendRequest(request);
    Future.delayed(Duration(seconds: 2));
    List<String> response = await _getResponse();
    List<TextWidget> textWidgets = [];
    for (String uuid in response) {
      textWidgets.add(TextWidget(uuid));
    }
    return textWidgets;
  }

  Future<List<String>> _getResponse() async {
    List<int> unconvertedResponse = await _bluetoothUtil.getResponse();
    String response = _decode(unconvertedResponse);
    print(response);
    if (response.startsWith('0;')) {
      List<String> params = [];
      if (response == '0;') {
        return params;
      }
      response = response.substring(2, response.length-1);
      return params = response.split(';');
    }
    else {
      throw Exception(response.substring(2));
    }
  }

  List<int> _getReadRequest() {
    return _encode('0;');
  }

  List<int> _getWriteRequest(String uuid, String text) {
    return _encode('1;$uuid;$text;');
  }

  List<int> _encode(String command) {
    final utf8encoder = Utf8Encoder();
    print(utf8encoder.convert('0;'));
    return utf8encoder.convert(command);
  }

  String _decode(List<int> unconvertedResponse) {
    final utf8decoder = Utf8Decoder();
    return utf8decoder.convert(unconvertedResponse);
  }
}