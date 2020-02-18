import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/repository/device_repository.dart';

class TextWidgetBloc extends Bloc<TextWidgetEvent, TextWidgetState> {
  final DeviceRepository _deviceRepository;
  final LoaderBloc loaderBloc;

  /*StreamSubscription<BlueState> _blueStateSubscription;
  StreamSubscription<BlueDeviceState> _blueDeviceStateSubscription;

  BlueState currentState;
  BlueDeviceState currentDeviceState;*/

  TextWidgetBloc(this._deviceRepository, this.loaderBloc) {
    /*_blueStateSubscription = _deviceRepository
      .blueState()
      .listen((scanResult) {
        currentState = scanResult;
        if (scanResult == BlueState.off) {
          add(TextWidgetDisconnectEvent());
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
    );*/
  }

  @override
  TextWidgetState get initialState => TextWidgetResultState();

  @override
  Future<void> close() {
    //_blueStateSubscription?.cancel();
    //_blueDeviceStateSubscription?.cancel();
    loaderBloc.close();
    return super.close();
  }

  @override
  Stream<TextWidgetState> mapEventToState(TextWidgetEvent event) async* {
    if (event is TextWidgetSendTextEvent) {
      yield* _mapTextWidgetSendToState(event.uuid, event.text);
    }
  }

  Stream<TextWidgetState> _mapTextWidgetSendToState(String uuid, String text) async* {
    loaderBloc.add(LoaderStartEvent());
    try {
      await _deviceRepository.sendText(uuid, text);
      yield TextWidgetResultState();
    } catch (error) {
      yield TextWidgetFailState(error);
    }
    loaderBloc.add(LoaderStopEvent());
  }
}

abstract class TextWidgetEvent {}

class TextWidgetSendTextEvent extends TextWidgetEvent {
  final String uuid;
  final String text;
  TextWidgetSendTextEvent(this.uuid, this.text);
}

abstract class TextWidgetState {}

class TextWidgetResultState extends TextWidgetState {}
class TextWidgetFailState extends TextWidgetState {
  final error;
  TextWidgetFailState(this.error);
}