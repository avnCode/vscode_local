import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../models/file_node.dart';
import '../../theme/app_theme.dart';

class PdfViewer extends StatefulWidget {
  final FileNode file;
  const PdfViewer({super.key, required this.file});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VSCodeColors>()!;

    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load PDF: $_error',
          style: TextStyle(color: colors.muted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: widget.file.path,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          onRender: (pages) {
            if (mounted) setState(() { _totalPages = pages ?? 0; _isReady = true; });
          },
          onError: (error) {
            if (mounted) setState(() => _error = error.toString());
          },
          onPageError: (page, error) {
            if (mounted) setState(() => _error = 'Page $page: $error');
          },
          onPageChanged: (page, total) {
            if (mounted) setState(() { _currentPage = page ?? 0; _totalPages = total ?? 0; });
          },
        ),
        if (_isReady)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.sidebar.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1} / $_totalPages',
                style: TextStyle(color: colors.muted, fontSize: 12),
              ),
            ),
          ),
        if (!_isReady && _error == null)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
