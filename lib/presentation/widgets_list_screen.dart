import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/internal/dependencies/application_component.dart';
import 'package:fullled/domain/bloc/widgets_list_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/model/text_widget.dart';
import 'package:fullled/presentation/design/placeholders.dart';
import 'package:fullled/presentation/text_widget_screen.dart';
import 'package:fullled/presentation/scanner_screen.dart';

class WidgetsListScreen extends StatefulWidget {

  @override
  _WidgetsListScreenState createState() => _WidgetsListScreenState();
}

class _WidgetsListScreenState extends State<WidgetsListScreen> {
  final _widgetsListBloc = WidgetsListModule.widgetsListBloc();
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState.show();
    });
  }

  @override
  void dispose() {
    _widgetsListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WidgetsListBloc, WidgetsListState>(
      bloc: _widgetsListBloc,
      listener: (context, state) {
        if (state is WidgetsListResultState) {
          _refreshCompleter.complete();
        }
        if (state is WidgetsListFailState) {
          _refreshCompleter.complete();
        }
        if (state is WidgetsListOpenWidgetScreenState) {
          _openWidgetScreen(state.textWidget);
        }
        if (state is WidgetsListOpenScannerScreenState) {
          _openScannerScreen();
        }
      },
      child: Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Список виджетов'),
      actions: <Widget>[
        _getDisconnectAction(),
      ],
    );
  }

  Widget _getDisconnectAction() {
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: () => _widgetsListBloc.add(WidgetsListDisconnectEvent()),
    );
  }

  Widget _getBody() {
    return BlocBuilder<WidgetsListBloc, WidgetsListState>(
      bloc: _widgetsListBloc,
      builder: (context, state) {
        return Stack(
          children: <Widget>[
            _getLoader(),
            SafeArea(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  _refreshCompleter = Completer();
                  _widgetsListBloc.add(WidgetsListRefreshEvent());
                  return _refreshCompleter.future;
                },
                child: _getWidgetsListLayout(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getWidgetsListLayout() {
    return BlocBuilder<WidgetsListBloc, WidgetsListState>(
      bloc: _widgetsListBloc,
      condition: (previous, current) {
        return current is WidgetsListResultState
            || current is WidgetsListLoadingState
            || current is WidgetsListFailState;
      },
      builder: (context, state) {
        final widgets = List<Widget>();
        if (state is WidgetsListLoadingState) {
          widgets.add(Placeholders.stringPlaceholder('Загрузка...'));
        }
        if (state is WidgetsListFailState) {
          widgets.add(Placeholders.stringPlaceholder('${state.error}'));
        }
        if (state is WidgetsListResultState) {
          final listWidgets = _getListWidget(state.textWidgets);
          if (listWidgets.isEmpty) {
            widgets.add(Placeholders.stringPlaceholder('Виджеты не найдены'));
          } else {
            widgets.addAll(listWidgets);
          }
        }
        return _getResult(widgets);
      },
    );
  }

  Widget _getResult(List<Widget> textWidgets) {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: textWidgets.length,
      itemBuilder: (context, index) => textWidgets[index],
      separatorBuilder: (context, index) => Divider(height: 1.0),
    );
  }

  List<Widget> _getListWidget(List<TextWidget> widgets) {
    return widgets
        .map((textWidget) => _getWidgetItem(textWidget))
        .toList(growable: false);
  }

  Widget _getWidgetItem(TextWidget textWidget) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
        child: Text(
          textWidget.uuid,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () => _widgetsListBloc.add(WidgetsListWidgetSelectedEvent(textWidget)),
    );
  }

  Widget _getLoader() {
    return BlocBuilder<LoaderBloc, LoaderState> (
      bloc: _widgetsListBloc.loaderBloc,
      builder: (context, state) {
        if (state is LoaderActiveState) {
          return Placeholders.loaderPlaceholder();
        } else {
          return Container();
        }
      },
    );
  }

  void _openWidgetScreen(TextWidget textWidget) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TextWidgetScreen(textWidget)),
    );
  }

  void _openScannerScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ScannerScreen()),
    );
  }
}