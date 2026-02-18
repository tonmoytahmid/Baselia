import 'package:flutter/material.dart';

class ReplyCard extends StatefulWidget {
  final String profileImage;
  final String fullName;
  final String text;
  final String timestamp;
  final bool isLiked;
  final void Function()? onPressed;

  const ReplyCard({
    super.key,
    required this.profileImage,
    required this.fullName,
    required this.text,
    required this.timestamp,
    required this.isLiked,
    this.onPressed,
  });

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.isLiked;
  }

  void _handleLikePressed() {
    setState(() {
      liked = !liked;
    });
    if (widget.onPressed != null) {
      widget.onPressed!(); // Trigger external like logic (e.g., Firestore update)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 45, bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with avatar, name, timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.profileImage),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                widget.timestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.text, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: _handleLikePressed,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: liked ? Colors.red : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.reply, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
