import 'package:flutter/material.dart';

class ForumsImageCarasule extends StatelessWidget {
  final List<String> images;
  
  const ForumsImageCarasule({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => 
                  Container(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}