import 'package:fullled/domain/bloc/scanner_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'device_repository_module.dart';

class DeviceModule {
  static ScannerBloc scannerBloc() {
    return ScannerBloc(DeviceRepositoryModule.deviceRepository(), LoaderBloc());
  }
}