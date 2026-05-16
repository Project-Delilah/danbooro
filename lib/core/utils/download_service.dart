import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  Future<String?> downloadImage(String url, String filename) async {
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('Could not access downloads directory');
      }

      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      await _dio.download(url, filePath);

      return filePath;
    } catch (e) {
      debugPrint('Download error: $e');
      return null;
    }
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      if (status.isPermanentlyDenied) {
        return await openAppSettings();
      }
      return status.isGranted;
    }
    return true;
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return await getDownloadsDirectory();
  }
}