import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flash/flash.dart';

import 'package:fullled/internal/dependencies/application_component.dart';
import 'package:fullled/domain/bloc/text_widget_bloc.dart';
import 'package:fullled/domain/bloc/loader_bloc.dart';
import 'package:fullled/domain/model/text_widget.dart';
import 'package:fullled/presentation/design/placeholders.dart';

class TextWidgetScreen extends StatefulWidget {
  final TextWidget textWidget;

  TextWidgetScreen(this.textWidget);

  @override
  _TextWidgetScreenState createState() => _TextWidgetScreenState();
}

class _TextWidgetScreenState extends State<TextWidgetScreen> {
  final _textWidgetBloc = TextWidgetModule.textWidgetBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _textWidgetBloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TextWidgetBloc, TextWidgetState> (
      bloc: _textWidgetBloc,
      listener: (context, state) {
        if (state is TextWidgetResultState) {
          _controller.clear();
          _showFlash();
        }
        if (state is TextWidgetFailState) {
          _showSnackBar(state.error.toString());
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _getAppBar(),
        body: _getBody(),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Отправить сообщение'),
    );
  }

  Widget _getBody() {
    return SafeArea(
      child: _getTextField()
    );
  }

  Widget _getTextField() {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Send english text to device',
                ),
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {
                  _textWidgetBloc.add(TextWidgetSendTextEvent(
                      widget.textWidget.uuid,
                      _controller.text
                  )
                  );
                },
                child: Text('Отправить'),
              ),
            ],
          ),
        ),
        _getLoader(),
      ],
    );
  }

  Widget _getLoader() {
    return BlocBuilder<LoaderBloc, LoaderState> (
      bloc: _textWidgetBloc.loaderBloc,
      builder: (context, state) {
        if (state is LoaderActiveState) {
          return Placeholders.loaderPlaceholder();
        } else {
          return Container();
        }
      },
    );
  }

  void _showFlash() {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierColor: Colors.black38,
          barrierDismissible: true,
          style: FlashStyle.floating,
          position: FlashPosition.top,
          child: FlashBar(
            message: Text('Сообщение успешно отправлено!'),
            primaryAction: FlatButton(
              onPressed: () => controller.dismiss(),
              child: Text('Закрыть', style: TextStyle(color: Colors.blue)),
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(),
        backgroundColor: Colors.red,
        content: Text(text),
      ),
    );
  }
}