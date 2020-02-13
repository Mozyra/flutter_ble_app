import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fullled/data/repository/device_data_repository.dart';
import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';

class TextWidgetBloc extends Bloc<TextWidgetEvent, TextWidgetState> {
  final DeviceRepository _deviceRepository;
  final loaderBloc;

  StreamSubscription<BlueState> _blueStateSubscription;
  StreamSubscription<BlueDeviceState> _blueDeviceStateSubscription;

  BlueState currentState;
  BlueDeviceState currentDeviceState;

  TextWidgetBloc(this._deviceRepository, this.loaderBloc) {
    _blueStateSubscription = _deviceRepository
      .blueState()
      .listen((scanResult) {
        currentState = scanResult;
        if (scanResult == BlueState.off) {
          add(TextWidgetSettingsEvent());
        }
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
        lastState = scanResult;
        print(lastState);
      }
    );
  }

  @override
  TextWidgetState get initialState => TextWidgetNormalState();

  @override
  Future<void> close() {
    _blueStateSubscription?.cancel();
    _blueDeviceStateSubscription?.cancel();
    loaderBloc.close();
    return super.close();
  }

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
  }

  Stream<TextWidgetState> _mapTextWidgetSendToState(String text) async* {
    loaderBloc.add(LoaderStartEvent());
      try {
        await _deviceRepository.sendText(text);
        yield TextWidgetResultState();
      }
      catch (error) {
        yield TextWidgetFailState(error);
      }
    loaderBloc.add(LoaderStopEvent());
  }

  Stream<TextWidgetState> _mapTextWidgetSettingsToState() async* {
    await _deviceRepository.disconnect();
    yield TextWidgetToSettingsState();
  }

  Stream<TextWidgetState> _mapTextWidgetFailToState(error) async* {
    yield TextWidgetFailState(error);
  }
}

abstract class TextWidgetEvent {}

class TextWidgetSettingsEvent extends TextWidgetEvent {}
class TextWidgetSendTextEvent extends TextWidgetEvent {
  final String text;
  TextWidgetSendTextEvent(this.text);
}
class TextWidgetFailEvent extends TextWidgetEvent {
  final error;
  TextWidgetFailEvent(this.error);
}

abstract class TextWidgetState {}

class TextWidgetNormalState extends TextWidgetState {}
class TextWidgetResultState extends TextWidgetState {}
class TextWidgetToSettingsState extends TextWidgetState {}
class TextWidgetFailState extends TextWidgetState {
  final error;
  TextWidgetFailState(this.error);
}