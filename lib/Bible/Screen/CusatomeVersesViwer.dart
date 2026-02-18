import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CustomVerseViewer extends StatefulWidget {
  final List<Verse> verses;

  const CustomVerseViewer({super.key, required this.verses});

  @override
  State<CustomVerseViewer> createState() => _CustomVerseViewerState();
}

class Verse {
  final int id;
  final String text;

  Verse({required this.id, required this.text});
}

class _CustomVerseViewerState extends State<CustomVerseViewer> {
  final TextEditingController _controller = TextEditingController();
  TextSelection? _selection;
  final Set<int> _highlightedVerses = {};

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  void _updateControllerText() {
    // Compose full text from verses like "1. Verse text 2. Verse text ..."
    final fullText = widget.verses
        .map((v) => '${v.id}. ${v.text}')
        .join('  '); // double space between verses
    _controller.text = fullText;
  }

  // Find verse IDs that are in the selected text
  List<int> _getSelectedVerseIds() {
    if (_selection == null || !_selection!.isValid) return [];

    final selectedText = _selection == null
        ? ''
        : _controller.text.substring(_selection!.start, _selection!.end);

    List<int> selectedIds = [];

    for (final verse in widget.verses) {
      // Check if the verse ID and text appear in the selected text
      final verseString = '${verse.id}. ${verse.text}';
      if (selectedText.contains(verseString)) {
        selectedIds.add(verse.id);
      } else {
        // As fallback, check if verse id with dot is in selected text (partial select)
        if (selectedText.contains('${verse.id}.')) {
          selectedIds.add(verse.id);
        }
      }
    }
    return selectedIds;
  }

  void _copySelection() {
    final selectedText = _selection == null
        ? ''
        : _controller.text.substring(_selection!.start, _selection!.end);
    if (selectedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: selectedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void _shareSelection() {
    final selectedText = _selection == null
        ? ''
        : _controller.text.substring(_selection!.start, _selection!.end);
    if (selectedText.isNotEmpty) {
      Share.share(selectedText);
    }
  }

  void _toggleHighlight() {
    final selectedIds = _getSelectedVerseIds();
    setState(() {
      for (var id in selectedIds) {
        if (_highlightedVerses.contains(id)) {
          _highlightedVerses.remove(id);
        } else {
          _highlightedVerses.add(id);
        }
      }
      // Clear selection after highlight toggled
      _selection = null;
      // Remove text selection (force collapse)
      _controller.selection = TextSelection.collapsed(offset: -1);
    });
  }

  // Build RichText with highlighted verses styled differently
  TextSpan _buildHighlightedText() {
    List<TextSpan> spans = [];

    for (var verse in widget.verses) {
      final bool isHighlighted = _highlightedVerses.contains(verse.id);
      spans.add(TextSpan(
        text: '${verse.id}. ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isHighlighted ? Colors.orange : Colors.purple,
        ),
      ));
      spans.add(TextSpan(
        text: verse.text + '  ', // keep spaces between verses
        style: TextStyle(
          backgroundColor: isHighlighted ? Colors.yellow.withOpacity(0.5) : null,
          color: Colors.black87,
          fontSize: 15,
          height: 1.7,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RichText display for highlighting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: RichText(
            text: _buildHighlightedText(),
          ),
        ),

        // Readonly TextField to allow selection
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _controller,
            maxLines: null,
            readOnly: true,
            showCursor: false,
            enableInteractiveSelection: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: Colors.transparent, height: 0.1),
            cursorColor: Colors.transparent,
            // Hide text because we show RichText above
            onChanged: (text) {
              setState(() {
                _selection = _controller.selection;
              });
            },
          ),
        ),

        if (_selection != null &&
            _selection!.isValid &&
            _selection!.baseOffset != _selection!.extentOffset)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Wrap(
              spacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  onPressed: _copySelection,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.highlight),
                  label: const Text('Highlight'),
                  onPressed: _toggleHighlight,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  onPressed: _shareSelection,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
