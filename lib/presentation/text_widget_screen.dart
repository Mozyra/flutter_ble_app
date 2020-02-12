import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flash/flash.dart';

import 'package:fullled/presentation/scanner_screen.dart';
import 'package:fullled/domain/bloc/text_widget_bloc.dart';
import 'package:fullled/internal/dependencies/application_component.dart';
import 'package:fullled/presentation/design/placeholders.dart';

class TextWidgetScreen extends StatefulWidget {

  @override
  _TextWidgetScreenState createState() => _TextWidgetScreenState();
}

class _TextWidgetScreenState extends State<TextWidgetScreen> {
  final _textWidgetBloc = TextWidgetModule.textWidgetBloc();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _controller = TextEditingController();
  String _labelText = 'Send english text to device';
  //StreamSubscription _blueState;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textWidgetBloc.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TextWidgetBloc, TextWidgetState> (
      listener: (context, state) {
        if (state is TextWidgetResultState) {
          _controller.clear();
          _showTopFlash();
        }
        if (state is TextWidgetToSettingsState) {
          _openScannerPage();
        }
        if (state is TextWidgetFailState) {
          _callSnapBar(state.error.toString());
        }
      },
      bloc: _textWidgetBloc,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _getAppBar(),
        body: _getBody(),
        floatingActionButton: _getFAB(),
      ),
    );
  }

  void _showTopFlash() {
    showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          boxShadows: [BoxShadow(blurRadius: 4)],
          //barrierBlur: 3.0,
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

  _callSnapBar(String text) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(),
        backgroundColor: Colors.red,
        content: Text(text),
      )
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text('Отправить сообщение'),
      actions: <Widget>[
        _getCloseButton(),
      ],
    );
  }

  Widget _getBody() {
    return SafeArea(
      child: _getTextField());
  }

  Widget _getFAB() {
    return BlocBuilder<TextWidgetBloc, TextWidgetState>(
      bloc: _textWidgetBloc,
      builder: (context, state) {
        if (state is TextWidgetFailState) {
          return FloatingActionButton(
            onPressed: () {
              _textWidgetBloc.add(TextWidgetBlueConnectingEvent());
            },
            child: Icon(Icons.refresh),
          );
        }
        if (state is TextWidgetConnectingState) {
          return FloatingActionButton(
            onPressed: () {
              //_textWidgetBloc.add(TextWidgetBlueConnectingEvent());
            },
            child: CircularProgressIndicator(backgroundColor: Colors.white,),
          );
        }
        else return Container();
      }
    );
  }

  Widget _getTextField() {
    return BlocBuilder<TextWidgetBloc, TextWidgetState>(
      bloc: _textWidgetBloc,
      builder: (context, state) {
        //if (state is TextWidgetResultState) ;
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
                      labelText: _labelText,
                    ),
                    onSubmitted: (_) {
                      if (state is TextWidgetFailState) {
                        return null;
                      }
                      else {
                        _textWidgetBloc.add(TextWidgetSendTextEvent(_controller.text));
                      }
                    }
                  ),
                  SizedBox(height: 10,),
                  RaisedButton(
                    onPressed: () {
                      if (state is TextWidgetFailState) {
                        return null;
                      }
                      else {
                        _textWidgetBloc.add(TextWidgetSendTextEvent(_controller.text));
                      }
                    },
                    child: Text('Отправить'),
                  ),
                ],
              ),
            ),
            if (state is TextWidgetLoadingState) Placeholders.loaderPlaceholder(),
          ],
        );
      },
    );
  }

  Widget _getCloseButton() {
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: () => _textWidgetBloc.add(TextWidgetSettingsEvent()),
    );
  }

  void _openScannerPage() {
    print('to Scanner');
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ScannerScreen()));
  }

}