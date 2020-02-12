import 'package:fullled/domain/bloc/file_content_bloc.dart';
import 'package:fullled/internal/dependencies/device/device_repository_module.dart';

class FileContentModule {
  static FileContentBloc fileContentBloc() {
    return FileContentBloc(DeviceRepositoryModule.deviceRepository());
  }
}
