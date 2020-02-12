
class File {
  final String name;
  final String extension;
  final FileType type;

  File(
    this.name,
    this.extension,
    this.type
  );

  String get path => '/assets/files/$name.$extension';
}

enum FileType {
  IMAGE_FILE,
  VIDEO_FILE,
  TEXT_FILE
}