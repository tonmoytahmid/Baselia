import 'package:baseliae_flutter/Component/ContainerComponent.dart';
import 'package:baseliae_flutter/Helper/CardWidgets.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';


class Aboutscreen extends StatefulWidget {
  String? about;
  String?location;
  String?followerscount;
  String?followingcount;
  String?postcount;
   Aboutscreen({super.key,required this.about,required this.location,required this.followerscount,required this.followingcount,required this.postcount});

  @override
  State<Aboutscreen> createState() => _AboutscreenState();
}

class _AboutscreenState extends State<Aboutscreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whit,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About",
                  style: robotostyle(black, 20, FontWeight.w600),
                ),
                Text(
                  widget.about!,
                  style: robotostyle(black, 16, FontWeight.w400),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Location",
                  style: robotostyle(black, 20, FontWeight.w600),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    Text(
                      widget.location!,
                      style: robotostyle(black, 16, FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Containercomponent(data: widget.followerscount!, name: "Follower"),
                    Containercomponent(data: widget.followingcount!, name: "Following")
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Containercomponent(data: widget.postcount!, name: "Post"),
                    Containercomponent(data: "1.2", name: "Follower")
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "On the Web",
                  style: robotostyle(black, 20, FontWeight.w600),
                ),
          
                
                Cardwidgets(image: "assets/images/facebook.png",text: "Facebook"),
                 Cardwidgets(image: "assets/images/twitter.png",text: "Twitter"),
                  Cardwidgets(image: "assets/images/instagram.png",text: "Instagram"),
                   Cardwidgets(image: "assets/images/linkend.png",text: "Linkedin"),
              ],
            ),
          ),
        ));
  }
}
