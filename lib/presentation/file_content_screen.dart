import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/model/file.dart';
import 'package:fullled/domain/bloc/file_content_bloc.dart';
import 'package:fullled/internal/dependencies/application_component.dart';


class FileContentScreen extends StatefulWidget {
  final File _file;

  FileContentScreen(this._file);

  @override
  _FileContentScreenState createState() => _FileContentScreenState();
}

class _FileContentScreenState extends State<FileContentScreen> {
  final FileContentBloc _fileContentBloc = FileContentModule.fileContentBloc();

  @override
  void initState() {
    super.initState();
    _fileContentBloc.add(InitEvent());
  }

  @override
  void dispose() {
    _fileContentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget._file.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: _getBody()
    );
  }

  Widget _getBody() {
    return SafeArea(
        child: _getContentBuilder()
    );
  }

  Widget _getContentBuilder() {
    return BlocBuilder<FileContentBloc, FileContentState> (
      bloc: _fileContentBloc,
      condition: (prevState, curState) =>
      !(prevState is FileContentResultState) && !(curState is FileContentChangeTurnState),
      builder: (context, state) {
        if (state is FileContentLoadingState) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is FileContentResultState) {
          return _getContentLayout(state.value);
        }
        return Container();
      },
    );
  }

  Widget _getContentLayout(int value) {
    DragStartDetails startHorizontalDragDetails;
    DragUpdateDetails updateHorizontalDragDetails;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        startHorizontalDragDetails = details;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        updateHorizontalDragDetails = details;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        double dx = updateHorizontalDragDetails.globalPosition.dx -
          startHorizontalDragDetails.globalPosition.dx;
        double dy = updateHorizontalDragDetails.globalPosition.dy -
            startHorizontalDragDetails.globalPosition.dy;
        double velocity = details.primaryVelocity;

        if (dx < 0) dx = -dx;
        if (dy < 0) dy = -dy;

        if (velocity < 0) {
          _fileContentBloc.add(RightTurnEvent());
        }
        else if (velocity > 0) {
          _fileContentBloc.add(LeftTurnEvent());
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Spacer(flex: 3,),
          Expanded(
            flex: 4,
            child: Column(
              children: <Widget>[
                _getButtons(),
                SizedBox(height: 50,),
                BlocProvider(
                  create: (BuildContext context) => _fileContentBloc,
                  child: _getCounter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getButtons() {
    return Row(
      children: <Widget>[
      Expanded(
        flex: 1,
        child: _getButton(
          icon: Icon(Icons.keyboard_arrow_left),
            voidCallback: () => _fileContentBloc.add(LeftTurnEvent())
        ),
      ),
      Spacer(flex: 3),
      Expanded(
          flex: 1,
          child: _getButton(
              icon: Icon(Icons.keyboard_arrow_right),
              voidCallback: () => _fileContentBloc.add(RightTurnEvent())
          )
        )
      ],
    );
  }

  Widget _getButton({@required Icon icon, @required VoidCallback voidCallback}) {
    return Ink(
      decoration: const ShapeDecoration(
          color: Colors.black12,
          shape: CircleBorder()
      ),
      child: IconButton(
        icon: icon,
        onPressed: voidCallback,
      ),
    );
  }

  Widget _getCounter() {
    int value;

    return BlocBuilder<FileContentBloc, FileContentState>(
        builder: (context, state) {
          if (state is FileContentResultState) {
            value = state.value;
          }
          if (state is FileContentChangeTurnState) {
            value = state.value;
          }
          return Text('$value');
        }
    );
  }
}
