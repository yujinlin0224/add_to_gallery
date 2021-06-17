import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:save_to_gallery/files.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

/// Save images and videos to the gallery
class SaveToGallery {
  static const String channelName = 'save_to_gallery';
  static const String methodSaveImage = 'saveImage';
  static const String methodSaveVideo = 'saveVideo';

  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static const MethodChannel _channel = const MethodChannel(channelName);

  ///saves video from provided temp path and optional album name in gallery
  static Future<String> saveVideo(String path, {String? albumName}) async {
    File? tempFile;
    if (path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isVideo(path)) {
      throw ArgumentError(fileIsNotVideo);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path);
      path = tempFile.path;
    }
    var filePath = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }
    return filePath.toString();
  }

  ///saves image from provided temp path and optional album name in gallery
  static Future<String> saveImage(String path, {String? albumName}) async {
    File? tempFile;
    if (path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
    if (!isImage(path)) {
      throw ArgumentError(fileIsNotImage);
    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path);
      path = tempFile.path;
    }
    var filePath = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }
    return filePath.toString();
  }

  static Future<File> _downloadFile(String url) async {
    print(url);
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/${basename(url)}');
    await file.writeAsBytes(bytes);
    print('File size:${await file.length()}');
    print(file.path);
    return file;
  }
}