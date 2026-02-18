import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CaptionWidget extends StatefulWidget {
  final String caption;

  const CaptionWidget({super.key, required this.caption});

  @override
  State<CaptionWidget> createState() => _CaptionWidgetState();
}

class _CaptionWidgetState extends State<CaptionWidget> {
  dynamic _previewData;
  @override
  void initState() {
    super.initState();
    _fetchPreview();
  }

  void _fetchPreview() async {
    final Uri? uri = Uri.tryParse(widget.caption.trim());
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final data = await getPreviewData(widget.caption.trim());
       if (!mounted) return;

      setState(() {
        _previewData = data;
      });
    }
  }

  bool _isValidUrl(String text) {
    final Uri? uri = Uri.tryParse(text.trim());
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url.trim());

    debugPrint('Attempting to launch: $uri');

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the URL')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = _isValidUrl(widget.caption);
    if (isUrl && _previewData != null) {
      return LinkPreview(
        text: widget.caption.trim(),
        width: MediaQuery.of(context).size.width, // Required
        previewData: _previewData, // Can be null initially
        onPreviewDataFetched: (data) {
          setState(() {
            _previewData = data;
          });
        },
        // text: widget.caption.trim(),
        // previewData: _previewData!,
        previewBuilder: (context, data) {
          return GestureDetector(
            onTap: () => _launchURL(context, widget.caption.trim()),
            child: Card(
              color: whit,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.image != null)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(data.image!.url, fit: BoxFit.cover),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.title != null)
                          Text(
                            data.title!,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        // if (data.description != null)
                        //   Padding(
                        //     padding: const EdgeInsets.only(top: 8.0),
                        //     child: Text(
                        //       data.description!,
                        //       style: const TextStyle(fontSize: 14),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          widget.caption,
          style: const TextStyle(fontSize: 14),
        ),
      );
    }
  }
}
