import 'package:baseliae_flutter/Fatching/Comments/FatchingTopcomment.dart';
import 'package:baseliae_flutter/Fatching/Comments/FtchingComments.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';

void showCommentsBottomSheet(
    BuildContext context, String postId, String image) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicator: BoxDecoration(
                            color: purpal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            _getTabContainer("Top", 0),
                            _getTabContainer("Newest", 1),
                          ],
                        ),
                        SizedBox(
                          height: 520, 
                          child: TabBarView(
                            children: [
                              Fatchingtopcomment(postId: postId),
                              Ftchingcomments(postId: postId),
                             
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _getTabContainer(String text, int index) {
  return Tab(
    child: Container(
      height: 38,
      width: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
      ),
      child: Text(text, style: TextStyle(fontSize: 14)),
    ),
  );
}