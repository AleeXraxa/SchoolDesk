import 'package:get/get.dart';
import '../features/expenses/controller/expenses_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Dependency injection setup
    // Add your global controllers or services here
    Get.lazyPut(() => ExpensesController());
  }
}
