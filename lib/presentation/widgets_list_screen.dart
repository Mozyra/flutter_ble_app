import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/widgets_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/internal/dependencies/application_component.dart';
import 'package:fullled/presentation/design/placeholders.dart';
import 'package:fullled/presentation/text_widget_screen.dart';
import 'package:fullled/domain/model/text_widget.dart';

class WidgetsListScreen extends StatefulWidget {

  @override
  _WidgetsListScreenState createState() => _WidgetsListScreenState();
}

class _WidgetsListScreenState extends State<WidgetsListScreen> {
  final _widgetsListBloc = WidgetsListModule.widgetsListBloc();
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
    _widgetsListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WidgetsListBloc, WidgetsListState>(
      listener: (context, state) {
        if (state is WidgetsListResultState) _refreshCompleter.complete();
        if (state is WidgetsListWidgetOpenState) _openWidgetPage(state.textWidget);
        if (state is WidgetsListFailState) _refreshCompleter.complete();
      },
      bloc: _widgetsListBloc,
      child: Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Список виджетов'),
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
      builder: (context, state) {
        final widgets = List<Widget>();
        if (state is WidgetsListLoadingState) {
          widgets.add(Placeholders.stringPlaceholder('Загрузка...')
          );
        }
        if (state is WidgetsListFailState) {
          widgets.add(Placeholders.stringPlaceholder('${state.error}'));
        }
        if (state is WidgetsListResultState) {
          List<Widget> listWidgets = _getListWidget(state.textWidgets);
          if (listWidgets.isEmpty) {
            widgets.add(Placeholders.stringPlaceholder('Устройства не найдены'));
          }
          else widgets.addAll(listWidgets);
        }
        return _getResult(widgets);
      },
    );
  }

  Widget _getResult(List<Widget> textWidgets) {
    return ListView.separated(
      padding: EdgeInsets.all(10),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: textWidgets.length,
      itemBuilder: (context, index) => textWidgets[index],
      separatorBuilder: (context, index) => Divider(),
    );
  }

  List<Widget> _getListWidget(List<TextWidget> widgets) {
    return widgets
        .map((textWidget) => _getWidgetItem(textWidget))
        .toList(growable: false);
  }

  Widget _getWidgetItem(TextWidget textWidget) {
    //final name = textWidget.name;
    final uuid = textWidget.uuid;

    return InkWell(
      onTap: () => _widgetsListBloc.add(WidgetsListClickedEvent(textWidget)),
      child: Container(
        height: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    uuid,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),
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
        bloc: _widgetsListBloc.loaderBloc,
        builder: (context, state) {
          if (state is LoaderActiveState) {
            return Placeholders.loaderPlaceholder();
          } else {
            return Container();
          }
        }
    );
  }

  void _openWidgetPage(TextWidget textWidget) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TextWidgetScreen(textWidget)),
    );
  }

}