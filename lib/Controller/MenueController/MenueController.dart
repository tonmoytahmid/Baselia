import 'package:get/get.dart';

class MenuControllers extends GetxController {
  
  var isSwitchedProfile = false.obs;

  void switchToProfile(bool value) {
    isSwitchedProfile.value = value;
  }
}
