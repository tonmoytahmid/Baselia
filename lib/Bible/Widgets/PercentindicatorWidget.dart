import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BookProgressWidget extends StatelessWidget {
  final double percentRead; // value between 0.0 to 1.0
 
  const BookProgressWidget({
    super.key,
    required this.percentRead,
   
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularPercentIndicator(
        radius: 30,
        lineWidth: 5.0,
        animation: true,
        percent: percentRead,
        center: Text(
          "${(percentRead * 100).toInt()}%",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
        ),
        
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: purpal,
        backgroundColor: Colors.grey[300]!,
      ),
    );
  }
}
