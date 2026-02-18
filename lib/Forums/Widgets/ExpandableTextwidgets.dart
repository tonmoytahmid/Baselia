import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';


class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;
  final double fixedHeight;

  const ExpandableText({super.key, 
    required this.text,
    this.trimLines = 5 ,
    this.style,
   required this.fixedHeight , // You can adjust height per use
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final span = TextSpan(text: widget.text, style: widget.style);
    final tp = TextPainter(
      text: span,
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width - 24);

    final isTextOverflow = tp.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.fixedHeight,
          child: SingleChildScrollView(
            physics: isExpanded ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
            child: Text(
              widget.text,
              maxLines: isExpanded ? null : widget.trimLines,
              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: widget.style,
            ),
          ),
        ),
        if (isTextOverflow)
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "See less" : "See more",
              style: TextStyle(color: purpal,fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
