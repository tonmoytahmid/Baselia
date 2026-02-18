import 'package:baseliae_flutter/Screens/CreatPost/CreatpostScreen.dart';
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/CreatgroupScreen.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/NewChatScreen.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/ProfileScreen.dart';
import 'package:baseliae_flutter/Screens/Settings/SettingsScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/ChoseAuthmethodScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/ConfirmLoginScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/CreatAccountScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/LoadingScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/LoginScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/PinVerificationScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/RegistrationWithemailScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/RegistrationWithphoneScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/SplashScreen.dart';
import 'package:baseliae_flutter/Screens/Pages/HomeScreen.dart';
import 'package:baseliae_flutter/Screens/Settings/UpdateProfileInfoScreen.dart';
import 'package:get/get.dart';

import '../Screens/Menu/MenuScreen.dart';
import '../Screens/Onbording/WelcomeScreen.dart';
import '../Screens/Pages/NavigationScreen.dart';

class AppRouting {
  static const String loading = "/loading";
  static const String login = "/login";
  static const String emailsignup = "/emailsignup";
  static const String home = "/home";
  static const String creatpost = "/creatpost";
  static const String creataccount = "/creataccount";
  static const String pinverification = "/pinverification";
  static const String confirmlogin = "/confirmlogin";
  static const String wlelcome = "/welcome";
  static const String splash = "/splash";
  static const String dashboard = "/dashboard";
  static const String choseauth = "/choseauth";
  static const String phonesignup = "/phonesignup";
  static const String menu = "/menu";
  static const String settings = "/settings";
  static const String updateprofileinfo = "/updateprofileinfo";
  static const String profile = "/profile";
   static const String uploadprofile = "/uploadprofile";
   static const String newChatScreen = "/newChatScreen";
    static const String createGroupScreen = "/createGroupScreen";



  static Transition appTransition = Transition.rightToLeftWithFade;
  static Duration appTransitionDuration = Duration(microseconds: 800);

  static List<GetPage> routes = [
    GetPage(
      name: loading,
      page: () => Loadingscreen(),
      transition: appTransition,
    ),
    GetPage(
        name: login,
        page: () => Loginscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: emailsignup,
        page: () => RegistrationWithEmailscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: home,
        page: () => Homescreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
      name: creatpost,
      page: () => Creatpostscreen(),
      transition: appTransition,
    ),
    GetPage(
        name: creataccount,
        page: () => Creataccountscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: pinverification,
        page: () => Pinverificationscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: confirmlogin,
        page: () => Confirmloginscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: wlelcome,
        page: () => Welcomescreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: splash,
        page: () => Splashscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: dashboard,
        page: () => Navigationscreen(),
        transition: Transition.zoom,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: choseauth,
        page: () => Choseauthmethodscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: phonesignup,
        page: () => Registrationwithphonescreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
    GetPage(
        name: menu,
        page: () => Menuscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),

        GetPage(
        name: settings,
        page: () => Settingscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),

        GetPage(
        name: updateprofileinfo,
        page: () => Updateprofileinfoscreen(),
        transition: Transition.native,
        transitionDuration: appTransitionDuration),
        
         GetPage(
        name: profile,
        page: () => Profilescreen(),
        transition: Transition.native,
        transitionDuration: appTransitionDuration),

         GetPage(
        name: uploadprofile,
        page: () => Updateprofileinfoscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),

        GetPage(
        name: newChatScreen,
        page: () => Newchatscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),

        
        GetPage(
        name: createGroupScreen,
        page: () => Creatgroupscreen(),
        transition: appTransition,
        transitionDuration: appTransitionDuration),
  ];
}
