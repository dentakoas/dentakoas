import 'package:get/get.dart';

class HomeContrller {
  static HomeContrller get instance => Get.find();

  final carouselCurrentIndex = 0.obs;

  void updatePageIndicator(index) {
    carouselCurrentIndex.value = index;
  }
}
