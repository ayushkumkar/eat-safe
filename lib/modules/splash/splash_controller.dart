import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    final String? uid = prefs.getString('uid');

    if (!seenOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (uid == null) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}