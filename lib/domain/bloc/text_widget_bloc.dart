import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fullled/data/repository/device_data_repository.dart';

import 'package:fullled/domain/repository/device_repository.dart';

class TextWidgetBloc extends Bloc<TextWidgetEvent, TextWidgetState> {
  final DeviceRepository _deviceRepository;
  StreamSubscription<BlueState> _blueStateSubscription;
  StreamSubscription<BlueDeviceState> _blueDeviceStateSubscription;

  BlueState currentState;
  BlueDeviceState currentDeviceState;

  TextWidgetBloc(this._deviceRepository) {
    _blueStateSubscription = _deviceRepository
      .blueState()
      .listen((scanResult) {
        currentState = scanResult;
        if (scanResult == BlueState.off) {
          //const String text = 'Отключен Bluetooth';
          add(TextWidgetSettingsEvent());
        }
//        if (scanResult == BlueState.on) {
//          add(TextWidgetNormalEvent());
//        }
//        if (scanResult == BlueState.turningOn) {
//          add(TextWidgetBlueConnectingEvent());
//        }
        print(scanResult);
      }
    );
    _blueDeviceStateSubscription = _deviceRepository
      .blueDeviceState()
      .listen((scanResult) {
        BlueDeviceState lastState = BlueDeviceState.disconnected;
        currentDeviceState = scanResult;
        if (scanResult == BlueDeviceState.disconnected) {
          const String text = 'Bluetooth устройство отключено';
          add(TextWidgetFailEvent(text));
        }
        if (scanResult == BlueDeviceState.connected) {
          add(TextWidgetNormalEvent());
        }
        lastState = scanResult;
        print(lastState);
      }
    );
  }

  void stopSubscriptions() {
    _blueStateSubscription?.cancel();
    _blueDeviceStateSubscription?.cancel();
  }

  @override
  TextWidgetState get initialState => TextWidgetNormalState();

  @override
  Stream<TextWidgetState> mapEventToState(TextWidgetEvent event) async* {
    if (event is TextWidgetSendTextEvent) {
      yield* _mapTextWidgetSendToState(event.text);
    }
    if (event is TextWidgetSettingsEvent) {
      yield* _mapTextWidgetSettingsToState();
    }
    if (event is TextWidgetFailEvent) {
      yield* _mapTextWidgetFailToState(event.error);
    }
    if (event is TextWidgetBlueConnectingEvent) {
      yield* _mapTextWidgetBlueStateConnectingToState();
    }
    if (event is TextWidgetNormalEvent) {
      yield* _mapTextWidgetNormalToState();
    }
  }

  Stream<TextWidgetState> _mapTextWidgetSendToState(String text) async* {
    yield TextWidgetLoadingState();
      try {
        await _deviceRepository.sendText(text);
        yield TextWidgetResultState();
      }
      catch (e) {
        yield TextWidgetFailState(e);
        //yield TextWidgetNormalState();
      }
  }

  Stream<TextWidgetState> _mapTextWidgetSettingsToState() async* {
    await _deviceRepository.disconnect();
    stopSubscriptions();
    yield TextWidgetToSettingsState();
  }

  Stream<TextWidgetState> _mapTextWidgetFailToState(error) async* {
    yield TextWidgetFailState(error);
  }

  Stream<TextWidgetState> _mapTextWidgetBlueStateConnectingToState() async* {
    yield TextWidgetConnectingState();
    try {
      await _deviceRepository.reconnect();
      yield TextWidgetNormalState();
    }
    catch (e) {
      print('was error');
      print(e);
      yield TextWidgetFailState(e);
    }
  }

  Stream<TextWidgetState> _mapTextWidgetNormalToState() async* {
    yield TextWidgetNormalState();
  }
}

abstract class TextWidgetEvent {}

class TextWidgetSettingsEvent extends TextWidgetEvent {}
class TextWidgetSendTextEvent extends TextWidgetEvent {
  final String text;
  TextWidgetSendTextEvent(this.text);
}
class TextWidgetNormalEvent extends TextWidgetEvent {}
class TextWidgetBlueConnectingEvent extends TextWidgetEvent {}
class TextWidgetFailEvent extends TextWidgetEvent {
  final error;
  TextWidgetFailEvent(this.error);
}

abstract class TextWidgetState {}

class TextWidgetNormalState extends TextWidgetState {}
class TextWidgetConnectingState extends TextWidgetState {}
class TextWidgetLoadingState extends TextWidgetState {}
class TextWidgetResultState extends TextWidgetState {}
class TextWidgetToSettingsState extends TextWidgetState {}
class TextWidgetFailState extends TextWidgetState {
  final error;
  TextWidgetFailState(this.error);
}