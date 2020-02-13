import 'package:fullled/domain/bloc/text_widget_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import '../dependencies/device/device_repository_module.dart';

class TextWidgetModule {
  static TextWidgetBloc textWidgetBloc() {
    return TextWidgetBloc(DeviceRepositoryModule.deviceRepository(), LoaderBloc);
  }
}