import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/scanner_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/model/device.dart';
import 'package:fullled/internal/dependencies/application_component.dart';
import 'package:fullled/presentation/widgets_list_screen.dart';
import 'package:fullled/presentation/design/placeholders.dart';

class ScannerScreen extends StatefulWidget {

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _scannerBloc = DeviceModule.scannerBloc();

  Completer<void> _refreshCompleter;
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState.show();
    });
  }

  @override
  void dispose() {
    _scannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerResultState) _refreshCompleter.complete();
        if (state is ScannerDeviceOpenState) _openDevicePage();
        if (state is ScannerFailState) _refreshCompleter.complete();
      },
      bloc: _scannerBloc,
      child: Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Список устройств'),
    );
  }

  Widget _getBody() {
    return BlocBuilder<ScannerBloc, ScannerState>(
      bloc: _scannerBloc,
      builder: (context, state) {
        return Stack(
          children: <Widget>[
            _getLoader(),
            SafeArea(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  _refreshCompleter = Completer();
                  _scannerBloc.add(ScannerRefreshEvent());
                  return _refreshCompleter.future;
                },
                child: _getScannerLayout(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getScannerLayout() {
    return BlocBuilder<ScannerBloc, ScannerState>(
      bloc: _scannerBloc,
      builder: (context, state) {
        final widgets = List<Widget>();
        if (state is ScannerLoadingState) {
          widgets.add(Placeholders.stringPlaceholder('Загрузка...')
          );
        }
        if (state is ScannerFailState) {
          widgets.add(Placeholders.stringPlaceholder('${state.error}'));
        }
        if (state is ScannerResultState) {
          List<Widget> listDevices = _getListDevice(state.devices);
          if (listDevices.isEmpty) {
            widgets.add(Placeholders.stringPlaceholder('Устройства не найдены'));
          }
          else widgets.addAll(listDevices);
        }
        return _getResult(widgets);
      },
    );
  }

  Widget _getResult(List<Widget> widgets) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widgets.length,
      itemBuilder: (context, index) => widgets[index],
      separatorBuilder: (context, index) => Divider(),
    );
  }

  List<Widget> _getListDevice(List<Device> devices) {
    return devices
        .map((device) => _getDeviceItem(device))
        .toList(growable: false);
  }

  Widget _getDeviceItem(Device device) {
    final name = device.name;
    final address = device.address;

    return InkWell(
      onTap: () => _scannerBloc.add(ScannerDeviceClickedEvent(device)),
      child: Container(
        height: 45,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _deviceIcon(),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (name != '') Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
                    overflow: TextOverflow.fade,
                  )
                  else Text(
                    'null',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    address,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getLoader() {
    return BlocBuilder<LoaderBloc, LoaderState> (
        bloc: _scannerBloc.loaderBloc,
        builder: (context, state) {
          if (state is LoaderActiveState) {
            return Placeholders.loaderPlaceholder();
          } else {
            return Container();
          }
        }
    );
  }

  Widget _deviceIcon() {
    return Icon(Icons.bluetooth);
  }

  void _openDevicePage() async {
    Navigator.pushReplacement(
      context,
//        MaterialPageRoute(builder: (context) => FileListScreen(device)));
      MaterialPageRoute(builder: (context) => WidgetsListScreen()),
    );
  }
}
