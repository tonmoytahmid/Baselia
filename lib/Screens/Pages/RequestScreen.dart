
import 'package:baseliae_flutter/Fatching/Relationship/FatchingFollowers.dart';
import 'package:baseliae_flutter/Fatching/Relationship/FatchingFollowings.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:flutter/material.dart';



import '../../Fatching/Relationship/FatchingPending.dart';

class Requestscreen extends StatefulWidget {
  const Requestscreen({super.key});

  @override
  State<Requestscreen> createState() => _RequestscreenState();
}

class _RequestscreenState extends State<Requestscreen> {
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: whit,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            
            title: Text(
              "Follow request",
              style: TextStyle(
                  color: black, fontSize: 24, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            bottom: TabBar(
          
            indicatorColor: purpal,
            labelColor: purpal,
            unselectedLabelColor: Colors.grey,
            tabs:  [
              Container(
                height: 38,
                width: 80,
                decoration: BoxDecoration(
                  color: semiwhit,
                  borderRadius: BorderRadius.circular(200),

                ),
                
                child: Tab(text: "Pending",height: 14,)),
                 Container(
                height: 38,
                width: 80,
                decoration: BoxDecoration(
                  color: semiwhit,
                  borderRadius: BorderRadius.circular(200),

                ),
                
                child: Tab(text: "Followers",height: 14,)),
                 Container(
                height: 38,
                width: 80,
                decoration: BoxDecoration(
                  color: semiwhit,
                  borderRadius: BorderRadius.circular(200),

                ),
                
                child: Tab(text: "Following",height: 14,)),
             
            ],
          ),
          ),
          body:  TabBarView(
          children: [
          
            Fatchingpending(),
         
            
            Fatchingfollowers(),
           
            
            
            Fatchingfollowings()
          ],
        ),
        ));
  }
}
