import 'package:baseliae_flutter/Screens/Onbording/SplashScreen.dart';
import 'package:baseliae_flutter/Screens/Pages/NavigationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class StreamControllerScreen extends StatefulWidget {
  const StreamControllerScreen({super.key});

  @override
  State<StreamControllerScreen> createState() => _StreamControllerScreenState();
}

class _StreamControllerScreenState extends State<StreamControllerScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
      
         
            if (snapshot.hasData) {
              return Navigationscreen();
            } else {
              return Splashscreen();
            }
       
      

        
      },
    ));
  }
}
