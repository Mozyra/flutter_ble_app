import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/repository/device_repository.dart';

class FileContentBloc extends Bloc<FileContentEvent, FileContentState> {
  final DeviceRepository _deviceRepository;

  FileContentBloc(this._deviceRepository);

  int _counter = 1;
  int minCounter = 1;
  int _maxCounter;

  @override
  FileContentState get initialState => FileContentLoadingState();

  @override
  Stream<FileContentState> mapEventToState(FileContentEvent event) async* {
    if (event is InitEvent) {
      yield* _mapInitToState();
    }
    if (event is LeftTurnEvent) {
      yield* _mapLeftTurnToState();
    }
    if (event is RightTurnEvent) {
      yield* _mapRightTurnToState();
    }
  }

  Stream<FileContentState> _mapInitToState() async* {
    yield FileContentLoadingState();
    List<String> values = await _deviceRepository.getValues();
    _maxCounter = values.length;
    yield FileContentResultState(_counter);
  }

  Stream<FileContentState> _mapLeftTurnToState() async* {
    if (_counter - 1 < minCounter) {
      yield FileContentChangeTurnState(minCounter);
    }
    else {
      _counter--;
      yield FileContentChangeTurnState(_counter);
    }
  }

  Stream<FileContentState> _mapRightTurnToState() async* {
    if (_counter + 1 > _maxCounter) {
      yield FileContentChangeTurnState(_maxCounter);
    }
    else {
      _counter++;
      yield FileContentChangeTurnState(_counter);
    }
  }
}

abstract class FileContentEvent {}

class InitEvent extends FileContentEvent {}
class LeftTurnEvent extends FileContentEvent {}
class RightTurnEvent extends FileContentEvent {}

abstract class FileContentState {}

class FileContentLoadingState extends FileContentState {}
class FileContentResultState extends FileContentState {
  final int value;
  FileContentResultState(this.value);
}
class FileContentChangeTurnState extends FileContentState {
  final int value;
  FileContentChangeTurnState(this.value);
}