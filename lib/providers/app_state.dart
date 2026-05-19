import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/file_node.dart';

class AppState extends ChangeNotifier {
  Directory? _rootDirectory;
  final List<FileNode> _openTabs = [];
  FileNode? _activeTab;

  Directory? get rootDirectory => _rootDirectory;
  List<FileNode> get openTabs => List.unmodifiable(_openTabs);
  FileNode? get activeTab => _activeTab;

  Future<void> openFolder() async {
    final granted = await _requestStoragePermission();
    if (!granted) return;

    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null) return;

    _rootDirectory = Directory(path);
    _openTabs.clear();
    _activeTab = null;
    notifyListeners();
  }

  void openFile(FileNode node) {
    if (node.isDirectory) return;
    final existing = _openTabs.indexWhere((t) => t.path == node.path);
    if (existing == -1) {
      _openTabs.add(node);
    }
    _activeTab = _openTabs.firstWhere((t) => t.path == node.path);
    notifyListeners();
  }

  void closeTab(FileNode node) {
    final idx = _openTabs.indexWhere((t) => t.path == node.path);
    if (idx == -1) return;
    _openTabs.removeAt(idx);
    if (_activeTab?.path == node.path) {
      if (_openTabs.isEmpty) {
        _activeTab = null;
      } else {
        _activeTab = _openTabs[idx.clamp(0, _openTabs.length - 1)];
      }
    }
    notifyListeners();
  }

  void setActiveTab(FileNode node) {
    _activeTab = node;
    notifyListeners();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 11+ (API 30+): MANAGE_EXTERNAL_STORAGE — .request() opens
      // the "All files access" settings page automatically.
      final manageStatus = await Permission.manageExternalStorage.status;
      if (manageStatus.isGranted) return true;

      // This opens the Settings page; user must grant manually then return.
      await Permission.manageExternalStorage.request();
      final afterManage = await Permission.manageExternalStorage.status;
      if (afterManage.isGranted) return true;

      // Fallback for Android ≤ 10 (READ_EXTERNAL_STORAGE is sufficient)
      final readStatus = await Permission.storage.request();
      return readStatus.isGranted || readStatus.isLimited;
    }
    return true;
  }
}
