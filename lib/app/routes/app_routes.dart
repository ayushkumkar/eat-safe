import 'package:get/get.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/onboarding/onboarding_screen.dart';
import '../../modules/auth/login_screen.dart';
import '../../modules/auth/register_screen.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/scan/scan_screen.dart';
import '../../modules/result/result_screen.dart';
import '../../modules/profile/profile_screen.dart';
import '../../modules/history/history_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String profile = '/profile';
  static const String history = '/history';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: scan, page: () => const ScanScreen()),
    GetPage(name: result, page: () => const ResultScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: history, page: () => const HistoryScreen()),
  ];
}