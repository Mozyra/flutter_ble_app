import 'package:fullled/domain/bloc/widgets_list_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import '../dependencies/device/device_repository_module.dart';

class WidgetsListModule {
  static WidgetsListBloc widgetsListBloc() {
    return WidgetsListBloc(DeviceRepositoryModule.deviceRepository(), LoaderBloc());
  }
}