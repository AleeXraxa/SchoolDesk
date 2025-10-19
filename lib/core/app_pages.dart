import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/controller/login_controller.dart';
import '../features/dashboard/view/dashboard_view.dart';
import '../features/dashboard/controller/dashboard_controller.dart';
import '../features/students/view/students_view.dart';
import '../features/students/controller/students_controller.dart';
import '../features/classes/view/classes_view.dart';
import '../features/classes/controller/classes_controller.dart';
import '../features/fees/view/fees_view.dart';
import '../features/fees/controller/fees_controller.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: AppRoutes.students,
      page: () => const StudentsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentsController>(() => StudentsController());
      }),
    ),
    GetPage(
      name: AppRoutes.classes,
      page: () => const ClassesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ClassesController>(() => ClassesController());
      }),
    ),
    GetPage(
      name: AppRoutes.fees,
      page: () => const FeesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FeesController>(() => FeesController());
      }),
    ),
    // Add more pages here as needed
  ];
}
