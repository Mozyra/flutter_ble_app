import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/model/text_widget.dart';
import 'package:fullled/domain/repository/device_repository.dart';

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
    if (event is WidgetsListDisconnectEvent) {
      yield* _mapWidgetsListDisconnectToState();
    }
    if (event is WidgetsListWidgetSelectedEvent) {
      yield* _mapWidgetsListWidgetSelectedToState(event.textWidget);
    }
  }

  Stream<WidgetsListState> _mapWidgetsListRefreshToState() async* {
    yield WidgetsListLoadingState();
    try {
      final textWidgets = await _deviceRepository.getWidgets();
      yield WidgetsListResultState(textWidgets);
    } catch (error) {
      yield WidgetsListFailState(error);
    }
  }

  Stream<WidgetsListState> _mapWidgetsListDisconnectToState() async* {
    await _deviceRepository.disconnect();
    yield WidgetsListOpenScannerScreenState();
  }

  Stream<WidgetsListState> _mapWidgetsListWidgetSelectedToState(TextWidget textWidget) async* {
    loaderBloc.add(LoaderStartEvent());
    try {
      yield WidgetsListOpenWidgetScreenState(textWidget);
    } catch (error) {
      yield WidgetsListFailState(error);
    }
    loaderBloc.add(LoaderStopEvent());
  }
}

abstract class WidgetsListEvent {}

class WidgetsListRefreshEvent extends WidgetsListEvent {}
class WidgetsListDisconnectEvent extends WidgetsListEvent {}
class WidgetsListWidgetSelectedEvent extends WidgetsListEvent {
  final TextWidget textWidget;
  WidgetsListWidgetSelectedEvent(this.textWidget);
}

abstract class WidgetsListState {}

class WidgetsListLoadingState extends WidgetsListState {}
class WidgetsListResultState extends WidgetsListState {
  final List textWidgets;
  WidgetsListResultState(this.textWidgets);
}
class WidgetsListFailState extends WidgetsListState {
  final error;
  WidgetsListFailState(this.error);
}
class WidgetsListOpenScannerScreenState extends WidgetsListState {}
class WidgetsListOpenWidgetScreenState extends WidgetsListState {
  final TextWidget textWidget;
  WidgetsListOpenWidgetScreenState(this.textWidget);
}