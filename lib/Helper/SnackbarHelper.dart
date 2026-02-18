import 'package:get/get.dart';


class SnackbarHelper {
  static void showErrorSnackbar(String message) {
   
    try {
      Get.snackbar('Error', message);
    } catch (e) {
      print("Error Sound : $e");
    }
  }

  static void showSuccessSnackbar(String message) {
   
   try{ Get.snackbar('Success', message);}catch(e){print("Error Sound : $e");}
  }
}
