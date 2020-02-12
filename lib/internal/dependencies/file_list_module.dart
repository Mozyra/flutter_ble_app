import 'package:fullled/domain/bloc/file_list_bloc.dart';
import '../dependencies/device/device_repository_module.dart';

class FileModule {
  static FileBloc fileBloc() {
    return FileBloc(DeviceRepositoryModule.deviceRepository());
  }
}