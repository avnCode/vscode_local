import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/file_node.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import 'file_tile.dart';

class FileTree extends StatefulWidget {
  const FileTree({super.key});

  @override
  State<FileTree> createState() => _FileTreeState();
}

class _FileTreeState extends State<FileTree> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;
    final state = context.watch<AppState>();

    if (state.rootDirectory == null) {
      return Center(
        child: Text(
          'No folder open',
          style: TextStyle(color: colors.muted, fontSize: 13),
        ),
      );
    }

    final root = FileNode(
      path: state.rootDirectory!.path,
      name: state.rootDirectory!.path.split('/').last,
      isDirectory: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
          child: Text(
            root.name.toUpperCase(),
            style: TextStyle(
              color: colors.muted,
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: _buildChildren(root, 0, colors, context, state),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren(
    FileNode node,
    int depth,
    VSCodeColors colors,
    BuildContext context,
    AppState state,
  ) {
    final children = node.listChildren();
    final widgets = <Widget>[];

    for (final child in children) {
      widgets.add(
        FileTile(
          node: child,
          depth: depth,
          isExpanded: _expanded.contains(child.path),
          isActive: state.activeTab?.path == child.path,
          colors: colors,
          onTap: () {
            if (child.isDirectory) {
              setState(() {
                if (_expanded.contains(child.path)) {
                  _expanded.remove(child.path);
                } else {
                  _expanded.add(child.path);
                }
              });
            } else {
              context.read<AppState>().openFile(child);
              Navigator.of(context).pop(); // close drawer
            }
          },
        ),
      );

      if (child.isDirectory && _expanded.contains(child.path)) {
        widgets.addAll(_buildChildren(child, depth + 1, colors, context, state));
      }
    }

    return widgets;
  }
}
