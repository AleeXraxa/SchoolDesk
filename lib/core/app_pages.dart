import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/controller/login_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    // Add more pages here as needed
  ];
}
