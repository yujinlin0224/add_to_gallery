import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import 'package:add_to_gallery/src/copy_to_temporary_directory.dart';

/// Save images and videos to the gallery
class AddToGallery {
  static const MethodChannel _channel = MethodChannel('add_to_gallery');

  /// Makes a COPY of the file and saves it to the gallery
  ///
  /// Returns the path of the new file in the gallery
  static Future<File> addToGallery({
    /// The original file to copy to the gallery
    required File originalFile,

    /// Name of the album to save to, the album is created if necessary
    required String albumName,

    /// Name of the file to save to, if not specified, the original filename is used
    String? filename,

    /// Should we delete the original file after saving?
    bool deleteOriginalFile = false,
  }) async {
    // Is it an image or video?
    final fileType = lookupMimeType(originalFile.path);
    if (fileType == null ||
        !fileType.startsWith('image/') && !fileType.startsWith('video/')) {
      throw ArgumentError(
        'Path does not have an image or video file extension',
      );
    }
    // Copy the original file to a temporary directory
    File copiedFile = await copyToTemporaryDirectory(
      originalFile: originalFile,
      filename: filename ?? path.basenameWithoutExtension(originalFile.path),
    );

    // Save to gallery
    String? methodResults = await _channel.invokeMethod(
      'addToGallery',
      <String, dynamic>{
        'path': copiedFile.path,
        'album': albumName,
      },
    );
    // Nothing? Probably Android, return the copied file
    if (methodResults == null) {
      return copiedFile;
    }
    File galleryFile = File(methodResults.toString());
    // If the operation created a NEW file, delete our copy
    if (galleryFile.path != copiedFile.path) {
      copiedFile.delete();
    }
    // Delete the original file?
    if (deleteOriginalFile) {
      originalFile.delete();
    }
    // Return the new file
    return galleryFile;
  }
}
