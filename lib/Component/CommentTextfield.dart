import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';

class Commenttextfield extends StatelessWidget {
  TextEditingController? controller;
  void Function()? onPressed;
 
  Commenttextfield(
      {super.key, required this.controller, required this.onPressed,});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0XFFEEEBEF),
      height: 80,
      child: Row(
        children: [
          SizedBox(
            width: 5,
          ),
          // CircleAvatar(
          //       backgroundImage:
          //           NetworkImage(image?? ''),
          //       radius: 20,
          //     ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              onEditingComplete: () => FocusScope.of(context).unfocus(),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                  fillColor: whit,
                  filled: true,
                  hintText: "Add a comment",
                  hintStyle: robotostyle(purpal, 14, FontWeight.w400),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(8)))),
            ),
          ),
          IconButton(
              onPressed: onPressed,
              icon: Icon(
                Icons.send,
                color: purpal,
                size: 30,
              ))
        ],
      ),
    );
  }
}
