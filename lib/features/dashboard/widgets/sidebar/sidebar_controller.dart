import 'package:get/get.dart';

class SidebarController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final menuItems = [
    {'icon': 'home', 'title': 'Home', 'route': '/dashboard'},
    {'icon': 'students', 'title': 'Students', 'route': '/students'},
    {'icon': 'classes', 'title': 'Classes', 'route': '/classes'},
    {'icon': 'fees', 'title': 'Fees', 'route': '/fees'},
    {'icon': 'challans', 'title': 'Challans', 'route': '/challans'},
    {'icon': 'attendance', 'title': 'Attendance', 'route': '/attendance'},
    {'icon': 'expenses', 'title': 'Expenses', 'route': '/expenses'},
    {'icon': 'users', 'title': 'Users', 'route': '/users'},
  ];

  void selectItem(int index) {
    selectedIndex.value = index;
    // No navigation needed - content switches in the same layout
  }

  bool isItemActive(int index) {
    return selectedIndex.value == index;
  }
}
