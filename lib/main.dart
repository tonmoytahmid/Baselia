import 'package:baseliae_flutter/AppRouting/AppRouting.dart';
import 'package:baseliae_flutter/Controller/MenueController/MenueController.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';
import 'package:baseliae_flutter/Controller/StreamController.dart';
import 'package:baseliae_flutter/Widgets/PostDetailsScreen.dart';
import 'package:baseliae_flutter/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:app_links/app_links.dart';
// import 'package:baseliae_flutter/View/PostDetailScreen.dart'; // <-- Replace with your actual post detail screen

void main() async {
  timeago.setLocaleMessages('en', timeago.EnMessages());

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(MenuControllers());

  Get.put(UserSessionController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/post') {
        final postId = uri.queryParameters['id'];
        if (postId != null) {
          final currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser == null) {
            Get.offNamed('/login');
          } else {
            Get.to(() => PostDetailScreen(postId: postId));
          }
        }
      }
    }, onError: (err) {
      print('Error receiving deep link: $err');
    });
  }

  // final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppRouting.routes,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      // navigatorObservers: [routeObserver],
      home: StreamControllerScreen(),
    );
  }
}
