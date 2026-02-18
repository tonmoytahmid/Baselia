import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../CreatPost/CreatpostScreen.dart';
import 'HomeScreen.dart';
import 'MessageScreen.dart';
import 'NotificationScreen.dart';
import 'RequestScreen.dart';

class Navigationscreen extends StatefulWidget {
  const Navigationscreen({super.key});

  @override
  State<Navigationscreen> createState() => _NavigationscreenState();
}

class _NavigationscreenState extends State<Navigationscreen> {
  int _currentIndex = 0;

  final GlobalKey<HomescreenState> _homeScreenKey =
      GlobalKey<HomescreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Homescreen(key: _homeScreenKey),
      Requestscreen(),
      Messagescreen(),
      NotificationBottomSheet(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        mini: true,
        shape: CircleBorder(),
        onPressed: () {
          Get.to(() => Creatpostscreen());
        },
        backgroundColor: purpal,
        child: Icon(
          Icons.add,
          color: whit,
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 30,
        shadowColor: Colors.black,
        color: black,
        child: BottomNavigationBar(
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            elevation: 1.5,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            iconSize: 28,
            selectedItemColor: purpal,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == _currentIndex && index == 0) {
                // 👇 If already on Home tab, scroll to top
                _homeScreenKey.currentState?.scrollToTop();
              } else {
                setState(() => _currentIndex = index);
              }
            },
            items: [
              BottomNavigationBarItem(
                  icon: _currentIndex == 0
                      ? Icon(
                          Icons.home,
                          color: purpal,
                        )
                      : Icon(
                          Icons.home_outlined,
                          color: purpal,
                        ),
                  label: "Home"),
              BottomNavigationBarItem(
                  icon: _currentIndex == 1
                      ? Icon(Icons.group, color: purpal)
                      : Icon(Icons.group_outlined, color: purpal),
                  label: "Friends"),
              BottomNavigationBarItem(
                  icon: _currentIndex == 2
                      ? Icon(
                          Icons.message,
                          color: purpal,
                        )
                      : Icon(Icons.messenger_outline_sharp, color: purpal),
                  label: "Message"),
              BottomNavigationBarItem(
                  icon: _currentIndex == 3
                      ? Icon(Icons.pan_tool, color: purpal)
                      : Icon(Icons.pan_tool_outlined, color: purpal),
                  label: "Help"),
            ]),
      ),
      body: _pages[_currentIndex],
    );
  }
}
