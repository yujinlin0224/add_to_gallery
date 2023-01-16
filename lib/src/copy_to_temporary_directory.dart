import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

var _uuid = Uuid();

/// Copies the file to the Temporary Directory
Future<File> copyToTemporaryDirectory({
  required File originalFile,
  required String filename,
}) async {
  String fileExt = path.extension(originalFile.path);
  String dirPath =
      path.join((await getTemporaryDirectory()).path, 'add_to_gallery');
  await Directory(dirPath).create(recursive: true);
  String filePath = path.join(dirPath, '$filename$fileExt');
  return await originalFile.copy(filePath);
}
