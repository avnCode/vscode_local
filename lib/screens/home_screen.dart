import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/file_node.dart';
import '../theme/app_theme.dart';
import '../widgets/file_explorer/file_tree.dart';
import '../widgets/viewers/code_viewer.dart';
import '../widgets/viewers/markdown_viewer.dart';
import '../widgets/viewers/pdf_viewer.dart';
import '../widgets/viewers/notebook_viewer.dart';
import '../widgets/viewers/image_viewer.dart';
import '../widgets/viewers/text_viewer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: _buildAppBar(context, colors),
      drawer: _buildDrawer(context, colors),
      body: Column(
        children: [
          _TabBar(colors: colors),
          Expanded(child: _ViewerArea(colors: colors)),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, VSCodeColors colors) {
    final state = context.watch<AppState>();
    final folderName = state.rootDirectory?.path.split('/').last ?? 'NDViewer';
    return AppBar(
      backgroundColor: colors.sidebar,
      title: Row(
        children: [
          Icon(Icons.folder_open, color: colors.accent, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              folderName,
              style: TextStyle(color: colors.onSurface, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.folder_open_outlined, color: colors.onSurface),
          tooltip: 'Open folder',
          onPressed: () => context.read<AppState>().openFolder(),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, VSCodeColors colors) {
    return Drawer(
      backgroundColor: colors.sidebar,
      child: const SafeArea(child: FileTree()),
    );
  }
}

class _TabBar extends StatelessWidget {
  final VSCodeColors colors;
  const _TabBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.openTabs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 35,
      color: colors.tabBar,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.openTabs.length,
        itemBuilder: (context, i) {
          final tab = state.openTabs[i];
          final isActive = state.activeTab?.path == tab.path;
          return _TabItem(
            tab: tab,
            isActive: isActive,
            colors: colors,
            onTap: () => context.read<AppState>().setActiveTab(tab),
            onClose: () => context.read<AppState>().closeTab(tab),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final FileNode tab;
  final bool isActive;
  final VSCodeColors colors;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TabItem({
    required this.tab,
    required this.isActive,
    required this.colors,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? colors.activeTab : colors.inactiveTab,
          border: Border(
            top: BorderSide(
              color: isActive ? colors.accent : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fileIcon(tab.extension, colors),
            const SizedBox(width: 5),
            Text(
              tab.name,
              style: TextStyle(
                color: isActive ? colors.onSurface : colors.muted,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onClose,
              child: Icon(Icons.close, size: 12, color: colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerArea extends StatelessWidget {
  final VSCodeColors colors;
  const _ViewerArea({required this.colors});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.rootDirectory == null) {
      return _Welcome(colors: colors);
    }

    if (state.activeTab == null) {
      return Center(
        child: Text(
          'Select a file to view',
          style: TextStyle(color: colors.muted, fontSize: 14),
        ),
      );
    }

    return _buildViewer(state.activeTab!);
  }

  Widget _buildViewer(FileNode file) {
    // ValueKey ensures a fresh widget state when the active file changes
    final key = ValueKey(file.path);
    switch (file.fileType) {
      case FileType.code:
        return CodeViewer(key: key, file: file);
      case FileType.markdown:
        return MarkdownViewer(key: key, file: file);
      case FileType.pdf:
        return PdfViewer(key: key, file: file);
      case FileType.notebook:
        return NotebookViewer(key: key, file: file);
      case FileType.image:
        return ImageViewer(key: key, file: file);
      case FileType.text:
        return TextViewer(key: key, file: file);
      case FileType.unsupported:
        return Center(
          child: Text(
            'Cannot preview .${file.extension} files',
            style: TextStyle(color: colors.muted),
          ),
        );
    }
  }
}

class _Welcome extends StatelessWidget {
  final VSCodeColors colors;
  const _Welcome({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: colors.muted),
          const SizedBox(height: 16),
          Text(
            'NDViewer',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the folder icon in the top-right to open a folder',
            style: TextStyle(color: colors.muted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Open Folder'),
            onPressed: () => context.read<AppState>().openFolder(),
          ),
        ],
      ),
    );
  }
}

Widget _fileIcon(String ext, VSCodeColors colors) {
  final color = _iconColor(ext, colors);
  final icon = _iconData(ext);
  return Icon(icon, size: 13, color: color);
}

Color _iconColor(String ext, VSCodeColors colors) {
  switch (ext) {
    case 'py':
      return const Color(0xFF4B8BBE);
    case 'md':
    case 'markdown':
      return const Color(0xFF519ABA);
    case 'json':
    case 'yaml':
    case 'yml':
      return const Color(0xFFCE9178);
    case 'ipynb':
      return const Color(0xFFE8A020);
    case 'pdf':
      return const Color(0xFFE74C3C);
    case 'dart':
      return const Color(0xFF54C5F8);
    default:
      return colors.muted;
  }
}

IconData _iconData(String ext) {
  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'png':
    case 'jpg':
    case 'jpeg':
    case 'gif':
    case 'webp':
    case 'bmp':
      return Icons.image_outlined;
    case 'md':
    case 'markdown':
      return Icons.article_outlined;
    case 'ipynb':
      return Icons.menu_book_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}
