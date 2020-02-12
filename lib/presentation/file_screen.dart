import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fullled/domain/bloc/file_list_bloc.dart';
import 'package:fullled/domain/model/file.dart';
import 'package:fullled/presentation/scanner_screen.dart';
import 'package:fullled/presentation/file_content_screen.dart';
import 'package:fullled/internal/dependencies/application_component.dart';

class FileListScreen extends StatefulWidget {

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  final FileBloc _fileBloc = FileModule.fileBloc();

  @override
  void initState() {
    super.initState();
    _fileBloc.add(FileLoadingEvent());
  }

  @override
  void dispose() {
    _fileBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileBloc, FileState> (
      listener: (context, state) {
        if (state is FileOpenState) _openFilePage(state.file);
        if (state is FileToSettingsState) _openSettingsPage();
      },
      bloc: _fileBloc,
      child: Scaffold(
        body: _getBody(),
        floatingActionButton: _getFAB(),
      ),
    );
  }

  Widget _getBody() {
    return SafeArea(
      child: _getContentBuilder(),
    );
  }

  Widget _getContentBuilder() {
    return BlocBuilder<FileBloc, FileState> (
      bloc: _fileBloc,
      condition: (prevState, curState) =>
      !(prevState is FileResultState) && !(curState is FileOpenState),
      builder: (context, state) {
        if (state is FileLoadingState) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is FileResultState) {
          return _getResult(state.files);
        }
        return Container();
      }
    );
  }

  _getResult(List<File> files) {
    List<Widget> filesWidgetList = _getFilesList(files);

    return ListView.separated(
        padding: EdgeInsets.all(10),
        itemCount: files.length,
        itemBuilder: (context, index) => filesWidgetList[index],
        separatorBuilder: (context, index) => SizedBox(height: 15,)
    );
  }

  List<Widget> _getFilesList(List<File> files) {
    return files
        .map((file) => _getFileItem(file))
        .toList(growable: false);
  }

  Widget _getFileItem(File file) {
    final name = file.name;
    final extension = file.extension;
    final type = file.type;

    return GestureDetector(
      onTap: () => _fileBloc.add(FileOpenEvent(file)),
      child: Container(
        height: 25,
        child: Row(
          children: <Widget>[
            _fileIcon(type),
            SizedBox(width: 25,),
            Text('$name.$extension', style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }

  Widget _fileIcon(FileType type) {
    if (type == FileType.IMAGE_FILE) {
      return Icon(Icons.image);
    }
    if (type == FileType.VIDEO_FILE) {
      return Icon(Icons.video_label);
    }
    if (type == FileType.TEXT_FILE) {
      return Icon(Icons.short_text);
    }
    else return Icon(Icons.do_not_disturb);
  }

  Widget _getFAB() {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => _fileBloc.add(FileSettingsEvent()),
    );
  }

  void _openSettingsPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => ScannerScreen()));
  }

  void _openFilePage(File file) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => FileContentScreen(file)));
  }
}