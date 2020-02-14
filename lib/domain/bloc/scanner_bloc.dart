import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/model/device.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final DeviceRepository _deviceRepository;
  final LoaderBloc loaderBloc;

  ScannerBloc(this._deviceRepository, this.loaderBloc);

  @override
  ScannerState get initialState => ScannerLoadingState();

  @override
  Stream<ScannerState> mapEventToState(ScannerEvent event) async* {
    if (event is ScannerRefreshEvent) {
      yield* _mapScannerRefreshToState();
    }
    if (event is ScannerDeviceClickedEvent) {
      yield* _mapScannerDeviceOpenState(event.device);
    }
  }

  Stream<ScannerState> _mapScannerRefreshToState() async* {
    yield ScannerLoadingState();
    try {
      final devices = await _deviceRepository.getBluetoothDevices();
      yield ScannerResultState(devices);
    }
    catch (error) {
      yield ScannerFailState(error);
    }
  }

  Stream<ScannerState> _mapScannerDeviceOpenState(Device device) async* {
    loaderBloc.add(LoaderStartEvent());
    try {
      await _deviceRepository.connect(device);
      yield ScannerDeviceOpenState();
    } catch (error) {
      yield ScannerFailState(error);
    }
    loaderBloc.add(LoaderStopEvent());
  }
}

abstract class ScannerEvent {}

class ScannerRefreshEvent extends ScannerEvent {}
class ScannerDeviceClickedEvent extends ScannerEvent {
  final Device device;
  ScannerDeviceClickedEvent(this.device);
}

abstract class ScannerState {}

class ScannerLoadingState extends ScannerState {}
class ScannerDeviceOpenState extends ScannerState {}
class ScannerResultState extends ScannerState {
  final List devices;
  ScannerResultState(this.devices);
}
class ScannerFailState extends ScannerState {
  final error;
  ScannerFailState(this.error);
}

