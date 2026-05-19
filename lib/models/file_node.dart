import 'dart:io';

class FileNode {
  final String path;
  final String name;
  final bool isDirectory;

  FileNode({
    required this.path,
    required this.name,
    required this.isDirectory,
  });

  String get extension {
    if (isDirectory) return '';
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }

  FileType get fileType => FileTypeHelper.fromExtension(extension);

  List<FileNode> listChildren() {
    if (!isDirectory) return [];
    try {
      final dir = Directory(path);
      final entries = dir.listSync()
        ..sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.split('/').last.toLowerCase()
              .compareTo(b.path.split('/').last.toLowerCase());
        });
      return entries.map((e) {
        final name = e.path.split('/').last;
        return FileNode(
          path: e.path,
          name: name,
          isDirectory: e is Directory,
        );
      }).where((n) => !n.name.startsWith('.')).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String> readAsString() async {
    return File(path).readAsString();
  }
}

enum FileType {
  code,
  markdown,
  notebook,
  pdf,
  image,
  text,
  unsupported,
}

class FileTypeHelper {
  static const Map<String, FileType> _map = {
    'py': FileType.code,
    'js': FileType.code,
    'ts': FileType.code,
    'tsx': FileType.code,
    'jsx': FileType.code,
    'dart': FileType.code,
    'java': FileType.code,
    'kt': FileType.code,
    'cpp': FileType.code,
    'cc': FileType.code,
    'c': FileType.code,
    'h': FileType.code,
    'hpp': FileType.code,
    'go': FileType.code,
    'rs': FileType.code,
    'rb': FileType.code,
    'swift': FileType.code,
    'sh': FileType.code,
    'bash': FileType.code,
    'zsh': FileType.code,
    'yaml': FileType.code,
    'yml': FileType.code,
    'toml': FileType.code,
    'json': FileType.code,
    'html': FileType.code,
    'htm': FileType.code,
    'css': FileType.code,
    'scss': FileType.code,
    'xml': FileType.code,
    'sql': FileType.code,
    'r': FileType.code,
    'scala': FileType.code,
    'md': FileType.markdown,
    'markdown': FileType.markdown,
    'ipynb': FileType.notebook,
    'pdf': FileType.pdf,
    'png': FileType.image,
    'jpg': FileType.image,
    'jpeg': FileType.image,
    'gif': FileType.image,
    'webp': FileType.image,
    'bmp': FileType.image,
    'txt': FileType.text,
    'log': FileType.text,
    'csv': FileType.text,
    'tsv': FileType.text,
    'ini': FileType.text,
    'env': FileType.text,
    'conf': FileType.text,
    'cfg': FileType.text,
  };

  static FileType fromExtension(String ext) => _map[ext] ?? FileType.unsupported;

  /// Maps file extension to a highlight.js language identifier
  static String highlightLanguage(String ext) {
    const langs = {
      'py': 'python',
      'js': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'jsx': 'javascript',
      'dart': 'dart',
      'java': 'java',
      'kt': 'kotlin',
      'cpp': 'cpp',
      'cc': 'cpp',
      'c': 'c',
      'h': 'cpp',
      'hpp': 'cpp',
      'go': 'go',
      'rs': 'rust',
      'rb': 'ruby',
      'swift': 'swift',
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'yaml': 'yaml',
      'yml': 'yaml',
      'toml': 'ini',
      'json': 'json',
      'html': 'html',
      'htm': 'html',
      'css': 'css',
      'scss': 'scss',
      'xml': 'xml',
      'sql': 'sql',
      'r': 'r',
      'scala': 'scala',
    };
    return langs[ext] ?? 'plaintext';
  }
}
