import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fullled/domain/model/text_widget.dart';

import 'package:fullled/domain/repository/device_repository.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';

class WidgetsListBloc extends Bloc<WidgetsListEvent, WidgetsListState> {
  final DeviceRepository _deviceRepository;
  final loaderBloc;

  WidgetsListBloc(this._deviceRepository, this.loaderBloc);

  @override
  WidgetsListState get initialState => WidgetsListLoadingState();

  @override
  Stream<WidgetsListState> mapEventToState(WidgetsListEvent event) async* {
    if (event is WidgetsListRefreshEvent) {
      yield* _mapWidgetsListRefreshToState();
    }
    if (event is WidgetsListClickedEvent) {
      yield* _mapWidgetsListWidgetOpenState(event.textWidget);
    }
  }

  Stream<WidgetsListState> _mapWidgetsListRefreshToState() async* {
    yield WidgetsListLoadingState();
    try {
      final textWidgets = await _deviceRepository.getWidgets();
      yield WidgetsListResultState(textWidgets);
    }
    catch (error) {
      yield WidgetsListFailState(error);
    }
  }

  Stream<WidgetsListState> _mapWidgetsListWidgetOpenState(TextWidget textWidget) async* {
    loaderBloc.add(LoaderStartEvent());
    try {
      yield WidgetsListWidgetOpenState(textWidget);
    } catch (error) {
      yield WidgetsListFailState(error);
    }
    finally {
      loaderBloc.add(LoaderStopEvent());
    }
  }
}

abstract class WidgetsListEvent {}

class WidgetsListRefreshEvent extends WidgetsListEvent {}
class WidgetsListClickedEvent extends WidgetsListEvent {
  final TextWidget textWidget;
  WidgetsListClickedEvent(this.textWidget);
}

abstract class WidgetsListState {}

class WidgetsListLoadingState extends WidgetsListState {}
class WidgetsListWidgetOpenState extends WidgetsListState {
  final TextWidget textWidget;
  WidgetsListWidgetOpenState(this.textWidget);
}
class WidgetsListResultState extends WidgetsListState {
  final List textWidgets;
  WidgetsListResultState(this.textWidgets);
}
class WidgetsListFailState extends WidgetsListState {
  final error;
  WidgetsListFailState(this.error);
}
