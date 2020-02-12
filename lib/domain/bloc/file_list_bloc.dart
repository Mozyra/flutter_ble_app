import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/model/file.dart';
import 'package:fullled/domain/repository/device_repository.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final DeviceRepository _deviceRepository;

  FileBloc(this._deviceRepository);

  @override
  FileState get initialState => FileLoadingState();

  @override
  Stream<FileState> mapEventToState(FileEvent event) async* {
    if (event is FileLoadingEvent) {
      yield* _mapFileLoadingToState();
    }
    if (event is FileOpenEvent) {
      yield* _mapFileOpenToState(event.file);
    }
    if (event is FileSettingsEvent) {
      yield* _mapFileSettingsToState();
    }
  }

  Stream<FileState> _mapFileLoadingToState() async* {
    yield FileLoadingState();
    List<File> files = await _deviceRepository.getFiles();
    yield FileResultState(files);
  }

  Stream<FileState> _mapFileOpenToState(File file) async* {
    yield FileOpenState(file);
  }

  Stream<FileState> _mapFileSettingsToState() async* {
    yield FileToSettingsState();
  }
}

abstract class FileEvent {}

class FileLoadingEvent extends FileEvent {}
class FileSettingsEvent extends FileEvent {}
class FileOpenEvent extends FileEvent {
  final File file;
  FileOpenEvent(this.file);
}

abstract class FileState {}

class FileLoadingState extends FileState {}
class FileToSettingsState extends FileState {}
class FileResultState extends FileState {
  final List<File> files;
  FileResultState(this.files);
}
class FileOpenState extends FileState {
  final File file;
  FileOpenState(this.file);
}
class FileFailState extends FileState {
  final error;
  FileFailState(this.error);
}

