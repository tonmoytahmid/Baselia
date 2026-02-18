import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';

class Containercomponent extends StatefulWidget {
  String data;
  String name;

  Containercomponent({super.key, required this.data, required this.name});

  @override
  State<Containercomponent> createState() => _ContainercomponentState();
}

class _ContainercomponentState extends State<Containercomponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83,
      width: 160,
      decoration: BoxDecoration(
          color: lightash, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
             formatCount(int.tryParse(widget.data) ?? 0),
              style: robotostyle(black, 20, FontWeight.w600),
            ),
            Text(
              widget.name,
              style: robotostyle(semigray, 15, FontWeight.w600),
            )
          ],
        ),
      ),
    );
  }
}

 String formatCount(int count) {
    if (count >= 1000) {
      double formattedCount = count / 1000;
      return "${formattedCount.toStringAsFixed(1)}K"; // Show one decimal place
    }
    return count.toString();
  }

